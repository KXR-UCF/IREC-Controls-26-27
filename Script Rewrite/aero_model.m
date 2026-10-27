function aero = aero_model(servoState, env, vel, veh, P, t, w)
aero.mach = vel / env.a;
CNa_set = P.canard.cna(aero.mach);  % ORK canard-set CNa, per rad, ref = Aref
CNa_fin = 2*CNa_set / P.canard.num; % singe fin (Barrowman: set = N/2 * fin)

%use effective angle of attack and not raw deflection to calculate lift
alpha = deg2rad(servoState.delta + P.dist.misalign) - veh.p * P.canard.r / max(vel, 1);
aero.L = env.q * P.veh.Aref * CNa_fin * alpha;  % N, lift per singel canard
aero.Mcan = P.canard.num * aero.L * P.canard.r;    % N*m, roll moment for all fins deflecting

%spin can bearing friction moment
aero.Mbrg = P.dist.bearingC * (P.traj.p(t) - veh.p);

%turbulence: w is random filtered signal from run_sim()
aero.Mturb = env.q * P.veh.Aref * P.veh.diam * w;

aero.M = aero.Mcan + aero.Mbrg + aero.Mturb;
end