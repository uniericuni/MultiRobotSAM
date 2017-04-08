function [ map ] = drawline(map,point1,point2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
global INFO;                            % experiment configuration, should not be updated
global PARAM;

[ny,nx] = size(map);
origin_x = round(nx/2) + 1;
origin_y = round(ny/2) ;

p = 1;

if ( point1(2) <= point2(2))
    x1 = point1(1);
    y1 = point1(2);
    x2 = point2(1);
    y2 = point2(2);
else
    x1 = point2(1);
    y1 = point2(2);
    x2 = point1(1);
    y2 = point1(2);
end

if x1 == x2
    nx = floor(x1/INFO.grid_size);
    n_y1 = floor((y1)/INFO.grid_size);
    n_y2 = floor((y2)/INFO.grid_size);ter
    n_sy = min(n_y1,n_y2);
    n_ey = max(n_y1,n_y2);
    for i = n_sy:n_ey
        map(origin_y - i, origin_x + nx) = map(origin_y - i, origin_x + nx) + p;
    end
elseif y1 ==y2
    ny = floor(x1/INFO.grid_size);
    n_x1 = floor((x1)/INFO.grid_size);
    n_x2 = floor((x2)/INFO.grid_size);
    n_sx = min(n_x1,n_x2);
    n_ex = max(n_x1,n_x2);
    for i = n_sx:n_ex
        map(origin_y - ny, origin_x + i) = map(origin_y - ny, origin_x + i) + p;
    end
else
    if x1 <= x2
        min_x = floor(x1/INFO.grid_size)*INFO.grid_size;
        max_x = ceil(x2/INFO.grid_size)*INFO.grid_size;
        
        for i = min_x : INFO.grid_size :max_x - INFO.grid_size
            k = (y2-y1)/(x2-x1);
            sx = max(x1,i);
            ex = min(x2,i + INFO.grid_size);
            nx = floor(sx/INFO.grid_size);
            s_ny = floor((k*(sx-x1) + y1)/INFO.grid_size);
            e_ny = floor((k*(ex-x1) + y1)/INFO.grid_size);
            if (mod((k*(ex-x1) + y1),INFO.grid_size) == 0)
                e_ny = e_ny - 1;
            end
            for j = s_ny:e_ny
                map(origin_y - j, origin_x + nx) = map(origin_y - j, origin_x + nx) + p;
            end
        end
    else
        min_x = floor(x2/INFO.grid_size)*INFO.grid_size;
        max_x = ceil(x1/INFO.grid_size)*INFO.grid_size;
        
        for i = min_x : INFO.grid_size :max_x - INFO.grid_size
            k = (y1-y2)/(x1-x2);
            sx = max(x2,i);
            ex = min(x1,i + INFO.grid_size);
            nx = floor(sx/INFO.grid_size);
            s_ny = floor((k*(sx-x2) + y2)/INFO.grid_size);
            if (mod((k*(sx-x2) + y2),INFO.grid_size) == 0)
                s_ny = s_ny - 1;
            end
            e_ny = floor((k*(ex-x2) + y2)/INFO.grid_size);
            for j = s_ny:e_ny
                map(origin_y - j, origin_x + nx) = map(origin_y - j, origin_x + nx) + p;
            end
        end
    end
end

end

