% Function: 
%    function [fAir] = kingfactor(lambda, co2ppmv)
%
% Input:
%    lambda - wavelength in micrometers
%    co2ppmv - CO2 concentration in parts per million volume
%
% Output:
%    fAir - King factor for dry air
%    rhoAir - depolarization ratio
%
% Description: 
%
%    The total crossection for molecular scattering of light has a
%    correction term known as King factor, F(air) or just
%    depolarization term:
%
%            King factor = (6 + 3 rho)/(6 - 7 rho)
%
%    where rho depends on wavelength and is known as the
%    depolarization factor or depolarization ratio and describes the
%    effect of molecular anisotropy.
%
%    This function calculates the King factors of each gas in the
%    atmosphere according to the empirical equations of Bates (1984)
%    and combine them as suggested by Bodhaine et al (1999) to obtain
%    the King factor for the dry air mixture.
%
%    The above equation is then inverted, yielding
%
%                rho = (6 King - 6)/(3 + 7 King)
%
%    the depolarization ratio of each species...
%    
%
% Usage:
%
%    The wavelength, lambda, can be a single number or a matrix, in
%    which case the subroutine will calculate king's factor for
%    each wavelength.
%
%      >> kingfac([0.355 0.387 0.408], 375)           
%      ans =
%          1.0529    1.0517    1.0510
%  
%    The co2 concentration, co2ppmv, as well can be a single number or
%    a matrix, in which case the subroutine will calculate king's
%    factor for each concentration of co2.
% 
%      >> kingfac(0.355, [375 800 1800])              
%      ans =
%          1.0529    1.0529    1.0530
%
%    In the weird case that both lambda and co2 are matrices, then
%    they must be the same size! The function will then return
%    values for each pair of (lambda, co2ppmv).
%
%      >> kingfac([0.355 0.387 0.408], [375 800 1800])
%      ans =
%          1.0529    1.0517    1.0512
%
% References:
%
%    Bodhaine et al, 1999: J. Atmos. Ocea. Tech, v. 16, p.1854
%    Bates, 1984: Planet. Space Sci., v. 32, p. 785
%
function [fAir, rhoAire] = kingfactor(lambda, co2ppmv)

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
fAir = (0.78084*fN2 + 0.20946*fO2 + 0.00934*fAr + co2ppmv*1e-6*fCO2)./...
       (0.78084     + 0.20946     + 0.00934     + co2ppmv*1e-6);
%
% Depolarization ratio estimated from King's factor
rhoN2  = (6*fN2 -6)./(3+7*fN2 );
rhoO2  = (6*fO2 -6)./(3+7*fO2 );
rhoCO2 = (6*fCO2-6)./(3+7*fCO2);
rhoAr  = (6*fAr -6)./(3+7*fAr );
% hmjb - What is the correct way?
rhoAir = (0.78084*rhoN2+0.20946*rhoO2+0.00934*rhoAr+co2ppmv*1e-6*rhoCO2)/...
	 (0.78084      +0.20946      +0.00934      +co2ppmv*1e-6)
% hmjb - What is the correct way?
rhoAire = (6*fAir-6)./(3+7*fAir)
%