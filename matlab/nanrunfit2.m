% Function: 
%    function [fval, a, b, relerr] = runfit2(S, z, nside, nside2)
%
% Input:
%    S(nz, nt) - Input signal with nz levels and nt times
%    z(nz) - Range of each zi level
%    nside - Use 2*nside+1 points for the linear fit
%
% Output:
%    fval - fitted values interpolated at the original zi's
%    a - angular coeffient of the linear fit at each zi
%    b - linear coeffient of the linear fit at each zi
%    relerr - Sum_nside (S - fval)/Sum_nside S
%
% Description: 
%
%    Does a running un-weighted least square fit of S(z)=a*z + b, ie,
%    for each point zi in the vertical, fits a straight line using
%    nside points to the left and to the right of zi.
%
%    A linear fit results in a linear system of two equations and two
%    variables (a and b) which can be easily solved. The result, in
%    in a chi2 sense, is:
%
%       a = (<zS> - <z><S>)/(<z^2>-<z>^2)
%       b = (<z^2><S> - <z><zS>)/(<z^2>-<z>^2)
%
%    This allows one not to use fit() functions which would be very
%    slow because they actually search numerically for a minimum of
%    chi2 function. Instead, here the smooth() function is used with
%    SPAN=2*nside+1 to evaluate the running mean values in the
%    above equations.
%
function [fval, a, b, relerr, Smed] = nanrunfit2(S, z, nside, nside2)

[nz, nt] = size(S);

if ~exist('z','var') z(:,1)=(1:nz)'; end
if ~exist('nside','var') nside=5; end

S(isnan(z))=nan;
z(isnan(S))=nan;

% smooth(S,SPAN) is a running average using SPAN points. Therefore,
% for odd SPAN, the number of points on each side of central point is
% the same, i.e., (SPAN-1)/2
%span=1+2*nside;
span=nside;
span2=nside2;
% calculate <z>
zmed=nanmysmooth(z,span,span2);
% calculate <z>^2
zmed2=zmed.*zmed;
% calculate <z*z>
z2(:,1)=z(:,1).*z(:,1);
z2med=nanmysmooth(z2,span,span2);
clear z2;

% repeat the values on all nt rows
for j=2:nt
  z(:,j)=z(:,1);
  zmed(:,j)=zmed(:,1);
  zmed2(:,j)=zmed2(:,1);
  z2med(:,j)=z2med(:,1);
end

% calculate <S> and <z*S> for all nt rows
for j=1:nt
  Smed(:,j)=nanmysmooth(S(:,j),span,span2);
  zSmed(:,j)=nanmysmooth(S(:,j).*z(:,j),span,span2);
end

%
% Because all of our z and S matrices are nz x nt, the solution can
% be found for all (i,j) points by just multiplying the matrices.
%
a=(zSmed-zmed.*Smed)./(z2med-zmed2);
b=(Smed.*z2med-zmed.*zSmed)./(z2med-zmed2);
clear z2med zmed2 zmed zSmed;

% With the coefficients, calculate the value interpolated at each zi
% note: since dz is uniform, fval == Smed
fval = a.*z + b;

% calculate <abs(S-fval)>/<y> for all nt rows
Sfval=(S-fval).^2;
for j=1:nt
  % it is necessary to force 'moving average' because absolute
  % errors are random and smooth() algorithm would try to use
  % 'robust' method instead.
  Sfvalmed(:,j)=nanmysmooth(Sfval(:,j),span,span2);
end
relerr=sqrt(Sfvalmed);

clear Sfvalmed Sfval;
return
%