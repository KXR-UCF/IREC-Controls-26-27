function [servoState] = servo_model(servoState, cmd, servo, dt)
us  = servo.us_center + cmd*servo.us_per_deg + servo.us_trim;   % deg -> pulse
us  = servo.us_step * round(us / servo.us_step);                % timer resolution
cmd = (us - servo.us_center) / servo.us_per_deg;                % what the servo actually targets

err = cmd - servoState.delta;

% Deadband only decides whether the servo starts moving; once moving it drives to the target
if ~servoState.moving && abs(err) > servo.deadband
    servoState.moving = true;
end

if servoState.moving
    maxStep = servo.rate * dt;
    servoState.delta = servoState.delta + max(min(err, maxStep), -maxStep);
    if abs(err) <= maxStep, servoState.moving = false; end      % arrived
end

end