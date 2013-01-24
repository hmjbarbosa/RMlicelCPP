% Function: 
%    function [nAir, dnAir] = refratindex(lambda, co2ppmv)
%
% Input:
%    lambda - wavelength in micrometers
%    co2ppmv - CO2 concentration in parts per million volume
%
% Output:
%    nAir - refractive index for dry air
%
% Description: 
%
%    This function calculates the refractive index of standard dry air
%    according to equations (2) and (3) Peck and Reeder
%    (1973). Standard dry air is defined to have pressure 1013.25 hPa
%    and temperature 15 degC. 
%
%    As noted by Bodhaine et al (1999), Peck and Reeder (1973) wrongly
%    quoted Edlen's (1966) formula to be at 330ppmv and not 300ppmv
%    as clearly stated by Edlen. Therefore, here we follow Bodhaine
%    and scale the result from 300ppmv of CO2 to whatever value
%    input by the user.
%
% Usage:
%
%    The wavelength, lambda, can be a single number or a matrix, in
%    which case the subroutine will calculate the refractive index for
%    each wavelength.
%
%      >> format long
%      >> refratindex([0.355 0.387 0.408], 375)           
%      ans =
%          1.000285711618120   1.000283499527122   1.000282344899086
%  
%    The co2 concentration, co2ppmv, as well can be a single number or
%    a matrix, in which case the subroutine will the refractive index
%    factor for each co2 concentration.
% 
%      >> refratindex(0.355, [375 800 1800])              
%      ans =
%          1.000285709303968   1.000285774871598   1.000285929148374
%
%    In the weird case that both lambda and co2 are matrices, then
%    they must be the same size! The function will then return
%    values for each pair of (lambda, co2ppmv).
%
%      >> refratindex([0.355 0.387 0.408], [375 800 1800])
%      ans =
%          1.000285709303968   1.000283562290867   1.000282559866045
%
% References:
%
%    Bodhaine et al, 1999: J. Atmos. Ocea. Tech, v. 16, p.1854
%    Bucholtz, 1995: App. Opt., v. 34 (15), p. 2765
%    Peck and Reeder, 1973: J. Opt. Soc. Ame., v 62 (8), p. 958
%
function [nAir] = refratindex(lambda, co2ppmv)

%% CALCULATE 1/LAMBDA^2
invl2=1./lambda.^2;

%% CALCULATE (n-1) at 300 ppmv CO2
% Peck and Reeder (1973), Eqs (2) and (3)
% or Bucholtz (1995), Eqs (4) and (5)
% or Bodhaine et al (1999), Eq (4)

if (lambda > 0.23)
  % lambda > 0.23 microns
  dn300 = (5791817 ./ (238.0185 - invl2) + ...
	167909 ./ (57.362 - invl2))*1e-8; 
else
  % lambda <= 0.23 microns
  dn300 = (8060.51 + 2480990 ./ (132.274 - invl2) + ...
	14455.7 ./ (39.32957 - invl2))*1e-8;
end

%% CORRECT FOR DIFFERENT CONCENTRATION
% or Bodhaine et al (1999), Eq (19)
dnAir = dn300 .* (1 + (0.54 * (co2ppmv*1e-6 - 0.0003)));

%% ACTUAL INDEX OF REFRACTION at 300 ppmv CO2
nAir = 1 + dnAir;

%