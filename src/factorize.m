function [R,d] = factorize(x, mega_robidObs, mega_obs, mega_robidControl, mega_controls)
%%
% This function reform A,b, and form R,d
% INPUT: state matrix x, size: 3N x (t+1)
%        mega_robidObs, size 1 x O, O is the total number of observation up to now
%        mega_obs, size 3 x O
%        mega_robidControl, size, 1 x C, C all the controls up to now
%        mega_controls, size 3 x C
% OUTPUT: R,d
%        R: upper trianguler matrix
%        d: associated vector 
%
global INFO;                            % experiment configuration, should not be updated
%% Start with initializing A, b
A = zeros(3*INFO.N*2,3*INFO.N*2);
% Since the controls are now presented every time stamp, in what sequence
% to put?

%% First take care of all the controls
% How is dt obtained to use in the jacobian?

%% Then take care of all the observations
% what factor should we put in the adjancy matrix?


end