function [R, d] = Givens_Rotation(R, d, newMatrix, lamda)
%%
% This function conducts the Givens Rotation for the factors added for the
% observation
% INPUT:  R        , size: M x M        , the previous R matrix
%         newMatrix, size: K x M        , the newly added matrix::obs
%         newMatrix, size: K x M+12     , the newly added matrix::control
%         d        , size: M x 1        , the vector in QR factorization 
%         lamda    , size: K x 1        , residual vector
% OUTPUT: R        , size: M x M        , the output R for observation
%                          (M+K) x (M+K), the output R for control
%
%% First augment R
K = size(newMatrix,1);      % size (row number) of newly added matrix
K_2 = size(newMatrix,2);    % size (col number) of newly added matrix
M = size(R,1);              % size (row number) of orignal R
M_2 = size(R,2);            % size (col number) of orignal R
% assertions
assert( M==size(d,1) );
assert( K==size(lamda,1) );
if M == K_2                 % this is observation
    R = [R; newMatrix];     % get size (M+K) x M
else                        % this is control
    R = [R, zeros(M,K_2-M_2)];% getsize M x (M+K)
    R = [R; newMatrix];     % get size (M+K) x (M+K)
end
d = [d;lamda];  % (M+K) x 1
%% Start rrotation
% start to do Givens Rotation, for every entry in the newly added matrix
for i = 1:size(R,2)             % columns
    for j = M+K:-1:max(M+1,i+1) % rows
        if R(j,i) ~= 0
            R
            beta = R(j,i);  % a_ik::need to become zero
            alpha = R(i,i); % a_kk::the diagonal element 
            if abs(beta) > abs(alpha)
                CosPhi = alpha/(beta*(sqrt(1+(alpha/beta)^2)));
                SinPhi = 1/sqrt(1+(alpha/beta)^2);
            else
                SinPhi = beta/(alpha*(sqrt(1+(alpha/beta)^2)));
                CosPhi = 1/sqrt(1+(alpha/beta)^2);
            end
            % fill in Givens
            Givens = eye(M+K,M+K); % size (M+K) x (M+K)
            Givens(i,i) = CosPhi;
            Givens(j,j) = CosPhi;
            Givens(i,j) = SinPhi;
            Givens(j,i) = -SinPhi;
            % apply Givens Rotation to R
            R = Givens * R; 
            % apply Givens Rotation to d
            d = Givens * d;
        end
    end
end

if M == K_2             % this is observation
    R = R(1:M,1:M);     % get size M x M
    d = d(1:M);         % get size M x 1
end

% rounding numbers for R 
R = R .* 1e10;
R = round(R);
R = R ./ 1e10;

end