function animate_roll(rec, P, opts)
arguments
    rec; P
    opts.Speed (1,1) double = 1      % 1 = real time
    opts.Exag  (1,1) double = 5      % canard angle exaggeration
end

% Build rocket
figure('Color','k'); ax = axes; axis equal off; view(35,20); hold on
R = P.veh.diam/2;  L = 1.0;
body = hgtransform(ax);
[x,y,z] = cylinder(R, 30);
surf(x, y, z*L, 'Parent',body, 'EdgeColor','none', 'FaceColor',[.7 .7 .75]);
patch([R R R R]*1.001, [-.01 .01 .01 -.01], [0 0 L L], 'b', 'Parent',body);  % roll stripe

for i = 1:P.canard.num
    ang = 2*pi*(i-1)/P.canard.num;
    hinge = hgtransform(body, 'Matrix', makehgtform('zrotate',ang, 'translate',[R 0 0.85*L]));
    fin(i) = hgtransform(hinge);
    patch([0 .04 .04 0], [0 0 0 0], [0 0 .06 .08], 'r', 'Parent',fin(i));
end
xlim([-.3 .3]); ylim([-.3 .3]); zlim([0 L+.1]); camlight

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