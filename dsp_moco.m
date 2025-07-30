function ds = dsp_moco(A, B, d, w)
    [m, n] = size(A);
    s = d(1); t = d(2);

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

    D    = D_st(A_d, w);
    g_a  = g_st(A_d, w);
    g_b  = rot90(g_st(B_d, w), 2);
    h    = h_st(A_d, B_d, w);
    f    = (g_a + g_b - 2*h)./D;
    minf = min(f, [], 'all');
    [r, c] = find( f == minf );
    ds     = [r-w; c-w] + d;
end