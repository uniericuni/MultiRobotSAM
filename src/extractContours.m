function local_map = extractContours(observations)
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
localMap = {};

% initiate local map
local_map = zeros(INFO.mapSize*2,...
                  INFO.mapSize*2); 
init_pos = [INFO.mapSize; INFO.mapSize];

% observations to points
points = [];
for i=1:o_num

    range = observations(1,i);
    bearing = observations(2,i);
    % TODO: add predicted positino  
    point = [range*cos(bearing); range*sin(bearing)];
    points = [points, point];

end

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

% iteratively update contours
isMarked = HashTable(o_num);
while ~H.IsEmpty()
    
    obs = H.ExtractMin();
    isMarked.Add(num2str(parents(obs.index)), true);        % set parent as marked
    if isMarked.ContainsKey(num2str(children(obs.index)))   % if child has been observed, in avoidance of loop
        continue;
    elseif obs.val > INFO.COST_MAX                          % if cost too large
        continue;
    else
        local_map = drawline(local_map, points(parents(obs.index)), points(chilredn(obs.index)));
    end    
    
end

end