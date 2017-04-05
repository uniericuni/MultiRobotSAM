function [robs_id, controls, observations] = parser()
% parser()
%   parsing all control commands before one observatoin
%
% outputs:
%   robs_id: vector of robot id, the nth id is cooresponding to the nth
%            control while the last to observation
%   controls: array, each column is one control command
%   observations: array, each column is one observation while all observe
%                 at the same time

% initialize global variables
global INFO;
global PARAM;
N = INFO.N;
robs = INFO.robs;
pose_id = PARAM.pose_id;
laser_id = PARAM.laser_id;

% initialize local variables
robs_id = [];
controls = [];
observations = [];
observed = false;

% parsing controls and observations to output queue
while ~observed
    
    min_t = Inf;
    min_rob = 0;
    
    % TODO: adopt priority queue
    % update priority queue
    for n=1:N*2
        
        % if control, else sensor
        if mod(n,2)==0
            rob_id = n/2;
            t = robs{rob_id}.pose{pose_id(rob_id)}.time;
        else
            rob_id = (n+1)/2;
            t = robs{rob_id}.laser{laser_id(rob_id)}.time;
        end
        
        % compare
        if t < min_t
            min_t = t;
            min_rob = n;
        end

    end
    
    % update control/observation queue
    if mod(min_rob,2)==0
        rob_id = min_rob/2;
        robs_id = [robs_id,rob_id];
        pose = robs{rob_id}.pose{pose_id(rob_id)};
        pose_id(rob_id) = pose_id(rob_id)+1;
        control = [pose.vel_x; pose.vel_y; pose.vel_theta];
        controls = [controls, control];
    else
        rob_id = (min_rob+1)/2;
        robs_id = [robs_id,rob_id];
        lasers = robs{rob_id}.laser{laser_id(rob_id)};
        laser_id(rob_id) = laser_id(rob_id)+1;
        for k=1:length(lasers)
            obs = [lasers.bearing; lasers.range; lasers.intensity];
            observations = [observations obs];
        end
        observed = true;
    end

end

% update control/observation index
PARAM.pose_id = pose_id;
PARAM.laser_id = laser_id;