%
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

clear cte
j=0;

%------------------------------------------------------------------------
% Fixed definitions
%------------------------------------------------------------------------

% Atmospheric Constituents Concentration
% ref: Seinfeld and Pandis (1998)
j=j+1;
cte.units{j,1}='gas';
cte.units{j,2}='Name';
cte.units{j,3}='[]';
j=j+1;
cte.units{j,1}='ppv';
cte.units{j,2}='Concentration';
cte.units{j,3}='[ppv]';
% Atmospheric Constituents Molecular weight
% ref: Handbook of Physics and Chemistry (CRC 1997)
j=j+1;
cte.units{j,1}='mwt';
cte.units{j,2}='Molecular weight';
cte.units{j,3}='[kg / mol]';
%
cte.gas{1}='N2';  cte.ppv(1)=0.78084;  cte.mwt(1)=28.013e-3;
cte.gas{2}='O2';  cte.ppv(2)=0.20946;  cte.mwt(2)=31.999e-3;
cte.gas{3}='Ar';  cte.ppv(3)=0.00934;  cte.mwt(3)=39.948e-3;
cte.gas{4}='Ne';  cte.ppv(4)=1.80e-5;  cte.mwt(4)=20.180e-3;
cte.gas{5}='He';  cte.ppv(5)=5.20e-6;  cte.mwt(5)=4.0030e-3;
cte.gas{6}='Kr';  cte.ppv(6)=1.10e-6;  cte.mwt(6)=83.800e-3;
cte.gas{7}='H2';  cte.ppv(7)=5.80e-7;  cte.mwt(7)=2.0160e-3;
cte.gas{8}='Xe';  cte.ppv(8)=9.00e-8;  cte.mwt(8)=131.29e-3;
cte.gas{9}='CO2'; cte.ppv(9)=4.00e-4;  cte.mwt(9)=44.010e-3; 

% force normalization depending of CO2 concentration
cte.ppv=cte.ppv/sum(cte.ppv);

% Now add dry air
cte.gas{10}='Air';
cte.mwt(10)=sum(cte.ppv.*cte.mwt)/sum(cte.ppv);
cte.ppv(10)=sum(cte.ppv);

% Physics
j=j+1;
cte.units{j,1}='k';
cte.units{j,2}='Boltzmann constant';
cte.units{j,3}='[J / K]';
cte.k=1.3806503e-23;

j=j+1;
cte.units{j,1}='Na';
cte.units{j,2}='Avogadro number';
cte.units{j,3}='[# / mol]';
cte.Na=6.0221367e23;

% Wallace and Hobbs, p. 65
j=j+1;
cte.units{j,1}='Rgas';
cte.units{j,2}='Universal gas constant';
cte.units{j,3}='[J / K / mol]';
cte.Rgas=cte.k*cte.Na;

j=j+1;
cte.units{j,1}='Rair';
cte.units{j,2}='Dry air gas constant';
cte.units{j,3}='[J / K / kg]';
cte.Rair=cte.Rgas/cte.mwt(10);

% Standard Atmosphere Reference values
j=j+1;
cte.units{j,1}='T0';
cte.units{j,2}='Water freezing point';
cte.units{j,3}='[K]';
cte.T0=273.15;

j=j+1;
cte.units{j,1}='Tstd';
cte.units{j,2}='Standard temperature';
cte.units{j,3}='[K]';
cte.Tstd=288.15;

j=j+1;
cte.units{j,1}='Pstd';
cte.units{j,2}='Standard pressure';
cte.units{j,3}='[Pa]';
cte.Pstd=101325.;

% Bodhaine et al, 1999, but at Tstd and Pstd
j=j+1;
cte.units{j,1}='Mvol';
cte.units{j,2}='Standard molar volume';
cte.units{j,3}='[m3 / mol]';
cte.Mvol=22.4141e-3*cte.Tstd/cte.T0;

% Bodhaine et al, 1999, at Tstd and Pstd
j=j+1;
cte.units{j,1}='Nstd';
cte.units{j,2}='Standard molecular density';
cte.units{j,3}='[# / m3]';
cte.Nstd=cte.Na/cte.Mvol; 

%
cte
[[cte.units{1,:} cte.gas]', [cte.units{2,:} num2cell(cte.ppv)]', [cte.units{3,:} num2cell(cte.mwt)]']
cte.units
%