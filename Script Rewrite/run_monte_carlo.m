clearvars
close all

% N = number of runs each run takes about 5-15 seconds depending on how
% long the fligt is
N = 1109; rng(1);    %Fixed seed so its repeatable.

P0 = params(Gains=[3, 0.6, 0.01, 7], gainSchedule=true, canardNum=2, Scale="subScale", gearDown=1, manualEndtime=11, maxQ = 20000, site="SRA", cascade=true, rollProgram=true, rollProgram_t=3);

names = ["misalign" "cnaScale" "backlash" "gyroBias" "bearingC"];
draws = zeros(N, numel(names));
res = repmat(struct('phiMax',0,'phiEnd',0,'pMax',0,'satFrac',0,'overshoot',0), N, 1);   %Results
recs = cell(N,1);    %Recording for plotting

for i = 1:N
    fprintf('On run %d out of %d ...\n', i, N)
    
    P = P0;
    P.dist.misalign = 0.5*(2*rand - 1); % +- 0.5 deg
    P.dist.cnaScale = 0.8 + 0.4*rand;     %+- 20%
    P.servo.backlash = 0.5*rand;        % 0-0.5 deg backlash
    P.imu.bias = deg2rad(0.5)*randn;    %gyro bias
    P.dist.bearingC = 2e-4*rand;
    draws(i,:) = [P.dist.misalign P.dist.cnaScale P.servo.backlash P.imu.bias P.dist.bearingC];

    rec = run_sim(P);
    res(i) = summarize(rec, P);
    recs{i} = struct('t', rec.t(1:10:end), 'phi',rec.phi(1:10:end), 'p',rec.p(1:10:end), 'phiTarget',rec.phiTarget(1:10:end));    %small set of data to plot
end

pass = [res.phiMax] < deg2rad(10) & [res.overshoot] < deg2rad(15);  % Check runs to see if they went above 10deg from 0
fprintf('%d/%d passed (%.0f%%)\n', sum(pass), N, 100*mean(pass))

% Save: timestamped .mat in seperate folder and CSV summary

outDir = "MC Results";  if ~isfolder(outDir), mkdir(outDir); end
stamp = string(datetime('now', 'Format','yyyyMMdd_HHmmss'));
save(fullfile(outDir, "mc_" + stamp + '.mat'), "draws", "names", "res", "pass", "recs", "P0")
writetable([array2table(draws, 'VariableNames', names) struct2table(res) table(pass(:), 'VariableNames', "pass")], ...
           fullfile(outDir, "mc_" + stamp + ".csv"))
writetable(flatten_params(P0), fullfile(outDir, "mc_" + stamp + "_params.csv"))
plot_monte_carlo(recs, res, draws, names, pass)

function s = summarize(rec, P)
on   = rec.t > P.ctrl.tOn;
err  = rec.phi - rec.phiTarget;                     % TRUE angle vs target
tSet = 1.5;                                          % s allowed to settle after a target change

holding = on;                                           % "should be holding" samples
tChg = rec.t([false diff(rec.phiTarget) ~= 0]);
for tc = tChg
    holding = holding & ~(rec.t >= tc & rec.t < tc + tSet);
end

s.phiMax    = max(abs(err(holding)));                   % worst error while holding
s.phiEnd    = abs(err(end));
s.pMax      = max(abs(rec.p(on)));
s.satFrac   = mean(abs(rec.cmd(on)) >= P.ctrl.deltaMax);
s.overshoot = 0;
if ~isempty(tChg)                                    % how far phi went past the new target
    after = rec.t >= tChg(end);
    s.overshoot = max(0, max(abs(rec.phi(after))) - abs(rec.phiTarget(end)));
end
end

function T = flatten_params(S, prefix)
if nargin < 2, prefix = "P"; end
name = strings(0,1);  value = strings(0,1);
for f = string(fieldnames(S))'
    v = S.(f);  key = prefix + "." + f;
    if isstruct(v)
        sub = flatten_params(v, key);
        name = [name; sub.name];  value = [value; sub.value];
    elseif (isnumeric(v) || islogical(v) || isstring(v)) && isscalar(v)
        name(end+1,1) = key;  value(end+1,1) = string(v);
    end
end
T = table(name, value);
end

%---Notes Aera---
% The Param setup below produces a good result for subcale tuning
% P0 = params(Gains=[3, 0.6, 0.01, 7], gainSchedule=true, canardNum=2, Scale="subScale", gearDown=1, manualEndtime=11, maxQ = 20000, site="SRA", cascade=true, rollProgram=true, rollProgram_t=3);


%Fullscale P for reference
% P0 = params(Gains=[3, 0.6, 0.01, 7], gainSchedule=true, canardNum=2, gearDown=1, maxQ = 172000, cascade=true, rollProgram=true, rollProgram_t=18);

