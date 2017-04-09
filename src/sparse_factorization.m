function [R,d] = sparse_factorization( A,b )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    As = sparse(A);
    [Q,R] = qr(As);
    bb = Q'*b;
    d = bb(1:length(R));
end
