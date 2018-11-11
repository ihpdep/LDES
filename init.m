function [ p,pos,target_sz ] = init( video_path, img_files, pos, target_sz, rot, show_visualization )
%INIT Summary of this function goes here
%   Detailed explanation goes here
    addpath('./utility');
    addpath('./utility/mexfiles');
    %% settings for correlation filter
    kernel_type = 'linear'; 
	kernel.type = kernel_type;
    features.gray = false;
	features.hog = false;
    features.hogcolor = false;

	padding = 1.5;  %extra area surrounding the target
	lambda = 1e-4;  %regularization
	output_sigma_factor = 0.1;  %spatial bandwidth (proportional to target)
	

    interp_factor = 0.01;
    features.hog_orientations = 9;
    cell_size = [4 4];
		
    min_image_sample_size = 100^2;   % Minimum area of image samples
    max_image_sample_size = 350^2;   % Maximum area of image samples
    
    %% settings for LDES
    p={}; 
  
    p.fixed_model_sz = [224 224];
    % to tun off/on rotation estimation
    p.isRotation=1;
    % to tun off/on Block Gradiant Descent
    p.isBGD=p.isRotation;
    p.isSubpixel = 1;
    % coefficient for equation 3
    p.interp_n = 0.85;
    

	%% learning window size, taking padding into account* (1 + padding)
    p.window_sz = floor(target_sz* (1 + padding) );   
    % calculating the model size not exceeds max and min of size
    search_area = prod(p.window_sz);
    %fprintf('%d, %d, %f \n', p.window_sz(1), p.window_sz(2), sqrt(search_area));
    if search_area > max_image_sample_size
        p.sc = sqrt(search_area / max_image_sample_size);
    elseif search_area < min_image_sample_size
        p.sc = sqrt(search_area / min_image_sample_size);
    else
        p.sc = 1.0;
    end

    p.window_sz0 = round(p.window_sz./p.sc);
    feature_sz = floor(p.window_sz0./cell_size); %current vgg-m cnn
    p.window_sz0 = feature_sz.*cell_size;% refine the size

    p.sc = p.window_sz ./ p.window_sz0;
    cell_size = p.window_sz0 ./ feature_sz;
    
    p.rot = rot;

    %% search window size and feature size
    avg_dim = sum(p.window_sz)/4;
    p.window_sz_search = floor(p.window_sz+avg_dim);%

    p.window_sz_search0 = floor(p.window_sz_search./p.sc);
    cell_size_search = cell_size;

    feature_sz0 = floor(p.window_sz_search0./cell_size_search);
    residual = feature_sz0 - feature_sz;
    feature_sz0 = feature_sz0+mod(residual,2);
    p.window_sz_search0 = feature_sz0.*cell_size_search; % refine the size to make thing easier

    p.sc = p.window_sz_search ./ p.window_sz_search0;
    p.target_sz0 = round(target_sz./p.sc);
	
	%% create regression labels, gaussian shaped, with a bandwidth
	%proportional to target size
	p.output_sigma = sqrt(prod(target_sz)) * output_sigma_factor ./ cell_size;
    p.y = gaussian_shaped_labels(p.output_sigma, round(p.window_sz0 ./ cell_size));
	p.yf = {};
    p.yf{1} = fft2(p.y);

	%store pre-computed cosine window
    p.cos_window = cellfun(@(yf) single(hann(size(yf,1))*hann(size(yf,2))'), p.yf, 'uniformoutput', false);
    p.cos_window_search = {};
 	p.cos_window_search{1} = hann(floor(p.window_sz_search0(1)./cell_size_search(1))) * hann(floor(p.window_sz_search0(2)./cell_size_search(2)))';	
    
    %% scale settings
    p.learning_rate_scale = 0.015;
    avg_dim = sum(target_sz)/2.5;
    p.scale_sz = (target_sz +avg_dim)./p.sc;%floor(repmat(sqrt(prod(target_sz * scale_padding)), 1, 2));
    p.scale_sz_window = [128,128];%floor(repmat(sqrt(prod(scale_sz)), 1, 2));
    p.features_scale = features;
    p.features_scale.hog=true;
    p.scale_sz0 = p.scale_sz;
    
	%store pre-computed cosine window
	p.cos_window_scale = hann(p.scale_sz_window(1)) * hann(p.scale_sz_window(2))';	
	p.mag =size(p.cos_window_scale,1)/log(sqrt(sum(size(p.cos_window_scale).^2)/4));% not important    p.features=features;
    p.cell_size=cell_size_search;
    
%     output_sigma_scale = sqrt(prod(target_sz)) * output_sigma_factor / 8;
%  	y_scale = gaussian_shaped_labels([output_sigma_scale output_sigma_scale], floor(p.scale_sz_window ));
%     yf_scale = fft2(y_scale);
    %% load color name transform and feature for CF
    temp = load('w2crs');
    features.w2c = temp.w2crs;
    p.features=features;
    p.features.hogcolor=true;
    p.kernel =kernel;
    p.lambda = lambda;
    p.interp_factor=interp_factor;

    %% color histogram
    p.features.interPatchRate = 0.3;
    p.features.nbin = 10;
    
    p.colorUpdateRate = 0.01;
    p.merge_factor = 0.4;
    
    %% create video interface
    if show_visualization, 
        p.update_visualization = show_video(img_files, video_path, 0);
    end

end

