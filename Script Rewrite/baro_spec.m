function [baro] = baro_spec(name)

%Things to consider
%Near mach, baro readings will be bad, they should be ignored for gain
%scheduling

switch name
    case "MS5611"
        baro.osr = 1024;
        baro.rate = 1/(2*2.08e-3); % ~240Hz (pressure + temp)
        baro.bias = 0;
        baro.noise = 2.7; %Pa, 1-sigma (0.027 mbar)
        baro.range = [1000 120000]; % Pa
    otherwise
        error("Unkown Baro module, manually add to baro_spec, or choose a supported model")
end
end