function [state] = update_state( state,control,robot_id, delta_time )
% input state: 3N*(t+1) control 3*C robot_id C
% output state 3N*(t+2)

%[r,c] = size(state);
[s_r,s_c] = size(state);
next_state = state(:,s_c);

[c_r,c_c] = size(control);

for i = 1:length(c_c)
    id = robot_it(i);
    robot_state = next_state(3*id-2:3*id);
    robot_control = control(:,i);
    robot_state = velocity_transition(robot_state,robot_control,delta_time(i));
    next_state(3*id-2) = robot_state(1);
    next_state(3*id-1) = robot_state(2);
    next_state(3*id) = robot_state(3); 
end
state = [state,next_state];
end

