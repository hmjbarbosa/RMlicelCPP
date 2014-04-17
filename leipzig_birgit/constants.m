%------------------------------------------------------------------------
% M-File:
%    molecular.m
%
% Authors:
%    H.M.J. Barbosa (hbarbosa@if.usp.br), IF, USP, Brazil
%
% Description
%
%    Defines important physic's constants, most of which are used
%    by the molecular scattering calculation.
%
% Input
%
%    co2ppmv - CO2 concentration in ppmv
%
% Ouput
%
%    k - Boltzmann constant [m2 kg / s2 K]
%    Na - Avogadro's number [#]
%    Mvol - Molar volume [m3/mol] at 1013.25hPa and 273.15K
%    Rgas - Universal gas constant [J/K/mol]
%    Rair - Dry air gas constant [J/K/kg]
%    Tstd - Temperature of standard atmosphere [K]
%    Pstd - Pressure of standard atmosphere [Pa]
%    Nstd - Molecular density [#/m3] at Tstd and Pstd
%
%    Atmospheric Constituents Concentration [ppv] and Molecular weight
%    [grams per mol] for: N2, O2, Ar, Ne, He, Kr, H2 Xe
%
% Usage
%
%    Input the desired CO2 concentration and execute the M-file.
%
% References
% 
%    Seinfeld and Pandis (1998)
%    Handbook of Physics and Chemistry (CRC 1997)
%    Wallace and Hobbs, Atmospheric science (2nd Edition)
%    Bodhaine et al, 1999: J. Atmos. Ocea. Tech, v. 16, p.1854
%
%------------------------------------------------------------------------

clear Airmwt Armwt Arppv CO2mwt CO2ppv H2mwt H2ppv Hemwt ...
    Heppv Krmwt Krppv Mvol N2mwt N2ppv Na Nemwt Neppv Nstd ...
    O2mwt O2ppv Pstd Rair Rgas T0 Tstd Xemwt Xeppv k

%------------------------------------------------------------------------
% User definitions (should be done before calling the routine)
%------------------------------------------------------------------------
% co2ppmv = 392; % CO2 concentration [ppmv]

disp(['constants:: co2ppmv = ' num2str(co2ppmv)]);

%------------------------------------------------------------------------
% Fixed definitions
%------------------------------------------------------------------------

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
CO2ppv=co2ppmv*1e-6;

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

% Dry air molecular mass (grams per mol)
Airmwt=(N2ppv*N2mwt + O2ppv*O2mwt + Arppv*Armwt + Neppv*Nemwt + ...
	Heppv*Hemwt + Krppv*Krmwt + H2ppv*H2mwt + Xeppv*Xemwt + ...
	CO2ppv*CO2mwt) / (N2ppv + O2ppv + Arppv + Neppv + Heppv + ...
			  Krppv + H2ppv + Xeppv + CO2ppv);

% Physics
k=1.3806503e-23; % Boltzmann [J / K]
Na=6.0221367e23; % Avogadro's number [#/mol]

% Wallace and Hobbs, p. 65
Rgas=k*Na;            % Universal gas constant [J / K / mol]
Rair=Rgas/Airmwt*1e3; % Dry air gas constant [J / K / kg]

% Standard Atmosphere Reference values
T0=273.15; % zero deg celcius [K]
Tstd=288.15;  % Temperature [K]
Pstd=101325.; % Pressure [Pa]

% Molar volume [m3/mol] at Pstd and T0
% Bodhaine et al, 1999
Mvol=22.4141e-3;

% Molecular density [#/m3] at Tstd and Pstd
Nstd=(Na/Mvol)*(T0/Tstd); 

%