function plot_results(rec, P)
t = rec.t;
alt = P.traj.alt(t);  vel = P.traj.vel(t);  thr = P.traj.thrust(t);  Ix = P.traj.Ix(t);
tBO = t(find(thr > 0, 1, 'last'));                   % burnout time

% 1) Trajectory
panels(t, tBO, "Trajectory", ...
  {alt, "Altitude (m)"}, {vel, "Velocity (m/s)"}, {rec.mach, "Mach"}, {thr, "Thrust (N)"});

% 2) Atmosphere / aero
panels(t, tBO, "Atmosphere & aero", ...
  {rec.q/1e3, "q (kPa)"}, {rec.rho, "Density (kg/m^3)"}, {Ix, "Ix (kg m^2)"}, {rec.M, "Roll moment (N m)"});

% 3) Roll control
panels(t, tBO, "Roll control", ...
  {[rec.p; rec.pMeas], "Roll rate (rad/s)", ["True" "Measured"]}, ...
  {rad2deg(rec.phi), "Roll angle (deg)"}, ...
  {[rec.cmd; rec.delta], "Canard (deg)", ["Command" "Actual"]});

% 4) Sensors (error = measured - true)
panels(t, tBO, "Sensors", ...
  {rec.pMeas - rec.p, "Gyro error (rad/s)"}, {rec.presMeas - rec.presTrue, "Baro error (Pa)"});
end

function panels(t, tBO, name, varargin)
figure('Name', name);  n = numel(varargin);
tl = tiledlayout(n,1,'TileSpacing','compact');  title(tl, name);  ax = gobjects(n,1);
for i = 1:n
    d = varargin{i};  ax(i) = nexttile;
    plot(t, d{1}); grid on; ylabel(d{2})
    if numel(d) > 2, legend(d{3}, 'Location','best'); end
    xline(tBO, ':', 'Burnout');
end
xlabel(ax(end), 'Time (s)');  linkaxes(ax, 'x');
end