close all;
clear;
clc;

%% main
% H_MAP, W_MAP: height and width of maps
% UPDATE_PERIOD: perioud of A update
% N: number of robots 
% T: total step number
% A: adjacency matrix
% b: residual vector, 3N*(t+1) x 1
% x: state matrix, 3N x (t+1)
% t: current steps
% priors: N*1 float
% init_poses: 3N*1
% map: map, Hx W x 3 | 3: for current likelihood, robot index, step
% control: control signal
% observation: observation signal

[priors, init_poses, control, observation] = readData('');
map = initialize();
[A,b] = initialize();

% main loop
for t=1:T

    % factorize for each period
    if mod(t,UPDATE_PERIOD)==0
        [R,d] = factorize(x,control(1:t),observation(1:t));
    end
    
    % read control
    u = control(t);
    
    % read observation
    z = observation(t);
    
    % update, augment state
    [x,R] = update(x, R, u);
    
    % scanmatching
    [R,b] = scanmatch(x, map, z);
    
    % optimization
    [R,b] = optimize(R,b);
    
end
