function [R,augument_R,d] = augument_R(R,d,state,control,robot_id, delta_time)
%Augument for the new line of R
%Return original R , augument_R, original d
[s_r,s_c] = size(state);
last_state = state(:,s_c);
augument_R =[];

for i = 1:length(robot_id)
    id = robot_id(i);
    theta = last_state(3*id);
    omega = control(3,i);
    v = sqrt(control(1,i)^2 + control(2,i)^2);
    dt = delta_time(i);
    
    Gt = [ 1, 0, (v*cos(theta + dt*omega))/omega - (v*cos(theta))/omega;
           0, 1, (v*sin(theta + dt*omega))/omega - (v*sin(theta))/omega;
           0, 0,                                                      1];
    augument_R = [augument_R,Gt];
end

[R_r,R_c] = size(R);
augument_R = [zeros(3,R_c),augument_R];

end

