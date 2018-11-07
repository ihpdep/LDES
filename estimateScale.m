function [ scale ,rotate, mscore ] = estimateScale( model, obser, mag )
%ESTIMATESCALE Summary of this function goes here
%   Detailed explanation goes here
    [ptx,pty,mscore] = phaseCorrelate(model, obser);
    rotate = (pty-1)*pi/floor(size(obser,2)/2);
    scale = exp( (ptx-1) / mag);
end


function [ptx,pty,mscore]=phaseCorrelate(src1,src2)

    s1f = (fft2(src1));%.*hf;
    s2f = (fft2(src2));%.*hf;
  
    num = s2f.*conj(s1f);
    d =sqrt(num.*conj(num))+eps;
    Cf = sum(num./d,3);%(norm(s2f)*norm(s1f));%

    C = ifft2(Cf,'symmetric'); %// gives us the nice peak shift location...
    C = fftshift(C);

    mscore = max(C(:));
    [pty, ptx] = find(C == mscore, 1);
    %% sub-pixel
    slobe_y = 1;slobe_x = 1;
    idy = pty-slobe_y:pty+slobe_y; idx = ptx-slobe_x:ptx+slobe_x;
    idx(idx>size(C,2))=size(C,2);idx(idx<1)=1;
    idy(idy>size(C,1))=size(C,1);idy(idy<1)=1;

    weightPatch = C(idy,idx);
    s = sum(weightPatch(:)) + eps;
    pty = sum(sum(weightPatch,2).*idy') / s;
    ptx = sum(sum(weightPatch,1).*idx) / s;
    %%
    pty = pty - floor(size(src1,1)/2); 
    ptx = ptx - floor(size(src1,2)/2);


end
