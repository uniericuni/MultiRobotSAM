function [R,d] = augument_R_obs(R,d,col_id,rob_id,c)
%R augumentation for obsercvation
%Input: R : original R
%       d : original d
%       col_id : involve two state column id elements
%                   1. pose doing the observation
%                   2. pose being observed
%       rob_id : invole two robot id elements
%                   1. robot doing the observation
%                   2. robot being observed
%       c : observation residue

global INFO;

c_i = col_id(1);
c_j = col_id(2);
r_i = rob_id(1);
r_j = rob_id(2);

w = inv((INFO.Q')^0.5);
[R_r,R_c] = size(R);
augument_R = zeros(3,R_c);
Hi = eye(3);
Hj = -eye(3);
augument_R(1:3,3*r_i-2:3*r_i) = w*Hi;%anchor
augument_R(1:3,3*r_j-2:3*r_j) = w*Hj;%anchor
augument_R(1:3,12*c_i-12+3*r_i-2:12*c_i-12+3*r_i)=w*Hi;%observation
augument_R(1:3,12*c_j-12+3*r_j-2:12*c_j-12+3*r_j)=w*Hj;
lamda = w*c;
R = sparse(R);
[R, d] = Givens_Rotation(R, d, augument_R, lamda);
R = sparse(R);
end

