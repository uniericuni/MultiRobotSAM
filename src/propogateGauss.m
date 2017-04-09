function map = propogateGauss(map)
% =========================================================================
% propogateGauss():
%   propogate binary local map to potential field likelihood map
%
% inputs:
%   map: N-by-N array contain binary state as occupancy
%
% outputs:
%   map: N-by-N array contain likelihood as local map
%   
% =========================================================================

% propogate likelihood
ksize = 5;
sigma = ksize/6;
h = fspecial('gaussian', ksize, sigma);
map_g = conv2(map, h, 'same');
map = max(map_g, map);

