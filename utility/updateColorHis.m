function [ features ] = updateColorHis( patch, features )
%UPDATECOLORHIS Summary of this function goes here
%   Detailed explanation goes here
sz = size(patch);
sz = sz(1:2);
pos = sz/2;
labPatch = patch;%applycform(patch, features.colorTransform);
interPatch = get_subwindow(labPatch, pos, sz*features.interPatchRate);
features.interPatch = interPatch;
pl = getColorSpaceHist(labPatch,features.nbin);
pi = getColorSpaceHist(interPatch,features.nbin);
if isfield(features,'pl')
    features.pi = (1 - features.colorUpdateRate) * features.pi +...
        features.colorUpdateRate * pi;
    features.pl = (1 - features.colorUpdateRate) * features.pl + ...
        features.colorUpdateRate * pl;
else
    features.pl = pl;
    features.pi = pi;
end


end

