clearvars
close all

P = params(Gains=[0.9, 0.1, 0.01], Servo="D930SW", gainSchedule=true, canardNum=2);
rec = run_sim(P);

plot_results(rec, P);