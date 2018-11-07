function [ pos, tmp_sc, tmp_rot, cscore,sscore ] = tracking(  im,pos, p, polish )
%TRACKING Summary of this function goes here
%   Detailed explanation goes here
		%obtain a subwindow for detection at the position from last
    %frame, and convert to Fourier domain (its size is unchanged)
    %% find a proper window size
    large_num = 0;
    if polish > large_num
        % use smaller one to speedup
        w_sz0 = p.window_sz0;
        c_w = p.cos_window;
    else
        w_sz0 = p.window_sz_search0;
        c_w = p.cos_window_search;
    end
    
    %% translational estimating
    if p.isRotation
        patch = get_affine_subwindow(im, pos, p.sc,p.rot,w_sz0);
    else
        sz_s = floor(p.sc.*w_sz0);
        patchO = get_subwindow(im, pos, sz_s);
        patch = mresize(patchO, w_sz0);
    end
    z = get_features(patch, p.features, p.cell_size, c_w);
    zf = cellfun(@fft2, z, 'uniformoutput', false);
    ssz = cellfun(@size, zf, 'uniformoutput', false);
    
    %% calculate response of the classifier at all shifts
    wf = cellfun(@(imodel_xf,imodel_alphaf) bsxfun(@times, conj(imodel_xf), imodel_alphaf)/ numel(imodel_xf),...
        p.model_xf,p.model_alphaf, 'uniformoutput', false); 
    if polish <= large_num % get same size for filter and image
        w = cellfun(@(iwf, issz) padding(ifft2(iwf),[issz(1), issz(2)]), wf,ssz, 'uniformoutput', false);
        wf = cellfun(@fft2, w, 'uniformoutput', false);%,round(size(w)/2)
    end
    pad_sz = {};
    pad_sz{1} = [0,0];
    tmp_sz = ssz{1};
    % Compute convolution for each feature block in the Fourier domain
    % use general compute here for easy extension in future
    rff = cellfun(@(hf, xf, pad_sz) padarray(sum(bsxfun(@times, hf, xf), 3), pad_sz),...
         wf, zf, pad_sz, 'uniformoutput', false);
    rff = cellfun(@(rff) imresize(rff, tmp_sz(1:2), 'nearest'), rff, 'uniformoutput', false);
    rf = rff{1};
    response_cf = ifft2(rf,'symmetric');  %equation for fast detection
    
    %% color histogram map
    response_color = zeros(size(response_cf));
    if size(patch,3) > 1
        object_likelihood = getColorSpace(patch,p.features.pi,p.features.pl);
        response_color = getCenterLikelihood(object_likelihood, p.target_sz0);
        response_color = mresize(response_color,size(response_cf));
    end
    
    %% combine the maps
    response_cf = fftshift(response_cf);
    response = (1 - p.merge_factor) *response_cf + p.merge_factor * response_color;

    %% sub-pixel search
    cscore =max(response(:));
    [pty, ptx] = find(response == cscore, 1);
    if p.isSubpixel
        slobe = 2;
        idy = pty-slobe:pty+slobe; idx = ptx-slobe:ptx+slobe;
        idx(idx>size(response,2))=size(response,2);idx(idx<1)=1;
        idy(idy>size(response,1))=size(response,1);idy(idy<1)=1;
        weightPatch = response(idy,idx);
        s = sum(weightPatch(:)) + eps;
        pty = sum(sum(weightPatch,2).*idy') / s;
        ptx = sum(sum(weightPatch,1).*idx) / s;
    end
    cscore = PSR(response,0.1);
    
    %% update the translational status
    vert_delta = pty - floor(size(response,1)/2);
    horiz_delta = ptx -floor(size(response,2)/2);
    local_trans = [vert_delta - 1, horiz_delta - 1];
    if p.isRotation
        sn = sin(p.rot); cs=cos(p.rot);
        pp = [p.sc(1)*cs,-p.sc(2)*sn;...
              p.sc(1)*sn, p.sc(2)*cs];
        pos = pos + (p.cell_size .* local_trans * pp);
    else
        pos = pos +  p.sc.*p.cell_size.*local_trans;
    end
    
    %% Estimating scale and rotation
    if p.isRotation
        patchL = get_affine_subwindow(im, pos, 1,p.rot,floor(p.sc.*p.scale_sz));
    else
        patchL = get_subwindow(im, pos, p.sc.*p.scale_sz);
    end
    patchL = mresize(patchL, p.scale_sz_window);
    % convert into logpolar
    patchLp = mpolar(double(patchL),p.mag);
    % get feature of scale and rotation
    patchLp= get_features(patchLp, p.features_scale, p.cell_size, []);
    [tmp_sc,tmp_rot,sscore] = estimateScale(p.modelPatch, patchLp ,p.mag);
    
    %% filter bad results
    if tmp_sc > 1.4, tmp_sc =1.4;end;
    if tmp_sc < 0.6, tmp_sc =0.6;end;   
    if tmp_rot > 1, tmp_rot =0;end;
    if tmp_rot < -1, tmp_rot =0;end;

end

