clearvars
close all

P = params(Gains=[10, 0, 0], Servo="D930SW");
rec = run_sim(P);

plot_results(rec, P, Units='imperial');