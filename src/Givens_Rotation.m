function [R, d] = Givens_Rotation(R, d, newMatrix)
%%
% This function conducts the Givens Rotation for the factors added for the
% observation
% INPUT:  R        , size: M x M        , the previous R matrix
%         newMatrix, size: K x M        , the newly added matrix::obs
%         newMatrix, size: K x M+12     , the newly added matrix::control
%         d        , size: M x 1        , the vector in QR factorization 
% OUTPUT: R        , size: (M+K) x (M+K), the output upper triangular matrix
%
%% First augment R
K = size(newMatrix,1);      % size (row number) of newly added matrix
K_2 = size(newMatrix,2);    % size (col number) of newly added matrix
M = size(R,1);              % size of orignal R
if M == K_2                 % this is observation
    R = [R; newMatrix];     % get size (M+K) x M
    R = [R, zeros(M+K,K)];  % get size (M+K) x (M+K)
else                        % this is control
    R = [R, zeros(M,K_2-M)];% getsize M x (M+K)
    R = [R; newMatrix];     % get size (M+K) x (M+K)
end

%% Start rrotation
% start to do Givens Rotation, for every entry in the newly added matrix
for i = 1:j   % columns
    for j = M+1:M+K % rows
        if R(j,i) ~= 0
            beta = R(j,i);  % a_ik::to become zero
            alpha = R(i,i); % a_kk::the diagonal element 
            if abs(beta) > abs(alpha)
                CosPhi = -alpha/(beta*(sqrt(1+(alpha/beta)^2)));
                SinPhi = 1/sqrt(1+(alpha/beta)^2);
            else
                SinPhi = -beta/(alpha*(sqrt(1+(alpha/beta)^2)));
                CosPhi = 1/sqrt(1+(alpha/beta)^2);
            end
            % fill in Givens
            Givens = zeros(j-i+1,j-i+1);
            Givens(1,1) = CosPhi;
            Givens(end,end) = CosPhi;
            Givens(1,end) = SinPhi;
            Givens(end,1) = -SinPhi;
            % multiply Givens Rotation to the subregion of R
            R(i:j,i:j) = Givens * R(i:j,i:j);
            % multiply Givens Rotation to the subregion of d
            d(i:j) = Givens * d(i:j);
        end
    end
end

end