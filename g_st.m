function g = g_st(M, w)
    [m, n] = size(M);
    g      = zeros(2*w - 1, 2*w - 1);
    
    for i = 1:w
        % → ↓
        g(1,i) = sum(M(1:m-w+1,1:n-w+i).^2, 'all');
        g(i,1) = sum(M(1:m-w+i,1:n-w+1).^2, 'all');
        % ↑ →
        g(1,end-i+1) = sum(M(1:m-w+1,w-i+1:n).^2, 'all');
        g(i,end)     = sum(M(1:m-w+i,w:n).^2, 'all');
        % ← ↓
        g(end-i+1,1) = sum(M(w-i+1:m,1:n-w+1).^2, 'all');
        g(end,i)     = sum(M(w:m,1:n-w+i).^2, 'all');
        % ← ↑
        g(end,end-i+1) = sum(M(w:m,w-i+1:n).^2, 'all');
        g(end-i+1,end) = sum(M(w-i+1:m,w:n).^2, 'all');
    end
    
    for i = 2:w
        for j = 2:w
            % → ↓
            g(i,j) = g(i-1,j) + g(i,j-1) - g(i-1,j-1) + M(m-w+i,n-w+j)^2;
            % ← ↑
            g(2*w-i,2*w-j) = g(2*w-i+1,2*w-j) + g(2*w-i,2*w-j+1) - g(2*w-i+1,2*w-j+1) + M(w-i+1,w-j+1)^2;
            % ← ↓
            g(i,2*w-j) = g(i-1,2*w-j) + g(i,2*w-j+1) - g(i-1,2*w-j+1) + M(m-w+i,w-j+1)^2;     
            % ↑ →
            g(2*w-i,j) = g(2*w-i+1,j) + g(2*w-i,j-1) - g(2*w-i+1,j-1) + M(w-i+1,n-w+j)^2;
        end
    end
end