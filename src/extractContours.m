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
o_num = size(points, 2);

% parse joins into priority queue
parents = zeros(o_num,1);	% store point index
children = zeros(o_num,1);
for i=1:o_num

    % search for nearest neighbor
    parents(i) = i;
    min_dist = Inf;
    min_index = 0;
    for j=1:o_num
        dist = norm(points(:,i) - points(:,j));
        if min_dist>dist && parents(j)~=i
            min_dist = dist;
            min_index = j;
        end
    end
    
    % making join struct
    obs = struct();
    obs.index = i;          % parent/child pair index
    obs.val = min_dist;
    children(i) = min_index;
    
    % throw into priority queue
    H.InsertKey(obs);

end

% mark negative points

for i=1:length(neg_points)
    neg_local_map = drawline(neg_local_map, neg_points(:,i), pred_pose(1:2), 1);
end

% iteratively update contours

isMarked = HashTable(o_num);
while ~H.IsEmpty()
    
    obs = H.ExtractMin();
    isMarked.Add(num2str(parents(obs.index)), true);        % set parent as marked
    if isMarked.ContainsKey(num2str(children(obs.index)))   % if child has been observed, in avoidance of loop
        continue;
    elseif obs.val > INFO.COST_MAX                          % if cost too large
        continue;
    elseif children(obs.index) == 0                         % if no parents
        continue;
    else
        local_map = drawline(local_map, points(:,parents(obs.index)), points(:,children(obs.index)), 1);
    end    
    
end

end