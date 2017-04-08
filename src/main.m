% ==================================================================
% EECS568
%
% H_MAP, W_MAP: height and width of maps
% UPDATE_PERIOD: perioud of A update
% N: number of robots
% T: total step number
% A: adjacency matrix
% b: residual vector, 3N*(t+2) x 1
% x: state matrix, 3N x (t+2)
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
addpath('../lib');                      % add data structure library

% INFO
INFO.grid_size = 0.2;                   % gird size for grid map
INFO.mapSize = 140 * 1/INFO.grid_size;  % grid map size
INFO.robs = readData();                 % robot data
INFO.N = length(INFO.robs);             % robot number
INFO.SCORE_MAX = Inf;                   % minimum acceptable score for contour

% PARAM
PARAM.map = zeros(INFO.mapSize*2,...    % grid map
                  INFO.mapSize*2,3);   
PARAM.pose_id = ones(1,INFO.N);         % current pose id for each robot
PARAM.laser_id = ones(1,INFO.N);        % current laser(sensor) id for each robot
PARAM.prev_time = 0;                    % time of previous state

% initialize A,b,x
[A, b, x] = initialize_Abx();

mega_obs = [];
mega_robidControl = [];
mega_robidObs = [];
mega_controls = [];
% =====================
% Main Loop
% =====================
while true

    % parsing controls and observation
<<<<<<< HEAD
    [rob_id, controls, observation] = parser();
<<<<<<< HEAD
    if size(contorls,2)==0
        continue;
    end
    
    % augment to mega_obs, mega_control, mega_robid
    mega_robidObs = [mega_robidObs, rob_id(end)];
    mega_obs = [mega_obs, observation];
    mega_robidControl = [mega_robidControl, rob_id(1,end-1)];
    mega_controls = [mega_controls, controls];
    % factorize for each period
    if mod(t,UPDATE_PERIOD)==0
        [R,d] = factorize(x, mega_robidObs, mega_obs, mega_robidControl, mega_controls);
    end
=======
=======
    [rob_id, controls, observation, time] = parser();
>>>>>>> e1655b494c66aaeb5314a5d38ff7c0c4fac2f843

    % factorize for each period
>>>>>>> 740ef26fa941194f7c0892756fd3a64aaf9adb5d
    
    % read control
    u = control(t);
    
    % read observation
    z = observation(t);
    
    % update, augment state
    [x,R] = update(R, controls);
    
    % scanmatching
    [R,b] = scanmatch(x, map, z);
    
    % optimization
    [R,b] = optimize(R,b);
<<<<<<< HEAD
=======

>>>>>>> e1655b494c66aaeb5314a5d38ff7c0c4fac2f843
end
 
