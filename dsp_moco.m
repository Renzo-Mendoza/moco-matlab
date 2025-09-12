function ds = dsp_moco(A, B, d, w)
%DSP_MOCO moco approach for a pair of images without downsampling.
%   DS = MOCO(A, B, D, W) performs moco to determine the displacement 'DS' 
%   between a template image 'B' and a stack image 'A'. The expected 
%   maximum displacement 'W' is defined by the user. 'D' denotes the 
%   initial displacement of the stack image with respect to the template 
%   image.

% Image dimensions and initial displacement
[m, n] = size(A);
s = d(1); t = d(2);

% Shift initial images
if s >= 0 && t >= 0
    A_d = A(s+1:m,t+1:n);
    B_d = B(1:m-s,1:n-t);
elseif s >= 0 && t <= 0
    A_d = A(s+1:m,1:n+t);
    B_d = B(1:m-s,1-t:n);
elseif s <= 0 && t >= 0
    A_d = A(1:m+s,t+1:n);
    B_d = B(1-s:m,1:n-t);
else
    A_d = A(1:m+s,1:n+t);
    B_d = B(1-s:m,1-t:n);
end

% Compute f(s,t)
D    = D_st(size(A_d), w); % Area of sets D
g_a  = g_st(A_d, w); % First sum
g_b  = rot90(g_st(B_d, w), 2); % Second sum
h    = h_st(A_d, B_d, w); % Cross pixel product
f    = (g_a + g_b - 2*h)./D; % L2 norm difference matrix

% Search for minimum and estimate displacement
minf = min(f, [], 'all');
[r, c] = find( f == minf );
ds     = [r-w; c-w] + d;
end