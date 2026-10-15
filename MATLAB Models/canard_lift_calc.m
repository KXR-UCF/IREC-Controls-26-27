%| Cna is a function of mach, returns a array lift for canard angles +-10
%| 
%| F = 0.5*rho*v^2*Cna(alpha*pi/180)A-ref
%|
function [lift] = canard_lift_calc(vel, temp, Cna, mach_fn_out)

A_ref = 0.00875;
cur_mach = vel/mach_fn_out;
p = 101.29*((temp+273.1)/288.08)^5.256;

lift = [-10:10; zeros(1,21)]; %| array of angles -10 to 10 (deg) that will be populated with forces

for i = 1:21
    lift(2:i) = 0.5*p*(vel^2)*Cna(cur_mach)*(lift(1:i)*pi/180)*A_ref;
end