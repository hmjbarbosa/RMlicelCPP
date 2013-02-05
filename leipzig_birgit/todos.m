clear all
% windows' size
wsx=250; wsy=650; 
% displacement for next window
wdx=260; xx0=-wsx;
% start position
wdy=0;   yy0=50;

% read physics constants
constants

read_ascii_Manaus
read_sonde_Manaus
molecular
rayleigh_fit_Manaus
Klett_Manaus
Raman_Manaus
Raman_beta_Manaus
%