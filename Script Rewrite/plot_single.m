clearvars
close all

P = params(Gains=[3, 0.6, 0.01, 7], gainSchedule=true, canardNum=2, Scale="subScale", gearDown=1, manualEndtime=11, maxQ = 20000, site="SRA", cascade=true, rollProgram=true, rollProgram_t=3);
P.servo.backlash = 0.5;
P.dist.misalign  = 0.25;   % deg, fixed canard offset (build tolerance), try 0.25=
P.dist.cnaScale  = 1;      % multiplier on canard CNa (aero uncertainty), MC: 0.8-1.2
P.dist.bearingC  = 1e-4;      % N*m per rad/s, spin-can bearing friction, try 1e-4
P.dist.turbSigma = 1e-4;      % roll moment noise as fraction of q*Aref*d, try 1e-4
P.dist.turbTau   = 0.2;    % s, turbulence correlation time
rec = run_sim(P);

plot_results(rec, P



%---Notes Aera---
% The Param setup below produces a good result for subcale tuning
% P = params(Gains=[3, 0.6, 0.01, 7], gainSchedule=true, canardNum=2, Scale="subScale", gearDown=1, manualEndtime=11, maxQ = 20000, site="SRA", cascade=true, rollProgram=true, rollProgram_t=3);