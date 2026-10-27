function plot_results(rec, P, opts)
arguments
    rec; P
    opts.Units (1,1) string {mustBeMember(opts.Units, ["SI","imperial"])} = "SI"
end
t = rec.t;
alt = P.traj.alt(t);  vel = P.traj.vel(t);  thr = P.traj.thrust(t);  Ix = P.traj.Ix(t);

% unit factors + labels: u.x = {factor, "label"}
if opts.Units == "imperial"
    u.len = {3.28084, "ft"};      u.vel = {3.28084, "ft/s"};   u.force = {0.224809, "lbf"};
    u.q   = {1.45038e-4, "psi"};  u.rho = {1.94032e-3, "slug/ft^3"};
    u.Ix  = {0.737562, "slug ft^2"}; u.M = {0.737562, "lbf ft"}; u.pres = {1.45038e-4, "psi"};
else
    u.len = {1, "m"};  u.vel = {1, "m/s"};  u.force = {1, "N"};  u.q = {1e-3, "kPa"};
    u.rho = {1, "kg/m^3"};  u.Ix = {1, "kg m^2"};  u.M = {1, "N m"};  u.pres = {1, "Pa"};
end
c = @(x, k) x * u.(k){1};                    % convert
L = @(name, k) name + " (" + u.(k){2} + ")"; % label

% events shared by every figure
mk.tBO = t(find(thr > 0, 1, 'last'));
in = rec.mach >= 0.8 & rec.mach <= 1.2;  e = diff([0 in 0]);
mk.trans = [t(e(1:end-1) == 1); t(e(2:end) == -1)]';

panels(t, mk, "Trajectory", ...
  {c(alt,"len"), L("Altitude","len")}, {c(vel,"vel"), L("Velocity","vel")}, ...
  {rec.mach, "Mach"}, {c(thr,"force"), L("Thrust","force")});

panels(t, mk, "Atmosphere & aero", ...
  {c(rec.q,"q"), L("q","q")}, {c(rec.rho,"rho"), L("Density","rho")}, ...
  {c(Ix,"Ix"), L("Ix","Ix")}, {c(rec.M,"M"), L("Roll moment","M")});

panels(t, mk, "Roll control", ...
  {[rec.p; rec.pMeas], "Roll rate (rad/s)", ["True" "Measured"]}, ...
  {rad2deg(rec.phi), "Roll angle (deg)"}, ...
  {[rec.cmd; rec.delta], "Canard (deg)", ["Command" "Actual"]});

panels(t, mk, "Sensors", ...
  {rec.pMeas - rec.p, "Gyro error (rad/s)"}, ...
  {c(rec.presMeas - rec.presTrue,"pres"), L("Baro error","pres")});
end

function panels(t, mk, name, varargin)
figure('Name', name);  n = numel(varargin);
tl = tiledlayout(n,1,'TileSpacing','compact');  title(tl, name);  ax = gobjects(n,1);
for i = 1:n
    d = varargin{i};  ax(i) = nexttile;  hold on
    for j = 1:size(mk.trans,1)                        % shade transonic (M 0.8-1.2)
        xregion(mk.trans(j,1), mk.trans(j,2), 'FaceColor',[1 .6 0], ...
                'FaceAlpha',.15, 'HandleVisibility','off');
    end
    plot(t, d{1});  grid on;  ylabel(d{2})
    xline(mk.tBO, ':', 'Burnout', 'HandleVisibility','off');
    if numel(d) > 2, legend(d{3}, 'Location','best'); end
    hold off
end
xlabel(ax(end), 'Time (s)');  linkaxes(ax, 'x');
end