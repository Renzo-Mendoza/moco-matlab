function h = h_st(A,B,w)
    [m, n] = size(A);
    A_ext  = ExtendMatrix(A, [0 w], [0 w]);
    B_ext  = ExtendMatrix(rot90(B, 2), [0 w], [0 w]);
    h      = ifft2(fft2(A_ext).*fft2(B_ext));
    h      = h(m-w+1:m+w-1,n-w+1:n+w-1);
end