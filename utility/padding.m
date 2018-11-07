function r = padding(x,pad)
mn = size(x);
mn = mn([1,2]);
delta = floor((pad - mn)/2);
n = size(x,3);
r = zeros([pad(1) pad(2) n]);
idx = [delta(1)+1 delta(1)+mn(1)];
idy = [delta(2)+1 delta(2)+mn(2)];
r(idx(1):idx(2),idy(1):idy(2),:) = x;
% 
% r=padarray(x,delta); 
% 
% if size(r,1) < pad(1)
%     r = [r;zeros(1,size(r,2))];
% end
% 
% if size(r,2) < pad(2)
%     r = [r, zeros(size(r,1),1)];
% end
end