% ==================================================================
% EECS568
%
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
% ==================================================================

% =====================
% Initialization
% =====================
close all;
clear;
clc;

% Initialize globals
global INFO;                            % experiment configuration, should not be updated
global PARAM;                           % global variables, should be updated

% INFO
INFO.grid_size = 0.2;                   % gird size for grid map
INFO.mapSize = 140 * 1/INFO.grid_size;  % grid map size
INFO.robs = readData();                 % robot data
INFO.N = length(INFO.robs);             % robot number

% PARAM
PARAM.map = zeros(INFO.mapSize*2,...    % grid map
                  INFO.mapSize*2,3);   
PARAM.pose_id = ones(1,INFO.N);         % current pose id for each robot
PARAM.laser_id = ones(1,INFO.N);        % current laser(sensor) id for each robot

% initialize A,b,x
[A, b, x] = initialize_Abx();

% =====================
% Main Loop
% =====================
whlie true

    % parsing controls and observation
    [rob_id, controls, observation] = parser();

    % factorize for each period
    
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
