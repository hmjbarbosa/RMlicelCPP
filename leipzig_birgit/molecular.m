%------------------------------------------------------------------------
% M-File:
%    molecular.m
%
% Authors:
%    H.M.J. Barbosa (hbarbosa@if.usp.br), IF, USP, Brazil
%    B. Barja (bbarja@gmail.com), GOAC, CMC, Cuba
%    R. Costa (re.dacosta@gmail.com), IPEN, Brazil
%
% Description
%
%    Takes temperature and pressure from the reference sounding and
%    calculates the refractive index, king's correction factor,
%    depolarization ratio, molecular phase function and cross-section
%    and, finally, molecular backscatter and extinction coefficients.
%
% Input
%
%    nlev_snd - number of levels in sounding
%    pres_snd(nlev_snd, 1) - column with pressure in Pa
%    temp_snd(nlev_snd, 1) - column with temperature in K
%
% Ouput
%
%    lambda   (1, 2) - wavelengths [m]
%    nAir     (1, 2) - index of refraction []
%    fAir     (1, 2) - king factor of air []
%    rhoAir   (1, 2) - depolarization factor of air []
%    Pf_mol   (1, 2) - phase function at -180deg []
%    LR_mol   (1, 2) - molecular lidar ratio [sr]
%
%    alpha_mol_snd(nlev_snd, 2) - extinction coefficient [m^-1]
%    beta_mol_snd (nlev_snd, 2) - backscatter coefficient [m^-1 sr^-1]
%
% Usage
%
%    First run: 
%
%        constants.m
%        read_sonde_*.m
%
%    This will set nlev_snd, pres_snd and temp_snd, the number of
%    levels in the souding data, the pressure and temperature in each
%    level, respectively. User must also change the code to set the
%    elastic and raman wavelengths.
%
% References
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
function [mol] = molecular(lambda, snd, cte, debug)

%------------------------------------------------------------------------
% User definitions (should be done before calling the routine)
%------------------------------------------------------------------------

% tipical: 354.68 386.73 532.06 607.4 1064.09 * 1e-6
% Units should be [m]. Example:
%
% lambda=[0.355 0.387 0.408]*1e-6; % [m]
mol.lambda = lambda;

disp(['molecular:: wlen = ' num2str(lambda*1e6) ' um']);

%%------------------------------------------------------------------------
%% REFRACTIVE INDEX WITH CO2 CORRECTION 
%%------------------------------------------------------------------------

%% Calculate (n-1) at 300 ppmv CO2
%% Peck and Reeder (1973), Eqs (2) and (3)
%% or Bucholtz (1995), Eqs (4) and (5) 
%% or Bodhaine et al (1999), Eq (4)
if (lambda > 0.23e-6)
  %% lambda > 0.23 microns
  mol.dn300 = (5791817 ./ (238.0185 - 1./(lambda*1e6).^2) + ...
	167909 ./ (57.362 - 1./(lambda*1e6).^2))*1e-8; 
else
  %% lambda <= 0.23 microns
  mol.dn300 = (8060.51 + 2480990 ./ (132.274 - 1./(lambda*1e6).^2) + ...
	14455.7 ./ (39.32957 - 1./(lambda*1e6).^2))*1e-8;
end

%% Correct for different concentration of CO2
%% Bodhaine et al (1999), Eq (19)
mol.dnAir = mol.dn300 .* (1 + (0.54 * (cte.CO2ppv - 0.0003)));

%% Actual index of refraction at 300 ppmv CO2
mol.nAir = 1 + mol.dnAir;

%%------------------------------------------------------------------------
%% KING FACTOR AND DEPOLARIZATION RATIO
%%------------------------------------------------------------------------

% Bates (1984), Eqs (13) and (14)
% or Bodhaine et al (1999), Eqs (5) and (6)

% Nitrogen
mol.fN2 = 1.034 + (3.17e-4 ./ ((lambda*1e6).^2));
% Oxygen 
mol.fO2 = 1.096 + (1.385e-3 ./ ((lambda*1e6).^2)) + (1.448e-4 ./ ((lambda*1e6).^4));
% Argon
mol.fAr = 1.0*ones(size(lambda));
% Carbon dioxide
mol.fCO2 = 1.15*ones(size(lambda));

% Bodhaine et al (1999) Eq (23)
% NOTE: numerator and denominator are not written in percent

% Standard dry air mixture with co2ppmv
mol.fAir = (cte.N2ppv*mol.fN2 + cte.O2ppv*mol.fO2 + cte.Arppv*mol.fAr ...
	    + cte.CO2ppv*mol.fCO2)./ (cte.N2ppv     + cte.O2ppv ...
				      + cte.Arppv     + cte.CO2ppv);
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
mol.rhoAir = (6*mol.fAir-6)./(3+7*mol.fAir);

%%------------------------------------------------------------------------
%% RAYLEIGH PHASE FUNCTION AT 180deg
%%------------------------------------------------------------------------

% Chandrasekhar (Chap. 1, p. 49)
% or Bucholtz (1995), eqs (12) and (13)
mol.gammaAir = mol.rhoAir./(2-mol.rhoAir);
mol.Pf_mol = 0.75*((1+3.*mol.gammaAir)+(1-mol.gammaAir)*(cos(pi)^2))./(1+2.*mol.gammaAir);

%%------------------------------------------------------------------------
%% RAYLEIGH TOTAL SCATERING CROSS SECTION
%%------------------------------------------------------------------------

% McCartney (1976)
% units: lambda [m], Nstd [#/m^3]
% hence sigma_std is in [m2]
mol.sigma_std = 24 * (pi^3) * ((mol.nAir.^2-1).^2) .* mol.fAir ./...
    ( (lambda.^4) .* (cte.Nstd^2) .* (((mol.nAir.^2)+2).^2) );

%%------------------------------------------------------------------------
%% RAYLEIGH VOLUME-SCATTERING COEFFICIENT
%%------------------------------------------------------------------------

% In traditional lidar notation, Bucholtz (1995) eqs (2), (9) and (10)
% defines the scattering part of the molecular extinction coeficient.
% Therefore, here the usual greek letter 'alpha' is used instead of
% 'beta' as in Bucholtz.

% Bucholtz (1995), eq (9), units [m^-1]
% Nstd was calculated in #/m^3
mol.alpha_std = cte.Nstd * mol.sigma_std; 
disp(['molecular:: alpha_std = ' num2str(mol.alpha_std*1e6) ' Mm^-1']);

% Bucholtz (1995), eq (10), units [m^-1]
% scaling for each P and T in the column 
% pres_snd in Pa
% temp_snd in K  -> see units in constants.m
mol.alpha_mol_snd = ((snd.pres./snd.temp) * cte.Tstd/cte.Pstd) * mol.alpha_std;

%%------------------------------------------------------------------------
%% RAYLEIGH ANGULAR VOLUME-SCATTERING COEFFICIENT
%%------------------------------------------------------------------------

% Rayleigh extinction to backscatter ratio
% ie, Rayleigh lidar ratio [sr]
mol.LR_mol = (4*pi)./mol.Pf_mol; 

% In traditional lidar notation, Bucholtz (1995) eq (14) defines the
% backscattering coeficient. Here the usual greek letter 'beta' is
% used as in Bucholtz.

% Multiply by phase function for -180deg and divide by 4pi steradians 
% Units: [m]-1 [sr]-1
mol.beta_mol_snd = mol.alpha_mol_snd*diag(mol.LR_mol.^-1); 

%
