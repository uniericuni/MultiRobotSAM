function [R,d] = releaseBuffer(R,d)

% global initiate
global PARAM;
global INFO;

for i=1:PARAM.buff_size
    
    % if the local map overlapped
    l_map = PARAM.local_buff.map;
    g_map = PARAM.obs_buff{PARAM.buff_size}.map;
    mex = l_map.*g_map;
    mex2 = l_map+g_map;
    if nnz(mex)/nnz(mex2) > 0.68
        delta_ = alignment(l_map, g_map);
        [R,d] = augument_R_obs( R,...
                                d,...
                                [PARAM.local_buff.pose_col, ...
                                PARAM.obs_buff{PARAM.buff_size}.pose_col], ...
                                [PARAM.local_buff.robot_id, ...
                                PARAM.obs_buff{PARAM.buff_size}.robot_id], ...
                                delta_);
    end
    
end

% merge with global map
g_map = PARAM.map;
l_map = PARAM.local_buff.map;
g_map(g_map==0) = l_map(g_map==0);
g_map(g_map>0) = max(g_map(g_map>0),l_map(g_map>0));
g_map(g_map<0) = min(g_map(g_map<0),l_map(g_map<0));

%% 
PARAM.map = g_map;

% push local buffer to global buffer
PARAM.buff_size = PARAM.buff_size+1;
if PARAM.buff_size > INFO.GLOBAL_BUFF_SIZE
    PARAM.obs_buff{1:end-1} = PARAM.obs_buff{2:end};
    PARAM.buff_size = PARAM.buff_size - 1;
end
obs = PARAM.local_buff;
obs.map = PARAM.map;
PARAM.obs_buff{PARAM.buff_size} = obs;
PARAM.local_buff.map = zeros(INFO.mapSize*2+1,... 
                             INFO.mapSize*2+1);
PARAM.local_buff.pose_col = 0;
PARAM.local_buff.robot_id = 0;
