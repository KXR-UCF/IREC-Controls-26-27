function [sensState, meas] = sensors(sensState, veh, env, P, t)

% imu: Roll rate (rad/s)
if t >= sensState.imu.tNext                            % Check if it should update
    p = veh.p +  P.imu.bias + P.imu.noise*randn;      % Apply Noise based off spec
    p = max(min(p, P.imu.range), -P.imu.range);       % Clamp reading to spec
    sensState.imu.p = P.imu.lsb*round(p/P.imu.lsb);  % Round based on smallest measurable reading
    sensState.imu.tNext = sensState.imu.tNext + 1/P.imu.rate;    %Calc next timestep to read
end

% Baro: static pressure (Pa)
if t >= sensState.baro.tNext
    pr = env.p + P.baro.bias + P.baro.noise*randn;
    sensState.baro.p = max(min(pr, P.baro.range(2)), P.baro.range(1));
    sensState.baro.tNext = sensState.baro.tNext + 1/P.baro.rate;
end

% Help between samples
meas.p = sensState.imu.p;      % Roll rate (rad/s)  
meas.pres = sensState.baro.p;   % Pressure (Pa)

end