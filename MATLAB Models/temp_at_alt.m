function [temp] = temp_at_alt(alt)
%| gets temp in kelvin for a given altitude
arguments (Input)
    alt
end

arguments (Output)
    temp
end

temp = (20 - 0.00649 * alt) + 273.15;
end