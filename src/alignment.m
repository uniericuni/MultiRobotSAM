function [delta_] = alignment(l_map, g_map)
% =========================================================================
% alignment():
%   search for best alignment along the global map
%
% inputs:
%   local_map: N-by-N array contain likelihood state as occupancy
%   global_map: N-by-N array contain binary state as occupancy
%   pred_pose: predicted current pose, used as a hueristic to speed up
%   exhuastive search
%
% outputs:
%   map: N-by-N array contain likelihood as global map
%   delta_: optimal transformation for alignment
%   
% =========================================================================

    % global initiate
    global PARAM;
    global INFO;
        
    % proccessed to piecewise line walls
    l_map(l_map>0) = 1; l_map(l_map<0) = -1;
    g_map(g_map>0) = 1; g_map(g_map<0) = -1;
    hp = [0, -1/4, 0; -1/4, 2, -1/4; 0, -1/4, 0];
    l_map = conv2(l_map, hp, 'same');
    g_map = conv2(g_map, hp, 'same');
    l_map(l_map>0) = 1; l_map(l_map<0) = -1;
    g_map(g_map>0) = 1; g_map(g_map<0) = -1;
    global_map = g_map;
    local_map = l_map;
    
    % specify warping output field
    [X,Y] = size(local_map);
    Rin = imref2d([X,Y]);
    Rin.XWorldLimits = Rin.XWorldLimits-mean(Rin.XWorldLimits);
    Rin.YWorldLimits = Rin.YWorldLimits-mean(Rin.YWorldLimits);
    total_cost = zeros([11,11,359]);
    
    % exhuastive search
    delta_ = [];
    min_cost = Inf;
    for i=-90:1:90                                          % rotation
        
        % rotation around center and crop to original size
        theta = deg2rad(i);
        t = [ cos(theta), -sin(theta), 0;
             sin(theta), cos(theta), 0;
                       0,          0, 1];
        tform = affine2d(t');
        local_map_r = imwarp(local_map, Rin, tform, 'OutPutView', Rin);
        
        for j=-8:2:8                                            % x translation
            for k=-8:2:8                                        % y translation
                
                x = j+pred_pose(1);
                y = -1*(k+pred_pose(2));
                %{
                t = [ 1, 0, j+pred_pose(1);
                      0, 1, k+pred_pose(2);
                      0, 0, 1];
                tform = affine2d(t');
                local_map_rt = imwarp(local_map_r, Rin, tform, 'OutPutView', Rin);
                %}
                
                if y>=0
                    Y_MIN1 = y+1; Y_MAX1 = Y; 
                    Y_MIN2 = 1;   Y_MAX2 = Y-y;
                else
                    Y_MIN1 = 1;   Y_MAX1 = Y+y;
                    Y_MIN2 = -y+1; Y_MAX2 = Y; 
                end
                if x>=0
                    X_MIN1 = x+1; X_MAX1 = X;
                    X_MIN2 = 1;   X_MAX2 = X-x;
                else
                    X_MIN1 = 1;   X_MAX1 = X+x;
                    X_MIN2 = -x+1;   X_MAX2 = X;
                end
                
                cost = norm(imabsdiff(local_map_rt(X_MIN1:X_MAX1, Y_MIN1:Y_MAX1),...
                                      global_map(X_MIN2:X_MAX2, Y_MIN2:Y_MAX2)));
                total_cost(j+6,k+6,i+181) = cost;
                                     
                if cost<min_cost                                % minimization
                    min_cost = cost;
                    delta_ = [i;j;k];
                end

            end
        end
        
        % transform to align
        %{
        theta = deg2rad(delta_(1));
        t = [ cos(theta), -sin(theta), delta_(2)+pred_pose(1);
              sin(theta), cos(theta),  delta_(3)+pred_pose(2);
                       0,          0,                       1];
        tform = affine2d(t');
        map = imwarp(local_map, Rin, tform, 'OutPutView', Rin);
        %}
    end