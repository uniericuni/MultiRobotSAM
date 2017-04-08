function map = propogateGauss(map)

h = fspecial('gaussian', 3, 0.5);
map_g = conv2(map, h);
map = max(map_g, map);