function center_likelihood = getCenterLikelihood(object_likelihood, m)
%GETCENTERLIKELIHOOD computes the sum over rectangles of size M.
% CENTER_LIKELIHOOD is the 'colour response'
    sz = size(object_likelihood);
    n1 = sz(1) - m(1) + 1;
    n2 = sz(2) - m(2) + 1;

%% equivalent MATLAB function
    SAT = integralImage(object_likelihood);
    i = 1:n1;
    j = 1:n2;
    center_likelihood = (SAT(i,j) + SAT(i+m(1), j+m(2)) - SAT(i+m(1), j) - SAT(i, j+m(2))) / prod(m);
    
    center_likelihood = fillzeros(center_likelihood, sz);
end


function res = fillzeros(im,sz)

res = zeros(sz);

msz = floor((sz - size(im))/2);

res(msz(1)+1:msz(1)+size(im,1), msz(2)+1:msz(2)+size(im,2)) = im;


end