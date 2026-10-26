function [imu] = imu_spec(name)

switch name
    case "LSM6DSOX"
        imu.accelRange = 16; %G's
        imu.rate = 833; %Hz
        imu.bias = 0;
        imu.noise = deg2rad(3.8e-3*sqrt(295.5)); % rad/s 1-sigma per sample
        imu.range = deg2rad(2000); % rad/s per count
        imu.lsb = deg2rad(70e-3); % least significant bit: the smallest reading the gyro can read
    otherwise
        error("Unkown IMU module, manually add to imu_spec, or choose a supported model")
end
end