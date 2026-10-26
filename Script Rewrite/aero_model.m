function aero = aero_model(servoState, env, vel, veh, P)
aero.mach = vel / env.a;
CNa_set = P.canard.cna(aero.mach);  % ORK canard-set CNa, per rad, ref = Aref
CNa_fin = 2*CNa_set / P.canard.num; % singe fin (Barrowman: set = N/2 * fin)

%use effective angle of attack and not raw deflection to calculate lift
alpha = deg2rad(servoState.delta) - veh.p * P.canard.r / max(vel, 1);
aero.L = env.q * P.veh.Aref * CNa_fin * alpha;  % N, lift per singel canard
aero.M = P.canard.num * aero.L * P.canard.r;    % N*m, roll moment for all fins deflecting

end