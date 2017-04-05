function [A, b, x] = initialize_Abx(Rob0, Rob1, Rob2, Rob3, NumofRobot)
%%
% This function initalizes the adjancy matrix A and residual vector b
% INPUT:  Number of robots to simulate
% OUTPUT: Initialized A and b
%   size of A: 3*NumofRobot*2 x 3*NumofRobot*2 
%   size of b: 3*NumofRobot x 1
%   size of x: 3*NumofRobot x 2 
%           with the first column is the anchor
%           with the second column to be the initial state
%
%% initialize A
A = zeros(3*NumofRobot,3*NumofRobot);
% give the initial state a very low covriance.
Wini = chol(inv([10e-7,0,0;0,10e-7,0;0,0,10e-7]));
% fill A
for i = 1:NumofRobot*2
    A(3*(i-1)+1:3*(i-1)+3,3*(i-1)+1:3*(i-1)+3) =  -Wini*eye(3);
end

%% initialize b (residual vector)
b = zeros(3*NumofRobot*2,1); 

%% initialize the state vector
x = zeros(3*NumofRobot,2); 

% initalize the anchors :: 4 robots!!!
anchorRob0 = [150;0;0];
anchorRob1 = [150;0;0];
anchorRob2 = [150;0;0];
anchorRob3 = [150;0;0];
anchor = [anchorRob0;anchorRob1;anchorRob2;anchorRob3];

% initialize the states !!
for i = 1:NumofRobot
    x(3*(i-1)+1:3*(i-1)+3,1) = anchor(3*(i-1)+1:3*(i-1)+3);
    x(3*(i-1)+1:3*(i-1)+3,2) = [0;0;0];
end

end