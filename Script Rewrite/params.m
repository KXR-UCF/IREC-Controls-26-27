function [P] = params(opts)
arguments
    opts.Scale (1,1) string {mustBeMember(opts.Scale, ["fullScale","subScale"])} = "fullScale"
    opts.site (1,1) string {mustBeMember(opts.site, ["SRA","Midland"])} = "SRA"
    opts.padTemp (1,1) double = 32
    opts.Servo (1,1) string = "2000-Super-Speed"
    opts.imu (1,1) string = "LSM6DSOX"
    opts.baro (1,1) string = "MS5611"
    opts.dt    (1,1) double {mustBePositive} = 1e-3
    opts.canardData (1,1) string {mustBeMember(opts.canardData, ["ORK","CFD"])} = "ORK"
    opts.canardNum (1,1) double {mustBePositive} = 4
    opts.Gains (1,3) double = [0.2, 0, 0]
    opts.gainSchedule (1,1) logical = false
end
addpath("ORK Data\");

% Sim settings
P.sim.dt = opts.dt;  P.sim.ctrlDiv = 20; % Controller Hz = 1/dt/ctrlDiv

% Ork Trajectory data

switch opts.Scale
    case "fullScale"
        ork.sim = readtable("Fullscale-Sim-Data.csv", VariableNamingRule="preserve");
        ork.can = readtable("Fullscale-Canard_Aero_data.csv", VariableNamingRule="preserve"); 
    case "subScale"
        ork.sim = readtable("Subscale-Sim-Data.csv", VariableNamingRule="preserve");
        ork.can = readtable("Subscale-Canard_Aero_data.csv", VariableNamingRule="preserve"); 
end

% ORK has repeated timestamps, we need to remove these for interpolation to
% work. tU is unique time, ia is its index that grabs the unique values
% from ork time.
[tU, ia] = unique(ork.sim.("# Time (s)"), "stable");
P.sim.tEnd = tU(end);

P.traj.alt = griddedInterpolant(tU, ork.sim.("Altitude (m)")(ia));
P.traj.vel = griddedInterpolant(tU, ork.sim.("Total velocity (m/s)")(ia));
P.traj.p = griddedInterpolant(tU, ork.sim.("Roll rate (rad/s)")(ia));
P.traj.Ix = griddedInterpolant(tU, ork.sim.("Rotational moment of inertia (kg·m²)")(ia)); % whole rocket, need ot remove spincan ltr 
P.traj.thrust = griddedInterpolant(tU, ork.sim.("Thrust (N)")(ia));

% Servo params
P.servo = servo_spec(opts.Servo);
P.servo.us_trim = 0;
P.servo.us_step = 1; % pwm res of microcrontroller

% Canard Data
P.canard.num = opts.canardNum; % Num of canards
P.canard.r = 0.075; % Canard moment arm to vehicle roll axis
P.canard.deltaMax = 10; % Max deflection in deg (for now)

switch opts.canardData
    case "ORK"
        P.canard.cna = griddedInterpolant(ork.can.("# Mach number"), ork.can.("CNa (Canards)"), "linear", "nearest");
    case "CFD"
        error("CFD data not supported yet")
end

% Vehicle Parameters
P.veh.Aref = 0.014; P.veh.diam = 0.1335;

% Controller Parameters
P.ctrl.Kp = opts.Gains(1);
P.ctrl.Ki = opts.Gains(2);
P.ctrl.Kd = opts.Gains(3);
P.ctrl.pTarget = 0;
P.ctrl.openLoopCmd = 2;
P.ctrl.tOn = 0.5; P.ctrl.tOff = P.sim.tEnd;
P.ctrl.schedule = opts.gainSchedule;
P.ctrl.deltaMax = 10;


% sensors

P.imu = imu_spec(opts.imu);

P.baro = baro_spec(opts.baro);

% initial state
P.init.phi = 0;  P.init.p = 0;  P.init.delta = 0;

% Site
P.site = site_spec(opts.site);
P.site.Tpad = 273.15 + opts.padTemp;
P.site.T0 = P.site.Tpad + 0.0065*P.site.elev;

% Disturbances
P.dist.misalign  = 1;      % deg, fixed canard offset (build tolerance), try 0.25
P.dist.cnaScale  = 1;      % multiplier on canard CNa (aero uncertainty), MC: 0.8-1.2
P.dist.bearingC  = 0;      % N*m per rad/s, spin-can bearing friction, try 1e-4
P.dist.turbSigma = 0;      % roll moment noise as fraction of q*Aref*d, try 1e-4
P.dist.turbTau   = 0.2;    % s, turbulence correlation time

end