function x = velocity_transition( x_i,u,dt)
%velocity_TRANSITION propagates the given state x_i according to the controls
% u = (vel_y; vel_x; vel_theta)
% x = (x;y;theta)
assert(length(x_i)==3);
assert(length(u)==2);
v = u(1); vel_theta = minimizedAngle(u(2));
x = x_i(1); y = x_i(2); theta = minimizedAngle(x_i(3));


x = x + v*dt*cos(theta + vel_theta*dt);
y = y + v*dt*sin(theta + vel_theta*dt);
theta = minimizedAngle(theta + vel_theta*dt);
x=[x;y;theta];

end

