function rec = run_sim(P, opts)
arguments
    P
    opts.openLoop (1,1) string {mustBeMember(opts.openLoop, ["True","False"])} = "False"
end

dt = P.sim.dt;  t = 0:dt:P.sim.tEnd;    n = numel(t);

% Initial State
state.veh.phi = P.init. phi;
state.veh.p = P.init.p;
state.servo.delta = P.init.delta;
state.servo.moving = false;

env = atmos(P.traj.alt(0), P.traj.vel(0), P.site);

state.sens.imu.p = 0;      state.sens.imu.tNext = 0;
state.sens.baro.p = env.p; state.sens.baro.tNext = 0;
cmd = 0;

state.ctrl.integ = 0; state.ctrl.pPrev = 0;

% Noise signal
w = 0;  a_w = exp(-dt/P.dist.turbTau);


% Preallocate record
rec.t = t;  [rec.p, rec.phi, rec.delta, rec.cmd, rec.M, rec.q, rec.mach, rec.pMeas, ...
 rec.presTrue, rec.presMeas, rec.rho, rec.a] = deal(zeros(1,n));

for k = 1:n
    vel = P.traj.vel(t(k));
    env = atmos(P.traj.alt(t(k)), vel, P.site);
    [state.sens, meas] = sensors(state.sens, state.veh, env, P, t(k));

    if mod(k-1, P.sim.ctrlDiv) == 0
        %Defaults to closed loop due to opts defaulting to false
        switch opts.openLoop
            case "True"
                cmd = P.ctrl.openLoopCmd;
            case "False"                  
                [state.ctrl, cmd] = controller(state.ctrl, meas, P, t(k));
        end
    end

    w = a_w*w + P.dist.turbSigma*sqrt(1 - a_w^2)*randn;   % low-pass filtered noise

    state.servo = servo_model(state.servo, cmd, P.servo, dt);
    a = aero_model(state.servo, env, vel, state.veh, P, t(k), w);

    %vehicle: integrate roll (euler)
    pdot = a.M / P.traj.Ix(t(k));
    state.veh.phi = state.veh.phi + state.veh.p*dt;
    state.veh.p = state.veh.p + pdot*dt;

    %record
    rec.p(k) = state.veh.p;  rec.phi(k) = state.veh.phi;  rec.delta(k) = state.servo.delta;
    rec.cmd(k) = cmd;  rec.M(k) = a.M;  rec.q(k) = env.q;  rec.mach(k) = a.mach;
    rec.pMeas(k) = meas.p;
    rec.presTrue(k) = env.p;  rec.presMeas(k) = meas.pres;  rec.rho(k) = env.rho;
end
end