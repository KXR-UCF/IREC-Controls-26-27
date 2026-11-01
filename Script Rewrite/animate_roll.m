function animate_roll(rec, P, opts)
arguments
    rec; P
    opts.Speed (1,1) double = 1          % 1 = real time
    opts.Exag  (1,1) double = 5          % canard angle exaggeration
    opts.Zoom  (1,1) logical = false     % true = frame the canards
end
% Dimensions from IREC_ORK7.0.ork (m), z = 0 at tail, +z toward nose
R = 0.065405;  Ltot = 3.2004;  Ln = 0.635;  zNose = Ltot - Ln;
zCan = 0.4064;                            % top of spin can (boat tail + straight)
grey = [.7 .7 .75];  ne = {'EdgeColor','none','FaceColor',grey};

figure('Color','k'); ax = axes; axis equal off; view(35,20); hold on
body = hgtransform(ax);                   % rolls with phi
can  = hgtransform(ax);                   % spin can, decoupled

% Body tube
[x,y,z] = cylinder(R, 40);
surf(x, y, zCan + z*(zNose - zCan), 'Parent',body, ne{:});
patch([R R R R]*1.002, [-.01 .01 .01 -.01], [zCan zCan zNose zNose], 'b', 'Parent',body);

% Von Karman nose
zs = linspace(0,1,40);  th = acos(1 - 2*(1 - zs));
[x,y,z] = cylinder(R*sqrt((th - sin(2*th)/2)/pi), 40);
surf(x, y, zNose + z*Ln, 'Parent',body, ne{:});

% Canards: pivot at mid root chord
c = 0.0508;  b = 0.0254;  zPiv = Ltot - 0.9152;
for i = 1:P.canard.num
    hinge = hgtransform(body, 'Matrix', makehgtform('zrotate',2*pi*(i-1)/P.canard.num, 'translate',[R 0 zPiv]));
    fin(i) = hgtransform(hinge);
    patch([0 b b 0], [0 0 0 0], [-c/2 -c/2 0 c/2], 'r', 'Parent',fin(i));
end

% Spin can: straight section, boat tail, fins
[x,y,z] = cylinder(R, 40);
surf(x, y, 0.254 + z*0.1524, 'Parent',can, ne{:});
[x,y,z] = cylinder([0.052705 R], 40);
surf(x, y, z*0.254, 'Parent',can, ne{:});
fx = [0 0.3556 0.3937 0.3556];  fy = [0 0.1168 0.1168 -0.011];  zF = 0.4274;
for i = 1:4
    patch(R + fy, zeros(1,4), zF - fx, [.3 .3 .3], 'Parent', ...
        hgtransform(can, 'Matrix', makehgtform('zrotate', pi/2*(i-1))));
end

if opts.Zoom
    xlim([-.12 .12]); ylim([-.12 .12]); zlim(zPiv + [-.15 .15]);
else
    xlim([-.3 .3]); ylim([-.3 .3]); zlim([0 Ltot]);
end
camlight

% Real-time playback
t0 = tic;
while true
    tNow = toc(t0) * opts.Speed;
    if tNow > rec.t(end), break; end
    k = find(rec.t >= tNow, 1);
    body.Matrix = makehgtform('zrotate', rec.phi(k));
    for i = 1:P.canard.num
        fin(i).Matrix = makehgtform('xrotate', deg2rad(rec.servoOut(k)*opts.Exag));
    end
    title(sprintf('t = %.2f s   p = %.2f rad/s   \\phi = %.0f°', ...
        rec.t(k), rec.p(k), rad2deg(rec.phi(k))), 'Color','w')
    drawnow limitrate
end
end