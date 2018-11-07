function [ results ] = run_ldea( seq, res_path, bSaveImage )
%RUN_LOGPOLAR Summary of this function goes here
%   Detailed explanation goes here

	
    seq = evalin('base', 'subS');
    target_sz = seq.init_rect(1,[4,3]);
    pos = seq.init_rect(1,[2,1]) + floor(target_sz/2);
    img_files = seq.s_frames;
    video_path = [];

    %call tracker function with all the relevant parameters
    [affs,rects, ~,~,~, time] = tracker(video_path, img_files, pos, target_sz, 0,...
         0);


    results.type = 'rect';
    results.res = rects;
    results.affs = affs;

    results.fps = size(rects,1)/time;

end

