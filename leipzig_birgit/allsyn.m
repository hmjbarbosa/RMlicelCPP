clear all
% windows' size
wsx=250; wsy=650; 
% displacement for next window
wdx=260; xx0=-wsx;
% start position
wdy=0;   yy0=50;

% read physics constants
constants;

% figure 1 2 3
read_ascii_synthetic
% figure 4 5
read_sonde_synthetic
molecular;
% figure 6 7
rayleigh_fit_Manaus
% figure 8
Klett_Manaus
% figure 9
Raman_Manaus
% figure 10 11
Raman_beta_Manaus
%
addresult
%