function wimg = mwarpimg(img,p,sz)

    if (size(p,1) == 1)
        p = p(:);
    end
    imsz = size(img);
    w = sz(2);  h = sz(1); 
%     [x,y] = meshgrid(1:w, 1:h);
    [x,y] = meshgrid([1:w]-floor(w/2), [1:h]-floor(h/2));
%     tmp1 = cat(2, ones(h*w,1),x(:),y(:));
    tmp1 = zeros(h*w,3);
    tmp1(:,1)=1;
    tmp1(:,2)=x(:);
    tmp1(:,3)=y(:);
    tmp2 = [p(1) p(2); p(3:4) p(5:6)];
    tmp3 = tmp1*tmp2;
    tmp3(tmp3<1)=1;
    tmp3(tmp3(:,1)>imsz(2),1)=imsz(2);
    tmp3(tmp3(:,2)>imsz(1),2)=imsz(1);
    pos = reshape( tmp3 , [h,w,2]);
    cn=size(img,3);
    wimg=zeros([sz cn]);
    for i=1:cn
        tmp4 = interp2(img(:,:,i), pos(:,:,1), pos(:,:,2));
        wimg(:,:,i) = squeeze(tmp4);
    end
%     wimg(find(isnan(wimg))) = 0;

% tmp2 = [ p(3:4) p(5:6);p(1) p(2)]';
% tform = affine2d([tmp2; 0 0 1]');
% wimg = imwarp(img,tform);
end