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
INFO.COST_MAX = Inf;                    % minimum acceptable score for contour

% PARAM
PARAM.map = zeros(INFO.mapSize*2+1,...  % grid map
                  INFO.mapSize*2+1,3);   
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
c=0;
while true

    c=c+1;

    % parsing controls and observation
    [rob_id, controls, observation, time] = parser();   
    if size(controls,2)==0 || c==1
        continue;
    end
    
    x = update_state(x,controls,rob_id, time );
    map = extractContours(observation, x(3*rob_id(end,1)-2:3*rob_id(end,1)));
    PARAM.map(:,:,1) = max(map, PARAM.map(:,:,1));
    fprintf(['iteration: ', num2str(c), '\n']);

end