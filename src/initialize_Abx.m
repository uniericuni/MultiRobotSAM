function [A, b, x] = initialize_Abx()
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

global INFO;
NumofRobot = INFO.N;

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

anchor = [];
%{
for n=1:NumofRobot
    anchorRob = [INFO.mapSize; INFO.mapSize; 0];
    anchor = [anchor; anchorRob];
end

% initialize the states !!
for i = 1:NumofRobot
    x(3*(i-1)+1:3*(i-1)+3,1) = anchor(3*(i-1)+1:3*(i-1)+3);
    x(3*(i-1)+1:3*(i-1)+3,2) = [INFO.mapSize; INFO.mapSize; 0];
end
%}

end