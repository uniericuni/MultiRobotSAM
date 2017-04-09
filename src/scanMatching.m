function scanMatching(observations, pred_pose)
% =========================================================================
% scanMatching():
%   matching the observational local map to current global map and make
%   corrections
%
% inputs:
%   observations: array contain columns of singel laser observation
%   pred_pose: predicted current pose, used as a hueristic to speed up
%   exhuastive search
%
% outputs:
%   
% =========================================================================


% init globals
global INFO;                            % experiment configuration, should not be updated
global PARAM;                           % global variables, should be updated

local_map = extractControus(observations, pred_pose);
local_map = propogateGauss(local_map);
[map, delta_] = alignment(local_map, PARAM.map);
PARAM.map(:,:,1) = PARAM.map(:,:,1) + map;


