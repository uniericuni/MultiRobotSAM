function [map, delta_] = alignment(local_map, map, pred_pose)

    min_cost = Inf;
    delta_ = [];
    for i=-180:0.5:180                                          % rotation

        theta = deg2rad(i)+pred_pose(3);
        tform = affine2d( [ cos(theta),-sin(theta), 0;
                            sin(theta), cos(theta), 0;
                                     0,          0, 1] );
        local_map_r = imwarp(local_map, tform);
        for j=-20:1:20                                          % x translation
            for k=-20:1:20                                      % y translation
                tform = affine2d( [ 1, 0, j+pred_pose(1);
                                    0, 1, k+pred_pose(2);
                                    0, 0, 1] );
                local_map_rt = imwarp(local_map_r, tform);
                mask = (local_map_rt~=0);        
                cost = norm((map-local_map_rt).*mask);
                if cost<min_cost                                % minimization
                    min_cost = cost;
                    delta_ = [i;j;k;];
                end
            end
        end
    end