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
constants;

%------------------------------------------------------------------------
% User definitions
%------------------------------------------------------------------------
lambda_rayleigh=0.355; % Elastic [microns]
lambda_raman=0.387;    % Raman N2 [microns]
co2ppmv = 390; % CO2 concentration [ppmv]

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
  dn300 = (5791817 ./ (238.0185 - invl2) + ...
	167909 ./ (57.362 - invl2))*1e-8; 
else
  %% lambda <= 0.23 microns
  dn300 = (8060.51 + 2480990 ./ (132.274 - invl2) + ...
	14455.7 ./ (39.32957 - invl2))*1e-8;
end

%% Correct for different concentration
%% or Bodhaine et al (1999), Eq (19)
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
P_Ray = 0.75*((1+3.*gammaAir)+(1-gammaAir).*cos(pi)^2) ./ (1+2.*gamma);

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
% Therefore, here the usual term 'alpha' is used.

% For the standard atmosphere, [1/m]
alpha_std = Nstd*1e6 * sigma_std; 
% For the whole column
for ii = 1:length(lambda)
  betamol_s(:,ii) = beta_s(ii) * ((pres./temp) * Tstd/Pstd); 
end

%%------------------------------------------------------------------------
%% RAYLEIGH ANGULAR VOLUME-SCATTERING COEFFICIENT
%%------------------------------------------------------------------------


%Rayleigh angular volume scattering coefficient(Coeficiente de dispersion
%molecular total o extinción molecular. [m]-1 [sr]-1
  for ie = 1:length(lambda)
      betamol_theta(:,ie) = (betamol_s(:,ie)./4*pi).*P_Ray(ie); %*sind(12.475); %Caso de inclinación del sistema lidar.
  end
%  plot(altitude,betamol_s(:,1)); xlim([1 10000]);

%Rayleigh extinction to backscatter ratio, Rayleigh lidar ratio... S_mol= betamol_S/betamol_theta  [sr] error en l medida de Re..
  S_mol = (4*pi)./P_Ray; % Es acosejable usar de esta manera en vez de (8/3)pi = 8.377 sr pues eso introduce un error de 1.5 % en la mayoria de las lambdas de los lidares