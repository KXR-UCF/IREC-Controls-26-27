function animate_roll(rec, P, opts)
arguments
    rec; P
    opts.Speed (1,1) double = 1          % 1 = real time
    opts.Exag  (1,1) double = 5          % canard angle exaggeration
    opts.Zoom  (1,1) logical = false     % true = frame the canards
    opts.Plots (1,1) logical = true      % live plots beside the rocket
    opts.Video (1,1) string = ""         % e.g. "roll.mp4" to record instead of play
end
% Dimensions from IREC_ORK7.0.ork (m), z = 0 at tail, +z toward nose
R = 0.065405;  Ltot = 3.2004;  Ln = 0.635;  zNose = Ltot - Ln;
zCan = 0.4064;  nSeg = 24;
grey = [.7 .7 .75];  ne = {'EdgeColor','none','FaceColor',grey};

% Layout
if opts.Plots
    fig = figure('Color','k', 'Position',[100 100 1400 700]);
    tl  = tiledlayout(fig, 3, 3, 'TileSpacing','compact');
    ax  = nexttile(tl, 1, [3 1]);
else
    fig = figure('Color','k');
    ax  = axes(fig);
end
axis(ax,'equal','off'); view(ax,35,20); hold(ax,'on')
body = hgtransform(ax);                   % rolls with phi
can  = hgtransform(ax);                   % spin can, decoupled

% Body tube
[x,y,z] = cylinder(R, nSeg);
surf(x, y, zCan + z*(zNose - zCan), 'Parent',body, ne{:});
patch([R R R R]*1.002, [-.01 .01 .01 -.01], [zCan zCan zNose zNose], 'b', 'Parent',body);

% Von Karman nose
zs = linspace(0,1,30);  th = acos(1 - 2*(1 - zs));
[x,y,z] = cylinder(R*sqrt((th - sin(2*th)/2)/pi), nSeg);
surf(x, y, zNose + z*Ln, 'Parent',body, ne{:});

% Canards: pivot at mid root chord
c = 0.0508;  b = 0.0254;  zPiv = Ltot - 0.9152;
for i = 1:P.canard.num
    hinge = hgtransform(body, 'Matrix', makehgtform('zrotate',2*pi*(i-1)/P.canard.num, 'translate',[R 0 zPiv]));
    fin(i) = hgtransform(hinge);
    patch([0 b b 0], [0 0 0 0], [-c/2 -c/2 0 c/2], 'r', 'Parent',fin(i));
end

% Spin can: straight section, boat tail, fins
[x,y,z] = cylinder(R, nSeg);
surf(x, y, 0.254 + z*0.1524, 'Parent',can, ne{:});
[x,y,z] = cylinder([0.052705 R], nSeg);
surf(x, y, z*0.254, 'Parent',can, ne{:});
fx = [0 0.3556 0.3937 0.3556];  fy = [0 0.1168 0.1168 -0.011];  zF = 0.4274;
for i = 1:4
    patch(R + fy, zeros(1,4), zF - fx, [.3 .3 .3], 'Parent', ...
        hgtransform(can, 'Matrix', makehgtform('zrotate', pi/2*(i-1))));
end

if opts.Zoom
    xlim(ax,[-.12 .12]); ylim(ax,[-.12 .12]); zlim(ax, zPiv + [-.15 .15]);
else
    xlim(ax,[-.3 .3]); ylim(ax,[-.3 .3]); zlim(ax,[0 Ltot]);
end
camlight(ax)

% Altitude gauge: pad (0 AGL) to apogee
alt = P.traj.alt(rec.t);
apo = max(P.traj.alt.Values);
ga = axes(fig, 'Position',[0.03 0.1 0.012 0.8], 'Color','k', ...
     'XColor','none', 'YColor','w', 'XLim',[0 1], 'YLim',[0 apo]);
hold(ga,'on')
yticks(ga, [0 apo]);  yticklabels(ga, {'Pad', sprintf('Apogee\n%.0f m', apo)})
rectangle(ga, 'Position',[0 0 1 apo], 'EdgeColor','w');
altBar = patch(ga, [0 1 1 0], [0 0 0 0], [0 .6 1], 'EdgeColor','none');
altTxt = text(ga, 1.4, 0, '', 'Color','w', 'FontSize',9);

% Live plots (decimated so redraws stay cheap)
dec = 10;
if opts.Plots
    td   = rec.t(1:dec:end);
    sig  = {rec.p, rad2deg(rec.phi), rec.servoOut};
    sigD = cellfun(@(s) s(1:dec:end), sig, 'UniformOutput', false);
    lab  = ["Roll rate (rad/s)" "Roll angle (deg)" "Canard (deg)"];
    for j = 1:3
        pa = nexttile(tl, 3*(j-1)+2, [1 2]); hold(pa,'on'); grid(pa,'on')
        set(pa, 'Color','k', 'XColor','w', 'YColor','w', 'GridColor',[.5 .5 .5])
        plot(pa, td, sigD{j}, 'Color',[.5 .5 .5 .4]);
        live(j) = plot(pa, NaN, NaN, 'LineWidth',1.5);
        ylabel(pa, lab(j)); xlim(pa, [0 rec.t(end)])
    end
    xlabel(pa, 'Time (s)')
end

% Playback
n = numel(rec.t);
if strlength(opts.Video) > 0
    fps = 60;
    v = VideoWriter(opts.Video, 'MPEG-4');  v.FrameRate = fps;  open(v);
    step = max(1, round(opts.Speed / (fps*P.sim.dt)));
    for k = 1:step:n
        drawFrame(k);
        drawnow;  writeVideo(v, getframe(fig));
    end
    close(v);
else
    t0 = tic;
    while true
        k = floor(toc(t0)*opts.Speed / P.sim.dt) + 1;
        if k > n, break; end
        drawFrame(k);
        drawnow;
    end
end

    function drawFrame(k)
        body.Matrix = makehgtform('zrotate', rec.phi(k));
        for ii = 1:P.canard.num
            fin(ii).Matrix = makehgtform('xrotate', deg2rad(rec.servoOut(k)*opts.Exag));
        end
        altBar.YData = [0 0 alt(k) alt(k)];
        set(altTxt, 'Position',[1.4 alt(k)], 'String',sprintf('%.0f m', alt(k)));
        if opts.Plots
            kd = ceil(k/dec);
            for jj = 1:3
                set(live(jj), 'XData', td(1:kd), 'YData', sigD{jj}(1:kd));
            end
        end
        title(ax, sprintf('t = %.2f s   p = %.2f rad/s   \\phi = %.0f°', ...
            rec.t(k), rec.p(k), rad2deg(rec.phi(k))), 'Color','w')
    end
end