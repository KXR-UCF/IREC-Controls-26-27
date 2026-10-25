function [servo] = servo_spec(name)
switch name
    case "2000-Super-Speed"
        servo.rate = 1740; %(deg/s)
        servo.res = 0.15;  %(deg/us)
        servo.deadband = 4;%(us)
    case "D930SW"
        servo.rate = 857;  %(deg/s)
        servo.res = 0.134; %(deg/us)
        servo.deadband = 1;%(us)
    case "D77MG"
        servo.rate = 667;  %(deg/s)
        servo.res = 0.132; %(deg/us)
        servo.deadband = 1;%(us)
end

end