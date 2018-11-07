function [ r ] = mresize( patch,sz )
%MRESIZE Summary of this function goes here
%   Detailed explanation goes here
 r = imresize(patch, sz,'bicubic');
%  r = mexResize(patch, sz,'linear');
% r = imresize(patch, sz,'auto');
end

