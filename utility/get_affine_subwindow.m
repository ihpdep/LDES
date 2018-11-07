function out = get_affine_subwindow(im, pos, sc, rot, window_sz)

%     p = double(round([pos(2) pos(1) sz(2) sz(1) 0]));
%     param0 = [p(1), p(2), p(3)/window_sz(2), p(5), p(4)/p(3), 0];
%     param0 = affparam2mat(param0);
    param0 = simiparam2mat(pos(2),pos(1),rot, sc);
%     out = uint8(warpimg(double(im), param0, window_sz));
    out = uint8(mwarpimg(double(im), double(param0), window_sz));

end


