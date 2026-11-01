function plot_monte_carlo(recs, res, draws, names, pass)
% Overlay of every run (blue = pass, red = fail)
figure('Name','MC overlay');
tl = tiledlayout(2,1, 'TileSpacing','compact');
a1 = nexttile; hold on; grid on; ylabel('Roll angle (deg)'); title('All runs (red = fail)')
a2 = nexttile; hold on; grid on; ylabel('Roll rate (rad/s)'); xlabel('Time (s)')
for i = 1:numel(recs)
    c = [0 .4 1 .15];  if ~pass(i), c = [1 .2 .2 .5]; end
    plot(a1, recs{i}.t, rad2deg(recs{i}.phi), 'Color', c)
    plot(a2, recs{i}.t, recs{i}.p,            'Color', c)
end
linkaxes([a1 a2], 'x')

% Distribution of worst holding error
figure('Name','MC histogram');
histogram(rad2deg([res.phiMax]), 30); grid on
xline(10, 'r--', 'Limit'); xlabel('Max |roll angle error| while holding (deg)'); ylabel('Runs')

% Which disturbance matters?
figure('Name','MC sensitivity');
tiledlayout('flow')
for j = 1:numel(names)
    nexttile; scatter(draws(:,j), rad2deg([res.phiMax]), 10, ~pass, 'filled'); grid on
    xlabel(names(j)); ylabel('Max |\phi err| (deg)')
end
colormap([0 .4 1; 1 .2 .2])                         % pass blue, fail red
end