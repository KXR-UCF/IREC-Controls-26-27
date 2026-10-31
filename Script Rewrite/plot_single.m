clearvars
close all

P = params(Gains=[2, 0.1, 0.01], gainSchedule=true, canardNum=2, Scale="subScale", gearDown=5, manualEndtime=11, maxQ = 20000);
rec = run_sim(P);

plot_results(rec, P);