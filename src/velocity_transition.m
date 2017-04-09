function x = velocity_transition( x_i,u,dt)
%velocity_TRANSITION propagates the given state x_i according to the controls
% u = (vel_y; vel_x; vel_theta)
% x = (x;y;theta)
assert(length(x_i)==3);
assert(length(u)==3);
v = sqrt(u(1)^2 + u(2)^2); vel_theta = u(3);
x = x_i(1); y = x_i(2); theta = x_i(3);

if (vel_theta ~= 0)
    x = x - v/vel_theta*sin(theta) + v/vel_theta*sin(theta+vel_theta*dt);
    y = y + v/vel_theta*cos(theta) - v/vel_theta*cos(theta+vel_theta*dt);
    theta = theta + vel_theta*dt;
    x=[x;y;theta];
else
    x = x + v*cos(theta);
    y = y + v*sin(theta);
    theta = theta;
    x=[x;y;theta]; 
end
end

