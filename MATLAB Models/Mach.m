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
    R = 286 % Gas Constant
    gamma = 1.4 % Specific heat ratio
    temp = (20 - 0.00649 * alt) + 273.15 % Get temperature in K
    mach = sqrt(gamma * temp * R)
end