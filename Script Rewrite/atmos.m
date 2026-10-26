function env = atmos(alt, vel, site)
h = alt + site.elev;    %ORK alt AGL + site elev
T = site.T0 - 0.0065*h;
env.T = T;              % K
env.T_cels = T - 273.15; % Celsius
env.p = 101325*(T/site.T0)^5.2559; %Pa
env.rho = env.p/(287.05*T);        %kg/m^3
env.a = sqrt(1.4*287.05*T);        %m/s, speed of sound at alt
env.q = 0.5*env.rho*vel^2;         % Pa, dynamic pressure
end