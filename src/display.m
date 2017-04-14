
%
FigHandle = figure('Position', [400, 400, 1000, 1000]);
grid_size = 0.2;
last = 1;
X = 200; Y = 200;

%
for i=1:64
    
    %
    l_map = obs_buff{i}.map;
    
    %
    l_map = propogateGauss(l_map);
    l_map(l_map>0) = 1; l_map(l_map<0) = -1;
    hp = [0, -1/4, 0; -1/4, 2, -1/4; 0, -1/4, 0];
    l_map = conv2(l_map, hp, 'same');
    l_map(l_map>0) = 1; l_map(l_map<0) = -1;
    
    %
    hold on;
    imagesc(l_map(700-X:700+X,700-Y:700+Y));
    
    %
    for j=last:obs_buff{i}.pose_col
        n=1; line(X+x(3*n-2,1:j)./grid_size, Y-x(3*n-1,1:j)./grid_size, 'Color','y', 'LineWidth', 1.5);
        n=2; line(X+x(3*n-2,1:j)./grid_size, Y-x(3*n-1,1:j)./grid_size, 'Color','r', 'LineWidth', 1.5);
        n=3; line(X+x(3*n-2,1:j)./grid_size, Y-x(3*n-1,1:j)./grid_size, 'Color','g', 'LineWidth', 1.5);
        n=4; line(X+x(3*n-2,1:j)./grid_size, Y-x(3*n-1,1:j)./grid_size, 'Color','w', 'LineWidth', 1.5);
    end
    last = obs_buff{i}.pose_col+1;
    pause(0.005);
    
end