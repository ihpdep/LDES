function [ p ] = logupdate( init, im,pos, tmp_sc,tmp_rot, p )
%UPDATE Summary of this function goes here
%   Detailed explanation goes here

    %% obtain a new window setting for training at newly estimated status
    if sum(floor(p.sc.*tmp_sc.*p.window_sz0)) < 10
        tmp_sc = 1.0;
    end
    p.sc = p.sc*tmp_sc;   
    p.rot =p.rot + tmp_rot;% 
    p.window_sz = floor(p.sc.*p.window_sz0);
    p.window_sz_search = floor(p.sc.*p.window_sz_search0);
    
    %% compute the current CF model
    % sampling the image
    if p.isRotation
        patch = get_affine_subwindow(im, pos, p.sc,p.rot,p.window_sz0);
    else
        patchO = get_subwindow(im, pos, p.window_sz);
        patch = mresize(patchO, p.window_sz0);
    end
    % get feature and get model
    x = get_features(patch, p.features, p.cell_size, p.cos_window);
    xf = cellfun(@fft2, x, 'uniformoutput', false);
    kf = cellfun(@linear_correlation, xf, xf, 'uniformoutput', false);
    alphaf = cellfun(@(iyf,ikf) iyf ./ (ikf + p.lambda), p.yf, kf, 'uniformoutput', false);   %equation for fast training
    
    %% scale and rotation updating
    if p.isRotation
        % here is not similarity transformation
        patchL = get_affine_subwindow(im, pos, 1,p.rot,floor(p.sc.*p.scale_sz));
    else
        patchL =get_subwindow(im, pos, floor(p.sc.*p.scale_sz));
    end
    patchL = mresize(patchL, p.scale_sz_window);
    % get logpolar space and apply feature extraction
    patchL = mpolar(double(patchL),p.mag);
    patchL= get_features(patchL, p.features_scale, p.cell_size, []);

    %% updating color histogram probabilities
    sz = size(patch);
    sz = sz(1:2);
    iscolor = size(patch,3) > 1;
    if iscolor
        pos_in = sz/2;
        labPatch = patch;%applycform(patch, features.colorTransform);
        interPatch = get_subwindow(labPatch, pos_in, sz*p.features.interPatchRate);
        p.features.interPatch = interPatch;
        pl = getColorSpaceHist(labPatch,p.features.nbin);
        pi = getColorSpaceHist(interPatch,p.features.nbin);  
    end
    
    %% exponential moving average updating
    interp_factor_scale = p.learning_rate_scale;
    if init == 1,  %first frame, train with a single image
        p.model_alphaf = alphaf;
        p.model_xf = xf;
        p.modelPatch = patchL;
        if iscolor
            p.features.pl = pl;
            p.features.pi = pi;
        end
        p.iscolor=iscolor;
    else
        % CF model
        p.model_alphaf = cellfun(@(imodel_alphaf, ialphaf)...
            (1 - p.interp_factor) * imodel_alphaf + p.interp_factor * ialphaf, p.model_alphaf, alphaf, 'uniformoutput', false);
        p.model_xf = cellfun(@(imodel_xf, ixf) ...
            (1 - p.interp_factor) * imodel_xf + p.interp_factor * ixf, p.model_xf, xf, 'uniformoutput', false);            
        % scale and rotation model
        p.modelPatch =  ((1 - interp_factor_scale) * p.modelPatch + interp_factor_scale * patchL);
        % color model
        if iscolor
            p.features.pi = (1 - p.colorUpdateRate) * p.features.pi +...
                p.colorUpdateRate * pi;
            p.features.pl = (1 - p.colorUpdateRate) * p.features.pl + ...
                p.colorUpdateRate * pl;
        end
    end

end
