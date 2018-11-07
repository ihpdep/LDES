function [affs,rects,points, scales, rotations, time] = tracker(video_path, img_files, pos, target_sz, rot, ...
	 show_visualization)

    %% initialize the tracker
    [p,pos,target_sz] = init(video_path, img_files, pos, target_sz, rot, show_visualization);

	time = 0;  %to calculate FPS
    rects = zeros(numel(img_files), 4);
    points = zeros(numel(img_files), 8);
    scales = zeros(numel(img_files), 1);
    rotations = zeros(numel(img_files), 1);
    tmp_sc=1.0;
    tmp_rot=0.0;
    affs = zeros(numel(img_files), 10);
	for frame = 1:numel(img_files),
		%load image
		im = imread([video_path img_files{frame}]);
		tic()
		if frame > 1,
            [pos,tmp_sc,tmp_rot,cscore,sscore] = tracking(im,pos,p,0);
            %% BGD iteration
            if p.isBGD
                cscore = (1-p.interp_n)*cscore + p.interp_n*sscore;
                iter = 0;
                mcscore = 0;
                while iter < 5
                    %% make sure the scale is not too small
                    if sum(floor(p.sc.*tmp_sc.*p.window_sz0)) < 10
                        tmp_sc = 1.0;
                    end
                    %% iterative update scale and rotation
                    p.sc = p.sc*tmp_sc;
                    p.rot =p.rot + tmp_rot;% 
                    if cscore >= mcscore 
                        msc = p.sc;
                        mrot = p.rot;
                        mpos = pos;
                        mcscore = cscore;
                    else
                        break;
                    end
                    [pos,tmp_sc,tmp_rot,cscore,sscore] = tracking(im,pos,p,iter);
                    cscore = (1-p.interp_n)*cscore + p.interp_n*sscore;
                    iter = iter +1;
                end
                %% revert to the best cscore one
                pos = mpos;
                p.sc = msc;
                p.rot = mrot;
            end
        end
        %% updating
        if frame == 1
            %% initialization
            p = logupdate(1,im, pos, tmp_sc,tmp_rot,p);
        else
            %% update model
            p = logupdate(0,im,pos, tmp_sc,tmp_rot,p);
        end
        %% filter pos
        if pos(1) > size(im,1); pos(1) = size(im,1);end;
        if pos(2) > size(im,2); pos(2) = size(im,2);end;
        if pos(1) < 1; pos(1) = 1;end;
        if pos(2) < 1; pos(2) = 1;end;
        
        %% construct return variables
        target_sz = p.sc .* p.target_sz0;
        box = [pos([2,1]) - target_sz([2,1])/2, target_sz([2,1])];
        aff = [];
        if p.isRotation
            T = parameters_to_projective_matrix('SIMILARITY',...
                [1,p.rot,pos(2),pos(1)]);
            [aff,~]= getLKcorner(T, target_sz);
            aff(:,5)=aff(:,1);        
            points(frame,:) = [aff(1,1),aff(2,1),aff(1,4),aff(2,4),....
                             aff(1,3),aff(2,3),aff(1,2),aff(2,2)];
            scales(frame, 1) = p.sc(1);
            rotations(frame, 1) = p.rot;
        end
        p.aff = aff;
            
        time = time + toc();
        rects(frame,:) = box;
        if p.isRotation
            affs(frame,:) = p.aff(:);
        end
		%% visualization
		if show_visualization,
			stop = p.update_visualization(frame, box,p.aff);
			if stop, break, end  %user pressed Esc, stop early
			drawnow
		end
		
    end
end


