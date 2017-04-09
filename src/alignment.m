function [total_cost,delta_] = alignment(local_map, global_map, pred_pose)
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

    % gradient ascent
    % TODO
    
    % specify warping output field
    [X,Y] = size(local_map);
    Rin = imref2d([X,Y]);
    Rin.XWorldLimits = Rin.XWorldLimits-mean(Rin.XWorldLimits);
    Rin.YWorldLimits = Rin.YWorldLimits-mean(Rin.YWorldLimits);
    total_cost = zeros([11,11,359]);
    
    % exhuastive search
    delta_ = [];
    min_cost = Inf;
    for i=-180:2:178                                          % rotation
        
        % rotation around center and crop to original size
        theta = deg2rad(i);
        t = [ cos(theta), -sin(theta), 0;
             sin(theta), cos(theta), 0;
                       0,          0, 1];
        tform = affine2d(t');
        local_map_r = imwarp(local_map, Rin, tform, 'OutPutView', Rin);
        
        tic;
        for j=-5:1:5                                          % x translation
            for k=-5:1:5                                      % y translation
                
                x = j+pred_pose(1);
                y = -1*(k+pred_pose(2));
                t = [ 1, 0, j+pred_pose(1);
                      0, 1, k+pred_pose(2);
                      0, 0, 1];
                tform = affine2d(t');
                local_map_rt = imwarp(local_map_r, Rin, tform, 'OutPutView', Rin);
                
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
        toc;
    end