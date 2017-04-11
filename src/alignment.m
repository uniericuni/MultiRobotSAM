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
    g_map = g_map;
    l_map = l_map;
    
    % search for bounding box
    for x_min=1:size(l_map,2)
        if nnz(g_map(:,x_min))~=0 || nnz(l_map(:,x_min))~=0
            break;
        end
    end
    for x_max=size(l_map,2):-1:1
        if nnz(g_map(:,x_max))~=0 || nnz(l_map(:,x_max))~=0
            break;
        end
    end
    for y_min=1:size(l_map,1)
        if nnz(g_map(y_min,:))~=0 || nnz(l_map(y_min,:))~=0
            break;
        end
    end
    for y_max=size(l_map,1):-1:1
        if nnz(g_map(y_max,:))~=0 || nnz(l_map(y_max,:))~=0
            break;
        end
    end
    local_map = l_map(y_min:y_max,x_min:x_max);
    global_map = g_map(y_min:y_max,x_min:x_max);
    
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
        t = [ cos(theta), sin(theta), 0;
             -sin(theta), cos(theta), 0;
                       0,          0, 1];
        tform = affine2d(t');
        local_map_rt = imwarp(local_map, Rin, tform, 'OutPutView', Rin);
        costs = [];
        for j=-8:2:8                                            % x translation
            for k=-8:2:8                                        % y translation
                
                x = j;
                y = -k;
                
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
                costs = [costs, cost];
                %total_cost(j+6,k+6,i+181) = cost;
                                     
                if cost<min_cost                                % minimization
                    min_cost = cost;
                    delta_ = [i;j;-k];
                end

            end
        end
        
    end
    %{
    % convert local solution to global
    V = [-INFO.mapSize; INFO.mapSize] + [(x_min+x_max)/2; -(y_min+y_max)/2];
    V_delta = -delta_(2:3,:);
    theta_delta = -deg2rad(delta_(1));
    R = [cos(theta_delta), -sin(theta_delta);
         sin(theta_delta),  cos(theta_delta)];
    V-V_delta- R*V;
    %}