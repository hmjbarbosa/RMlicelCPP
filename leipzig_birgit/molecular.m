%------------------------------------------------------------------------
% molecular.m
%
% 
%    Bates, 1984: Planet. Space Sci., v. 32, p. 785
%    Bodhaine et al, 1999: J. Atmos. Ocea. Tech, v. 16, p.1854
%    Bucholtz, 1995: App. Opt., v. 34 (15), p. 2765
%    Chandrasekhar, Radiative Transfer (Dover, New York, 1960)
%    Edlen, 1953: J. Opt. Soc. Amer., v. 43, p. 339
%    McCartney, E. J., 1976: Optics of the Atmosphere. Wiley, 408 pp.
%    Peck and Reeder, 1973: J. Opt. Soc. Ame., v 62 (8), p. 958
%
%------------------------------------------------------------------------
% first run the following programs:
%   
%    read_ascii_*.m
%    read_sonde_*.m
%------------------------------------------------------------------------

% Read Physics Constants
constants;

%------------------------------------------------------------------------
% User definitions
%------------------------------------------------------------------------
lambda_rayleigh=0.355; % Elastic [microns]
lambda_raman=0.387;    % Raman N2 [microns]
co2ppmv = 375; % CO2 concentration [ppmv]

lambda=[lambda_rayleigh lambda_raman];

%%------------------------------------------------------------------------
%% REFRACTIVE INDEX WITH CO2 CORRECTION 
%%------------------------------------------------------------------------

%% Calculate (n-1) at 300 ppmv CO2
%% Peck and Reeder (1973), Eqs (2) and (3)
%% or Bucholtz (1995), Eqs (4) and (5) 
%% or Bodhaine et al (1999), Eq (4)
if (lambda > 0.23)
  %% lambda > 0.23 microns
  dn300 = (5791817 ./ (238.0185 - 1./lambda.^2) + ...
	167909 ./ (57.362 - 1./lambda.^2))*1e-8; 
else
  %% lambda <= 0.23 microns
  dn300 = (8060.51 + 2480990 ./ (132.274 - 1./lambda.^2) + ...
	14455.7 ./ (39.32957 - 1./lambda.^2))*1e-8;
end

%% Correct for different concentration
%% Bodhaine et al (1999), Eq (19)
dnAir = dn300 .* (1 + (0.54 * (co2ppmv*1e-6 - 0.0003)));

%% Actual index of refraction at 300 ppmv CO2
nAir = 1 + dnAir;

%%------------------------------------------------------------------------
%% KING FACTOR AND DEPOLARIZATION RATIO
%%------------------------------------------------------------------------

% Bates (1984), Eqs (13) and (14)
% or Bodhaine et al (1999), Eqs (5) and (6)

% Nitrogen
fN2 = 1.034 + (3.17e-4 ./ (lambda.^2));
% Oxygen 
fO2 = 1.096 + (1.385e-3 ./ (lambda.^2)) + (1.448e-4 ./ (lambda.^4));
% Argon
fAr = 1;
% Carbon dioxide
fCO2 = 1.15;

% Bodhaine et al (1999) Eq (23)
% NOTE: numerator and denominator are not written in percent

% Standard dry air mixture with co2ppmv
fAir = (N2ppv*fN2 + O2ppv*fO2 + Arppv*fAr + co2ppmv*1e-6*fCO2)./...
       (N2ppv     + O2ppv     + Arppv     + co2ppmv*1e-6);
%
% Depolarization ratio estimated from King's factor
%
% hmjb - What is the correct way?
%rhoN2  = (6*fN2 -6)./(3+7*fN2 );
%rhoO2  = (6*fO2 -6)./(3+7*fO2 );
%rhoCO2 = (6*fCO2-6)./(3+7*fCO2);
%rhoAr  = (6*fAr -6)./(3+7*fAr );
%rhoAir = (0.78084*rhoN2+0.20946*rhoO2+0.00934*rhoAr+co2ppmv*1e-6*rhoCO2)/...
%	  (0.78084      +0.20946      +0.00934      +co2ppmv*1e-6)
%
% hmjb - What is the correct way?
rhoAir = (6*fAir-6)./(3+7*fAir);

%%------------------------------------------------------------------------
%% RAYLEIGH PHASE FUNCTION AT 180deg
%%------------------------------------------------------------------------

% Chandrasekhar (Chap. 1, p. 49)
% or Bucholtz (1995), eqs (12) and (13)
gammaAir = rhoAir./(2-rhoAir);
P_Ray = 0.75*((1+3.*gammaAir)+(1-gammaAir)*(cos(pi)^2))./(1+2.*gammaAir);

%%------------------------------------------------------------------------
%% RAYLEIGH TOTAL SCATERING CROSS SECTION
%%------------------------------------------------------------------------

% McCartney (1976)
% units: lambda*1e-6 [m], Nstd*1e6 [#/m^3]
% hence sigma_s is in [m2]
sigma_std = 24 * (pi^3) * ((nAir.^2-1).^2) .* fAir ./...
    ( ((lambda*1e-6).^4) .* ((Nstd*1e6)^2) .* (((nAir.^2)+2).^2) );

%%------------------------------------------------------------------------
%% RAYLEIGH VOLUME-SCATTERING COEFFICIENT
%%------------------------------------------------------------------------

% In traditional lidar notation, Bucholtz (1995) eqs (2), (9) and (10)
% defines the scattering part of the molecular extinction coeficient.
% Therefore, here the usual greek letter 'alpha' is used instead of
% 'beta' as in Bucholtz.

% Bucholtz (1995), eq (9), units [km^-1]
% factor 1e6 converts #/cm^3 to #/m^3
alpha_std = Nstd*1e6 * sigma_std * 1000.; 
% Bucholtz (1995), eq (10), units [km^-1]
% scaling for each P and T in the column 
alpha_mol_snd = ((pres_snd./temp_snd) * Tstd/Pstd) * alpha_std;

%%------------------------------------------------------------------------
%% RAYLEIGH ANGULAR VOLUME-SCATTERING COEFFICIENT
%%------------------------------------------------------------------------

% Rayleigh extinction to backscatter ratio
% ie, Rayleigh lidar ratio [sr]
LR_mol = (4*pi)./P_Ray; 

% In traditional lidar notation, Bucholtz (1995) eq (14) defines the
% backscattering coeficient. Here the usual greek letter 'beta' is
% used as in Bucholtz.

% Multiply by phase function for -180deg and divide by 4pi steradians 
% Units: [km]-1 [sr]-1
beta_mol_snd = alpha_mol_snd*diag(P_Ray)/(4*pi); 

%
