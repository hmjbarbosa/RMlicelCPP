% Physics
k=1.3806503e-23; % Boltzmann [m2 kg / s2 K]
Na=6.0221367e23; % Avogadro's number []
Mvol=22.4141;    % Molar volume [L/mol] at 1013.25hPa and 273.15K

% Standard Atmosphere Reference values
Tstd=288.15;  % Temperature [K]
Pstd=1013.25; % Pressure [hPa]
% Molecular density [#/cm3] at Tstd and Pstd
% 1000 to convert liter to cm^3
Nstd=(Na/Mvol/1000)*(273.15/Tstd); 

% Atmospheric Constituents Concentration
% units: ppv
% ref: Seinfeld and Pandis (1998)
N2ppv=(1e-2)*78.084;
O2ppv=(1e-2)*20.946;
Arppv=(1e-2)*0.934;
Neppv=(1e-2)*1.80*1e-3;
Heppv=(1e-2)*5.20*1e-4;
Krppv=(1e-2)*1.10*1e-4;
H2ppv=(1e-2)*5.80*1e-5;
Xeppv=(1e-2)*9.00*1e-6;

% Atmospheric Constituents Molecular weight
% units: grams per mol
% ref: Handbook of Physics and Chemistry (CRC 1997)
N2mwt=28.013;
O2mwt=31.999;
Armwt=39.948;
Nemwt=20.18;
Hemwt=4.003;
Krmwt=83.8;
H2mwt=2.016;
Xemwt=131.29;
CO2mwt=44.01;

