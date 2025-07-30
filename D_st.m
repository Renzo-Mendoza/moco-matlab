function D = D_st(A, w)
    [m, n] = size(A);
    D      = zeros(2*w - 1, 2*w - 1);
    for i = 1:w
        % → ↓
        D(1,i) = (m-w+1)*(n-w+i);
        D(i,1) = (m-w+i)*(n-w+1);
    end
    for i = 2:w
        for j = 2:w
            % → ↓
            D(i,j) = D(i-1,j) + D(i,j-1) - D(i-1,j-1) + 1;
        end
    end
    D(w+1:end,1:w) = flip(D(1:w-1,1:w), 1);
    D(:,w+1:end)   = flip(D(:,1:w-1), 2);
end