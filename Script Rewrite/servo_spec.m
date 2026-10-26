function [servo] = servo_spec(name)
switch name
    case "2000-Super-Speed"
        servo.rate = 1740; %(deg/s)
        servo.res = 0.15;  %(deg/us)
        servo.us_per_deg = inv(servo.res);
        servo.deadband_us = 4;
        servo.deadband = servo.deadband_us / servo.us_per_deg;
        servo.us_center = 1500;
    case "D930SW"
        servo.rate = 857;  %(deg/s)
        servo.res = 0.134; %(deg/us)
        servo.us_per_deg = inv(servo.res);
        servo.deadband_us = 1;
        servo.deadband = servo.deadband_us / servo.us_per_deg;
        servo.us_center = 1500;
    case "D77MG"
        servo.rate = 667;  %(deg/s)
        servo.res = 0.132; %(deg/us)
        servo.us_per_deg = inv(servo.res);
        servo.deadband_us = 1;
        servo.deadband = servo.deadband_us / servo.us_per_deg;
        servo.us_center = 1500;
    otherwise
        error("Uknown servo model, check overview sheet for supported servos or manually add new ones in sservo_spec.m")
end

end