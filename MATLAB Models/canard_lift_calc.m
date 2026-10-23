%| Cna is a function of mach, returns a array lift for canard angles +-10
%| 
%| F = 0.5*rho*v^2*Cna(alpha*pi/180)A-ref
%|
function [lift] = canard_lift_calc(vel, temp, Cna_arr, alt)

A_ref = 0.014; %| m^2
cur_mach = vel/Mach(alt);
pressure = 101.29*((temp)/288.08)^5.256; %| kPa
p = pressure/(0.2869*(temp+273.1));

lift = [-10:10; zeros(1,21)]; %| array of angles -10 to 10 (deg) that will be populated with forces

Cna = interp1(Cna_arr(:,1), Cna_arr(:,2), cur_mach);

for i = 1:21
   lift(2,i) = 0.5*p*(vel^2)*Cna*(lift(1,i)*pi/180)*A_ref;
end