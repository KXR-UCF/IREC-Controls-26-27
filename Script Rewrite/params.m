function [P] = params(opts)
arguments
    opts.Scale (1,1) string {mustBeMember(opts.Scale, ["fullScale","subScale"])} = "fullScale"
    opts.site (1,1) string {mustBeMember(opts.site, ["SRA","Midland"])} = "SRA"
    opts.padTemp (1,1) double = 32
    opts.Servo (1,1) string {mustBeMember(opts.Servo, ["2000-Super-Speed","D930SW","D77MG","Axon-MINI-MK2"])} = "Axon-MINI-MK2"
    opts.imu (1,1) string = "LSM6DSOX"
    opts.baro (1,1) string = "MS5611"
    opts.dt    (1,1) double {mustBePositive} = 1e-3
    opts.canardData (1,1) string {mustBeMember(opts.canardData, ["ORK","CFD"])} = "ORK"
    opts.canardNum (1,1) double {mustBePositive} = 4
    opts.Gains (1,4) double = [0.2, 0, 0, 0]
    opts.gainSchedule (1,1) logical = false
    opts.gearDown (1,1) double = 1
    opts.manualEndtime (1,1) double = 0
    opts.maxQ (1,1) = 172000
    opts.cascade (1,1) logical = false
    opts.rollProgram (1,1) logical = false
    opts.rollProgram_t (1,1) double = 5
    opts.openLoop (1,1) logical = false
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

if opts.manualEndtime ~= 0
    P.sim.tEnd = opts.manualEndtime;
end

P.traj.alt = griddedInterpolant(tU, ork.sim.("Altitude (m)")(ia));
P.traj.vel = griddedInterpolant(tU, ork.sim.("Total velocity (m/s)")(ia));
P.traj.p = griddedInterpolant(tU, ork.sim.("Roll rate (rad/s)")(ia));
P.traj.Ix = griddedInterpolant(tU, ork.sim.("Rotational moment of inertia (kg·m²)")(ia)); % whole rocket, need ot remove spincan ltr 
P.traj.thrust = griddedInterpolant(tU, ork.sim.("Thrust (N)")(ia));

% Servo params
P.servo = servo_spec(opts.Servo);
P.servo.us_trim = 0;
P.servo.us_step = 1; % pwm res of microcrontroller
P.servo.gearDown = opts.gearDown;
P.servo.us_per_deg = P.servo.us_per_deg * P.servo.gearDown;
P.servo.rate = P.servo.rate / P.servo.gearDown;
P.servo.deadband = P.servo.deadband_us / P.servo.us_per_deg;
P.servo.backlash = 0.5; %deg of slop between servo output and canard shaft

% Canard Data
P.canard.num = opts.canardNum; % Num of canards
P.canard.ORKnum = 4;           %VERY IMPORTANT MUST CHANGE OR SIM IS BAD <<<<<===================
if opts.Scale == 'subScale'
    P.canard.ORKnum = 2;
end
%For more accurate sim with ORK data export ork CNA with correct canard num

P.canard.r = 0.075; % Canard moment arm to vehicle roll axis
if opts.Scale == "subScale", P.canard.r = 0.057; end

P.canard.deltaMax = 10; % Max deflection in deg (for now)

switch opts.canardData
    case "ORK"
        P.canard.cna = griddedInterpolant(ork.can.("# Mach number"), ork.can.("CNa (Canards)"), "linear", "nearest");
    case "CFD"
        error("CFD data not supported yet")
end

% Vehicle Parameters -- UPDATE WITH ORK CHANGES!!!
P.veh.Aref = 0.014; P.veh.diam = 0.1335;
if opts.Scale == "subScale"
    P.veh.Aref = 0.009; P.veh.diam = 0.1056;
end

% Controller Parameters
P.ctrl.Kp = opts.Gains(1);
P.ctrl.Ki = opts.Gains(2);
P.ctrl.Kd = opts.Gains(3);
P.ctrl.pTarget = 0;
P.ctrl.openLoopCmd = 2;
P.ctrl.tOn = 0.5; P.ctrl.tOff = P.sim.tEnd;
P.ctrl.schedule = opts.gainSchedule;
P.ctrl.deltaMax = 10;
P.ctrl.qRef = opts.maxQ;
P.ctrl.qMin = 2000;
P.ctrl.sMax = 10;

P.ctrl.cascade = opts.cascade;
P.ctrl.Kphi = opts.Gains(4);
P.ctrl.phiTarget = 0;
P.ctrl.pTargetMax = 4; % rad/s, clamps what outer loop can cmd

P.ctrl.rollProgram = opts.rollProgram;
P.ctrl.rollProgram_t = opts.rollProgram_t;



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
P.dist.misalign  = 0.25;      % deg, fixed canard offset (build tolerance), try 0.25
P.dist.cnaScale  = 1;      % multiplier on canard CNa (aero uncertainty), MC: 0.8-1.2
P.dist.bearingC  = 0;      % N*m per rad/s, spin-can bearing friction, try 1e-4
P.dist.turbSigma = 0;      % roll moment noise as fraction of q*Aref*d, try 1e-4
P.dist.turbTau   = 0.2;    % s, turbulence correlation time

end