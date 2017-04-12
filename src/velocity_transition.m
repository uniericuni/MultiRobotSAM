function x = velocity_transition( x_i,k,i,dt)
%velocity_TRANSITION propagates the given state x_i according to the controls
% u = (vel_y; vel_x; vel_theta)
% x = (x;y;theta)


% assert(length(x_i)==3);
% assert(length(u)==2);
% v = u(1); vel_theta = u(2);
% x = x_i(1); y = x_i(2); theta = minimizedAngle(x_i(3));
%
%
% x = x + v*dt*cos(theta + vel_theta*dt);
% y = y + v*dt*sin(theta + vel_theta*dt);
% theta = minimizedAngle(theta + vel_theta*dt);
% x=[x;y;theta];



% dx = u(1);
% dy = u(2);
% dtheta = u(3);

global INFO;  

dx = INFO.robs{k}.pose{i+1}.x - INFO.robs{k}.pose{i}.x;
dy = INFO.robs{k}.pose{i+1}.y - INFO.robs{k}.pose{i}.y;
dtheta =  INFO.robs{k}.pose{i+1}.theta - INFO.robs{k}.pose{i}.theta;

x = x_i(1) + dx;
y = x_i(2) + dy;
theta = minimizedAngle(theta + dtheta);

end

