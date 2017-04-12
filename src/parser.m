function [robs_id, controls, poses, state, observations, time] = parser()
% =========================================================================
% parser()
%   parsing all control commands before one observatoin
%
% outputs:
%   robs_id: vector of robot id, the nth id is cooresponding to the nth
%            control while the last to observation
%   controls: array, each column is one control command
%   observations: array, each column is one observation while all observe
%                 at the same time
% =========================================================================

% initialize global variables
global INFO;
global PARAM;
N = INFO.N;
robs = INFO.robs;
pose_id = PARAM.pose_id;
laser_id = PARAM.laser_id;

% initialize local variables
robs_id = [];
poses = [];
controls = [];
observations = [];
states = [];
time = [];
observed = false;

% parsing controls and observations to output queue
while ~observed
    
    min_t = Inf;
    min_rob = 0;
    
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

        % parse id and poses
        rob_id = min_rob/2;
        pose = robs{rob_id}.pose{pose_id(rob_id)};
        if pose_id(rob_id)>1
            prev_pose = robs{rob_id}.pose{pose_id(rob_id)-1};
        else
            prev_pose =  robs{rob_id}.pose{pose_id(rob_id)};
        end
        time = [time,...
                robs{rob_id}.pose{pose_id(rob_id)+1}.time-robs{rob_id}.pose{pose_id(rob_id)}.time];
        
        pose_id(rob_id) = pose_id(rob_id)+1;
        poses = [poses, pose_id];
        
        % detemine control
        control = [ sqrt((pose.x-prev_pose.x)^2+...
                        (pose.y-prev_pose.y)^2);...
                        (pose.theta-prev_pose.theta) ];
        
        if control(1)==0 && control(2)==0  % zeros pruning
            %PARAM.prev_time(1,rob_id) = pose.time;
        else
            robs_id = [robs_id,rob_id];
            %time = [time, pose.time - PARAM.prev_time(1,rob_id)];
            controls = [controls, control./time(end)];
            %PARAM.prev_time(1,rob_id) = pose.time;
        end

    else

        % parse id and poses
        rob_id = (min_rob+1)/2;
        robs_id = [robs_id,rob_id];

        % determine state
        pose = robs{rob_id}.pose{pose_id(rob_id)};
        state = [pose.x; pose.y; pose.theta];
        
        % detemine observation
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

end