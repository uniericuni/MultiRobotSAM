function [ local_map ] = creat_localmap( local_state, observation )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% observation.bearing range intensity
% local_state 1.x 2.y 3.theta

% Initialize globals
global INFO;                            % experiment configuration, should not be updated
global PARAM;                           % global variables, should be updated

assert(length(observation.bearing) == length(observation.range));
assert(length(observation.bearing) == length(observation.intensity));

alpha = INFO.grid_size;

%[ind] = find(observation.intensity > 0);
bearing = observation.bearing + local_state(3);
%bearing = bearing
range = observation.range;
intensity = observation.intensity;

%range
x = zeros(1,length(range));
y = zeros(1,length(range));

for i = 1:length(range)
    x(i) = range(i)*cos(bearing(i));
    y(i) = range(i)*sin(bearing(i));
end

max_x = max(abs(x));
max_y = max(abs(y));
nx = ceil(max_x/INFO.grid_size) + 1;
ny = ceil(max_y/INFO.grid_size) + 1;

local_map = zeros(2*ny+1,2*nx+1);

origin_x = nx + 1;
origin_y = ny + 1;

for i = 1:length(range)
    if intensity(i) > 0 %observation
        local_x = origin_x + round(x(i)/INFO.grid_size);
        local_y = origin_y + round(y(i)/INFO.grid_size);
        switch intensity(i)
            case 1
                p = 0.2;
            case 2
                p = 0.4;
            case 3
                p = 0.6;
            case 4
                p = 0.8;
            case 5
                p = 1;
        end
        for j = local_y - 1 : local_y + 1
            for k = local_x - 1 : local_x + 1
                d = INFO.grid_size*sqrt((j-origin_y)^2 + (k - origin_x)^2);
                if d > alpha/2
                    local_map(j,k) = local_map(j,k) + p;
                end
            end
        end
    else %no observation
        step = abs(round(x(i)/INFO.grid_size));
        k = tan(bearing(i));
        y1 = min(round(1/2*k),round(step*k));
        range_y=[min(0,y1):max(0,y1)];
        for j = 1:length(range_y)
            local_map(origin_y-range_y(j),origin_x) = local_map(origin_y-range_y(j),origin_x) - 0.5;
        end
        if (i == 49)
            xx=1;
        end
        for j = 1:step-1
            y1 = min(round(k*(j+0.5)),round(k*step));
            y2 = round(k*(j-0.5));
            range_y = [min(y1,y2):max(y1,y2)];
            for k = 1:length(range_y)
                local_map(origin_y-range_y(k),origin_x + j) = local_map(origin_y-range_y(k),origin_x+j) - 0.5;
            end
        end
        
        %%last range
        if step >= 1
            j = step;
            y1 = round(k*j);
            y2 = round(k*(j-0.5));
            range_y = [min(y1,y2):max(y1,y2)];
            for k = 1:length(range_y)
                local_map(origin_y-range_y(k),origin_x + j) = local_map(origin_y-range_y(k),origin_x+j) - 0.5;
            end
        end
    end
end
end
