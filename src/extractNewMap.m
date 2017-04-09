function obs = extractNewMap(observation, pred_pose, pose_col, robot_id)

global PARAM;
global INFO;

% extract new local map
[n_map,map] = extractContours(observation, pred_pose);

% propogate likelihood
n_map = propogateGauss(n_map);
map = propogateGauss(map);

% merge with global map
map_temp = PARAM.local_buff;
map_temp(n_map>0) = min(map_temp(n_map>0), -1*n_map(n_map>0));
map_temp(map>0) = max(map_temp(map>0), map(map>0));
obs.map = map_temp;
obs.pose_col = pose_col;
obs.robot_id = robot_id;

end