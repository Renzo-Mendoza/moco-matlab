function d = moco(A, B, w, srch_wdw, scl, max_val, downs_meth, is_norm)
    if ~is_norm
        [S,M] = std(A,[],'all');
        A = (A - M) / S;
        [S,M] = std(B,[],'all');
        B = (B - M) / S;
    end
    
    if downs_meth == "length"
        k = ceil( max( log( max(size(A)) / max_val) / log(scl), 0) );
    elseif downs_meth == "area"
        k = ceil( sqrt( max( log(numel(A) / max_val) / log(scl), 0) ) );
    end
    d = [0; 0];
    
    % Initial estimation (downsampled image)
    A_n = imresize(A, (1/scl)^k);
    B_n = imresize(B, (1/scl)^k);
    w_n = ceil(w*(1/scl)^k)+1;
    d   = dsp_moco(A_n, B_n, d, w_n);
    
    for i = k-1:-1:0
        A_n = imresize(A, (1/scl)^i);
        B_n = imresize(B, (1/scl)^i);
        d = d*scl;
        d = dsp_moco(A_n, B_n, d, srch_wdw);
    end
end