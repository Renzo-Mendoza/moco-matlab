function E = ExtendMatrix (A, row_ext, column_ext)
%EXTENDMATRIX Extension of rows and colums of a matrix with zero values.
%   E = EXTENDMATRIX(A, ROW_EXT, COLUMN_EXT) performs an extension of the 
%   matrix 'A' by concatenating rows of zeros on the top and bottom, and 
%   columns of zeros on the right and left. Both 'ROW_EXT' and 'COLUMN_EXT'
%   are vectors of two elements, the first element indicates the 
%   number of rows (for 'ROW_EXT') and columns (for 'COLUMN_EXT') to be 
%   concatenated on the left/top, and the second indicates the number to be
%   concatenated on the right/bottom, respectively.
%
%   For example, if ROW_EXT = [1 2] and COLUMN_EXT = [3 4], then
%   the result has 1 row of zeros on top, 2 on the bottom, 3 columns of zeros
%   on the left, and 4 on the right of matrix 'A'.

m_a = row_ext(1); m_p = row_ext(2);
n_a = column_ext(1); n_p = column_ext(2);
[m,n] = size(A);
E = [zeros(m_a,n_a), zeros(m_a,n), zeros(m_a,n_p);
     zeros(m,n_a)  ,            A, zeros(m,n_p);
     zeros(m_p,n_a), zeros(m_p,n), zeros(m_p,n_p)];
end