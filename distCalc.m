% distCalc.m
% This function calculates the seperation distance between a source and 
% receiver
%
% Inputs: 
% temp_deg_c - water temperature [deg. C]
% depth_ m - depth of receiver (should be same as source) [m]
% time_delay - scope delay time from source signal to receiver
%
% Outputs:
% R - seperation distance [m]

function R = distCalc(temp_c, depth_m, time_delay)
    cfun = @(t,d) 1402.7 + 488*(t/100) - 482*(t/100).^2 + 135*(t/100).^3 + (15.9 + 2.8*(t/100) + 2.4*(t/100)^2).*(1e-5*1000*9.81*d/100);
    c = cfun(temp_c, depth_m);
    R = c * time_delay;
end