% Function: 
%    function [nAir, dnAir] = rayphase(lambda, co2ppmv)
%
% Input:
%    lambda - wavelength in micrometers
%    co2ppmv - CO2 concentration in parts per million volume
%
% Output:
%    nAir - refractive index for dry air
%    dnAir - just (nAir-1)
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
function [pray] = rayphase(theta, val, opt)

if (strcmp(opt,'rho'))
  rho=val;
  gamma=rho./(2-rho);
elseif (strcmp(opt,'gamma'))
  gamma=val;
else
  error(['unknown option: ' opt]);
end

pray = 0.75*((1+3.*gamma)+(1-gamma).*cos(theta)^2) ./ (1+2.*gamma);

%