function [neg_local_map,local_map] = extractContours(observations, pred_pose)
% =========================================================================
% extracContours():
%   connect observations to piece-wise lines local map
%
% inputs:
%   observations: array contain columns of singel laser observation
%   
% outputs:
%   local_map: N-by-N array contain binary state as occupancy
%   
% =========================================================================

% initialize global variables
global INFO;
global PARAM;
o_num = size(observations, 2);
H = MinHeap(o_num);

% initiate local map
local_map = zeros(size(PARAM.map(:,:,1)));
neg_local_map = local_map;

% observations to points
points = [];
neg_points = [];
for i=1:o_num

    range = observations(1,i);
    bearing = observations(2,i);
    % TODO: add predicted positino  
    point = [ range*cos(bearing+pred_pose(3)) + pred_pose(1); ... 
              range*sin(bearing+pred_pose(3)) + pred_pose(2)];
    if observations(3,i)==0
        neg_points = [neg_points, point];
    else
        points = [points, point];
    end

end

% mark negative points

for i=1:length(neg_points)
    neg_local_map = drawline(neg_local_map, neg_points(:,i), pred_pose(1:2), 1);
end

% iteratively update contours
%{
for i=1:size(points,2)
    local_map = drawline(local_map, points(:,i), points(:,i), 1);
end
%}
o_num = size(points, 2);
isMarked = HashTable(o_num);

if o_num~=0
    
    point = points(:,:,1);
    isMarked.Add(num2str(1), true);
    while ~isMarked.Count()<o_num
    
        min_id = 0;
        min_dist = Inf;
        for j=1:o_num
        
            if isMarked.ContainsKey(num2str(j))
                continue
            end
        
            dist = norm(point - points(:,j));
        
            if dist<min_dist
                min_dist = dist;
                min_id = j;
            end
        
        end
    
        if min_id==0
            break;
        elseif min_dist <= INFO.COST_MAX
            local_map = drawline(local_map, point, points(:,min_id), 1);
        end
    
        point = points(:,min_id);
        isMarked.Add(num2str(min_id), true);
    end
end


end