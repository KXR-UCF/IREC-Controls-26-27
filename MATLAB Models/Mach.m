function [mach] = Mach(alt)
% This function gets the speed of sound given altitude
%   Detailed explanation goes here
arguments (Input)
    alt % temperature is in Kelvin
end

arguments (Output)
    mach
end

    % find speed of sound based on temperature
    R = 286; % Gas Constant
    gamma = 1.4; % Specific heat ratio
    temp = temp_at_alt(alt); % Get temperature in K
    mach = sqrt(gamma * temp * R);
end