function h = h_st(A, B, w)
%H_ST Cross product of elements of matrices A and B.
%   H = H_ST(A, B, W) calculates the cross product of elements of a matrix 
%   'B' and a matrix 'A' displaced with all combinations of pairs of 
%   elements from the set [-W+1,...,0,...,W-1] in both dimensions. This 
%   results is just a convolution of both matrices which is computed using 
%   FFT for speed.

% Matrices dimensions
[m, n] = size(A);

% Extend matrices and compute convolution
A_ext  = ExtendMatrix(A, [0 w], [0 w]);
B_ext  = ExtendMatrix(rot90(B, 2), [0 w], [0 w]);
h      = ifft2(fft2(A_ext).*fft2(B_ext));
h      = h(m-w+1:m+w-1,n-w+1:n+w-1);
end