function E = ExtendMatrix (A, row_ext, column_ext)
    m_a = row_ext(1); m_p = row_ext(2);
    n_a = column_ext(1); n_p = column_ext(2);
    [m,n] = size(A);
    E = [zeros(m_a,n_a), zeros(m_a,n), zeros(m_a,n_p);
         zeros(m,n_a)  ,            A, zeros(m,n_p);
         zeros(m_p,n_a), zeros(m_p,n), zeros(m_p,n_p)];
end