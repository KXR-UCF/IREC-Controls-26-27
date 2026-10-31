function [ctrl, cmd] = controller(ctrl, meas, P, t)
C = P.ctrl;
dt = P.sim.dt * P.sim.ctrlDiv;  %Time since last run

% Only actuate canards during the "enable" window
if t < C.tOn || t > C.tOff
    ctrl.integ = 0; ctrl.pPrev = meas.p; cmd = 0;
    return
end

% Schedule logic (do later)
s = 1;
if C.schedule
    %s = C.qRef/ctrl.q; % Uncomment this and comment line below to see what
    %happens we dont clamp s at a lower q and upper value of s
    s = min(C.qRef / max(ctrl.q, C.qMin), C.sMax);
    ctrl.s = s;
end
%logic here

err = C.pTarget - meas.p;           %rad/s
deriv = -(meas.p - ctrl.pPrev) / dt;%derivative on measurement
ctrl.pPrev = meas.p;

u = (s*C.Kp*err + C.Ki*ctrl.integ + C.Kd*deriv);   % deg (gains are deg per rad/s)

% Anti-windup: only integrate when not saturated (or when it helps unsaturate)
if abs(u) < C.deltaMax || sign(err) ~= sign(u)
    ctrl.integ = ctrl.integ + err*dt;
end
cmd = max(min(u, C.deltaMax), -C.deltaMax);
end

