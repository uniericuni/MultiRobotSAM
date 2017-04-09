function extractNewMap(observation, pred_pose)

global PARAM;
global INFO;
    
% extract new local map
[n_map,map] = extractContours(observation, pred_pose);

% propogate likelihood
n_map = propogateGauss(n_map);
map = propogateGauss(map);

% merge with global map
map_temp = PARAM.map(:,:,1);
map_temp(n_map>0) = min(map_temp(n_map>0), -1*n_map(n_map>0));
map_temp(map>0) = max(map_temp(map>0), map(map>0));
PARAM.map(:,:,1) = map_temp;
    
end