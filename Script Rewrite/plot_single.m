clearvars
close all

P = params(Gains=[3, 0.6, 0.01, 7], gainSchedule=true, canardNum=4, gearDown=1, maxQ = 172000, cascade=true, rollProgram=true, rollProgram_t=18);
P.dist.misalign  = 0.1;
P.dist.cnaScale  = 1;      % multiplier on canard CNa (aero uncertainty), MC: 0.8-1.2
P.dist.bearingC  = 0;      % N*m per rad/s, spin-can bearing friction, try 1e-4
P.dist.turbSigma = 1e-4;      % roll moment noise as fraction of q*Aref*d, try 1e-4
P.dist.turbTau   = 0.2;    % s, turbulence correlation time
rec = run_sim(P);

plot_results(rec, P)
animate_roll(rec, P, Plots=true, Zoom=true)


%---Notes Aera---
% The Param setup below produces a good result for subcale tuning
% P = params(Gains=[3, 0.6, 0.01, 7], gainSchedule=true, canardNum=2, Scale="subScale", gearDown=1, manualEndtime=11, maxQ = 20000, site="SRA", cascade=true, rollProgram=true, rollProgram_t=3);


%Fullscale P for reference
% P = params(Gains=[3, 0.6, 0.01, 7], gainSchedule=true, canardNum=2, gearDown=1, maxQ = 172000, cascade=true, rollProgram=true, rollProgram_t=18);