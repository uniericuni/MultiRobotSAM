function x = optimize( R, d, x )
%%
% This function optimze all the current states
% INPUT:  x: state matrix       , size 3N x T
%         R: R matrix           , size 3N*T x 3N*T
%         d: residual vector    , size 3N*T x 1
% OUTPUT: x: state matrix after optimization
%%
% find size
TNT = size(R,1); % TNT equals to 3N*T
TN = size(x,1); % TN equals to 3N

% convert R to sparse matrix
% R is an upper triangular matrix
R = sparse(R);

% back-substitution
dx = zeros(TNT,1);
dx(TNT)=d(TNT)/R(TNT,TNT);
for i=TNT-1:-1:1
   dx(i)=(d(i)-R(i,i+1:TNT)*dx(i+1:TNT))/R(i,i);
end 

% update the solution
x_new = zeros(size(x));
for t = 1:size(x,2)
    x_new(:,t) = x(:,t) + dx(t*TN-(TN-1):t*TN);  
    x_new(3:3:end,t) = wrapToPi( x_new(3:3:end,t) );
end

end