function [R,d] = releaseBuffer(R,d)

% global initiate
global PARAM;
global INFO;

% scanmatching
%{
for i=1:PARAM.buff_size
    
    % if the local map overlapped
    l_map = PARAM.local_buff.map;
    g_map = PARAM.obs_buff{PARAM.buff_size}.map;
    mex = l_map .* g_map;
    if sum(sum(mex(mex~=0))) > 20
        delta_ = alignment(l_map, g_map);
            ...R,d,col_id,rob_id,c)
        [R,d] = augument_R_obs( R,...
                                d,...
                               [PARAM.local_buff.pose_col, ...
                                PARAM.obs_buff{PARAM.buff_size}.pose_col], ...
                               [PARAM.local_buff.robot_id, ...
                                PARAM.obs_buff{PARAM.buff_size}.robot_id]);
    end
    
end
%}
% merge global map


% push local buffer to global buffer
PARAM.buff_size = PARAM.buff_size+1;
if PARAM.buff_size > INFO.GLOBAL_BUFF_SIZE
    PARAM.obs_buff{1:end-1} = PARAM.obs_buff{2:end};
    PARAM.buff_size = PARAM.buff_size - 1;
end
PARAM.obs_buff{PARAM.buff_size} = PARAM.local_buff;
PARAM.local_buff.map = PARAM.map(:,:);              % create local buffer
PARAM.local_buff.pose_col = 0;
PARAM.local_buff.robot_id = 0;
PARAM.buff_size = 0;