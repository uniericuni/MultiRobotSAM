function scanMatching(observations)

% init globals
global INFO;                            % experiment configuration, should not be updated
global PARAM;                           % global variables, should be updated

local_map = extractControus(observations);
local_map = propogateGauss(local_map);
[PARAM.map, delta_] = alignment(local_map, PARAM.map);

