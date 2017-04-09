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
PARAM.prev_time = zeros(1,INFO.N);      % time of previous state
PARAM.prev_pose = zeros(3,INFO.N);      % pose of previous state

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
cc=0;
xs = [];
while true
    
    c=c+1;
    % parsing controls and observation
    [rob_id, controls, state, observation, time] = parser();
    if ~(size(controls,2)==0)
        controls
        time
    end
    %{
    if ~(size(controls,2)==0 || c==1)
        cc = cc+1;
        x = update_state(x,controls,rob_id, time );
        xs = [xs, [state;rob_id(end)]];
        pred_pose = state;
    else
        continue;
    end
    
    
    % merge map
    % pred_pose = xs(3*rob_id(end)-2 : 3*rob_id(end), end);
    [n_map,map] = extractContours(observation, pred_pose);
    %n_map = propogateGauss(n_map);
    %map = propogateGauss(map);
    map_temp = PARAM.map(:,:,1);
    map_temp(n_map>0) = min(map_temp(n_map>0), -1*n_map(n_map>0));
    map_temp(map>0) = max(map_temp(map>0), map(map>0));
    PARAM.map(:,:,1) = map_temp;
    
    if mod(cc,100)==99
        fprintf(['iteration: ', num2str(c), '\n']);
        im = PARAM.map(:,:,1);
        im(im>0)=1;
        im(im<0)=-1;
        imagesc(im);
        pause(0.2);
    end
    %}
    %imagesc(PARAM.map(:,:,1));
    %pause(0.2);
end

