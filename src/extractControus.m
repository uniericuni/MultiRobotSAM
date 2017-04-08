function localMap = extractControus(observations)

% initialize global variables
global INFO;
global PARAM;
o_num = size(observations, 4);
H = MinHeap(n);
localMap = {};

% parse joins into priority queue
for i=1:o_num
    
    % search for nearst neighbor
    observation = observations(:,i);
    observation_ = [];
    min_dist = Inf;
    for k=1:o_num
        dist = norm(observation - observations(:,k));
        if min_dist > dist
            min_dist = dist;
            observation_ = observations(:,k);
        end
    end
    
    % making join struct
    obs = struct();
    obs.o1 = observation;
    obs.o2 = observation_;
    obs.score = min_dist;
    
    % throw into priority queue
    H.InsertKey(obs);
    
end

% iteratively update contours
while ~H.isEmpty()
    
    obs = H.ExtractMin();
    if obs.o1 % TODO: already has a child
        continue;
    elseif obs.score > TH
        continue;
    elseif obs.o2 % TODO: already has a parent
        obs = struct();
        obs.o1 = observation;
        obs.o2 = observation_;
        obs.score = min_dist;
        H.InsertKey(obs);
    else
        localMap = {localMap, obs};
    end    
    
end

end