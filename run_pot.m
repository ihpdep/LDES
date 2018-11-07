%video_path = '/Users/zhefeng.wzf/dataset/POT/V01/V01_1.mp4';
%gt_path = '/Users/zhefeng.wzf/dataset/POT/annotation/annotation/V01_1_gt_points.txt';

base_path = '~/Data/POT/POT/';
result_path = '~/Data/POT/results/LDES/';

if ~exist('myfolder', 'dir')
    mkdir(result_path)
end

videos = dir([base_path 'V*']);
videos = sort({videos.name});


parfor index = 1:numel(videos),
    
    video = videos{index};
    
    result_file = [result_path video '_LDESNEW.txt'];
     if exist(result_file,'file'),
         fprintf('%s has already existed.\n',result_file);
         continue;
     end
	
    %get image file names, initial state, and ground truth for evaluation
    [img_files, pos, target_sz, rot, ground_truth, video_path] = load_video_info(base_path, video, 'POT');
		
		
    %call tracker function with all the relevant parameters
    [positions, ~, points, scales, rotations, time] = tracker(video_path, img_files, pos, target_sz,rot, 0);
		
    %calculate and show precision plot, as well as frames-per-second
    %precisions = precision_plot(positions(:,[1,2]), ground_truth, video, show_plots);

    %fprintf('%12s - Precision (20px):% 1.3f, FPS:% 4.2f\n', video, precisions(20), fps)
    
    fid = fopen(result_file,'w');
    for i = 1:size(points,1),
        fprintf(fid, '%.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f\n',points(i,:));
    end
    fclose(fid);
    
     % compute the precise
     inx = 1:500;
     inx = find(mod(inx,2) ~= 0);
     
     ground_truth = ground_truth(2:end,:);
     gtFilter = ground_truth(inx,:);
     
     points = points(2:end,:);
     rtFilter = points(inx,:);
     
     aerr = gtFilter - rtFilter;
     aerr = aerr.^2;
     aerr = sum(aerr,2);
     aerr = aerr / 4;
     aerr = sqrt(aerr);
     
     threshold = 20;
     mask = aerr <= threshold;          
     precesion = sum(mask)/size(aerr,1);

     fps = numel(img_files) / time;
     
     
     fprintf('%12s - Precision (20px):% 1.3f, Time: %.3fs, FPS:% 4.2f\n',  video,precesion, time, fps);
     log_file = '~/Data/POT/results/ldes_log.txt';
     fid = fopen(log_file,'a');
     fprintf(fid, '%s - Precision (20px):% 1.3f, Time: %.3fs, FPS:% 4.2f\n',  video,precesion, time, fps);
     fclose(fid);
     
     
end