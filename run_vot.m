function run_vot
%RUN_VOT 此处显示有关此函数的摘要
%   此处显示详细说明

% NSAMF tracker
% coded by Li, Yang, 2015

addpath('./utility');
%cleanup = onCleanup(@() exit() ); % Always call exit command at the end to terminate Matlab!
RandStream.setGlobalStream(RandStream('mt19937ar', 'Seed', sum(clock))); % Set random seed to a different value every time as required by the VOT rules.


[handle, image, region] = vot('polygon'); % Obtain communication object

corners= reshape(region,[2,4]);
lu = min(corners,[],2);
pos = sum(corners,2)/4;
pos = pos([2,1])';lu = lu([2,1])';
target_sz =(pos - lu) *2;

d = dist(reshape(region,2,4));
target_sz = [(d(2,3)+d(1,4))/2,(d(2,1)+d(3,4))/2];
 pos = [(region(2) + region(4) + region(6) + region(8))/4,...
        (region(1) + region(3) + region(5) + region(7))/4];

A = [0,-1];
B = [region(5)-region(3), region(4)-region(6)];
rot1 = acos(dot(A,B)/(norm(A)*norm(B))) * 2 / pi;
if prod(B) < 0,
    rot1 = -rot1;
end

C = [region(7)-region(1), region(2)-region(8)];
rot2 = acos(dot(A,C)/(norm(A)*norm(C))) * 2 / pi;
if prod(C) < 0,
    rot2 = -rot2;
end

rot = (rot1 + rot2) / 2;



param ={};

[p,pos,target_sz] = init([], [], pos, target_sz, rot, 0);

tmp_sc=1.0;
tmp_rot=0.0;

frame = 1;

im = imread(image);

%if p.resize_image,
%    im = imresize(im, 0.5);
%end
interp_n = 0.85;
p = logupdate(1,im, pos, tmp_sc,tmp_rot,p);

while true
    [handle, image] = handle.frame(handle); % Get the next frame
    if isempty(image) % Are we done?
        break;
    end;

    im = imread(image);
    
    frame = frame+1;
 % Read the image from file
    % TODO: Perform a tracking step with the image, obtain new region
    [pos,tmp_sc,tmp_rot,cscore,sscore] = tracking(im,pos,p,0);
    if p.isBGD
        cscore = (1-interp_n)*cscore + interp_n*sscore;
	    iter = 0;
	    mcscore = 0;
        while iter < 5
            if sum(floor(p.sc.*tmp_sc.*p.window_sz0)) < 10
    			tmp_sc = 1.0;
	        end
	        p.sc = p.sc*tmp_sc;
	        p.rot =p.rot + tmp_rot;% 
	        if cscore >= mcscore %|| sscore >= msscore
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
    	pos = mpos;
    	p.sc = msc;
    	p.rot = mrot;
    end

    %% updating
    p = logupdate(0,im,pos, tmp_sc,tmp_rot,p);
    
    %% filter pos
    if pos(1) > size(im,1); pos(1) = size(im,1);end;
    if pos(2) > size(im,2); pos(2) = size(im,2);end;
    if pos(1) < 1; pos(1) = 1;end;
    if pos(2) < 1; pos(2) = 1;end;
    %% construct return variables
    target_sz = p.sc .* p.target_sz0;
    box = [pos([2,1]) - target_sz([2,1])/2, target_sz([2,1])];
    T = parameters_to_projective_matrix('SIMILARITY',...
        [1,p.rot,pos(2),pos(1)]);
    [aff,~]= getLKcorner(T, target_sz);
    aff(:,5)=aff(:,1);        
    p.aff = aff;
    re = double([p.aff(:,1), p.aff(:,4), p.aff(:,3),p.aff(:,2)]);
    %region = double(box);
	re=re(:)';
    handle = handle.report(handle, re); % Report position for the given frame
end;

handle.quit(handle); % Output the results and clear the resources





end



