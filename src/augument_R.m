function [R,d] = augument_R(R,d,state,control,robot_id, delta_time)
%Augument for the new line of R
%Return original R , augument_R, original d
[s_r,s_c] = size(state);
last_state = state(:,s_c);
augument_R =[];

overall_control = zeros(3,4);
overall_dt = zeros(1,4);
%combine control
for id = 1:4
    [ind] = find(robot_id == id);
    for i = 1 : length(ind)
        overall_control(:,id) = overall_control(:,id) + control(:,ind(i));
        overall_dt(id) = overall_dt(id) + delta_time(ind(i));
    end
end

augument_R = zeros(12,12);

for i = 1:4
    id = robot_id(i);
    theta = last_state(3*id);
    omega = overall_control(3,i);
    v = sqrt(overall_control(1,i)^2 + overall_control(2,i)^2);
    dt = overall_dt(i);
    
    if (omega ~= 0)
        Gt = [ 1, 0, (v*cos(theta + dt*omega))/omega - (v*cos(theta))/omega;
            0, 1, (v*sin(theta + dt*omega))/omega - (v*sin(theta))/omega;
            0, 0,                                                      1];
    else
        Gt = [ 1, 0, -v*sin(theta);
               0, 1,  v*cos(theta);
               0, 0,             1];
    end
    augument_R(3*i-2:3*i,3*i-2:3*i) = Gt;
end

[R_r,R_c] = size(R);
augument_R = [zeros(12,R_c-12),augument_R,-1*eye(12)];
lamda = zeros(12,1);

[R, d] = Givens_Rotation(R, d, augument_R, lamda);

end

