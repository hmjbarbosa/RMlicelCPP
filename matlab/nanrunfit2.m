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
function [fval, a, b, relerr, Ymed] = nanrunfit2(Y, X, nside, nside2)

[nX, nt] = size(Y);

if ~exist('X','var') X(:,1)=(1:nX)'; end
if ~exist('nside','var') nside=5; end

Y(isnan(X))=nan;
X(isnan(Y))=nan;

% smooth(Y,SPAN) is a running average using SPAN points. Therefore,
% for odd SPAN, the number of points on each side of central point is
% the same, i.e., (SPAN-1)/2
%span=1+2*nside;
span=nside;
span2=nside2;
% calculate <X>
Xmed=nanmysmooth(X,span,span2);
% calculate <X>^2
Xmed2=Xmed.*Xmed;
% calculate <X*X>
X2(:,1)=X(:,1).*X(:,1);
X2med=nanmysmooth(X2,span,span2);
clear X2;

% repeat the values on all nt rows
for j=2:nt
  X(:,j)=X(:,1);
  Xmed(:,j)=Xmed(:,1);
  Xmed2(:,j)=Xmed2(:,1);
  X2med(:,j)=X2med(:,1);
end

% calculate <Y> and <X*Y> for all nt rows
for j=1:nt
  Ymed(:,j)=nanmysmooth(Y(:,j),span,span2);
  XYmed(:,j)=nanmysmooth(Y(:,j).*X(:,j),span,span2);
end

%
% Because all of our X and Y matrices are nX x nt, the solution can
% be found for all (i,j) points by just multiplying the matrices.
%
a=(XYmed-Xmed.*Ymed)./(X2med-Xmed2);
%b=(Ymed.*X2med-Xmed.*XYmed)./(X2med-Xmed2);
%clear X2med Xmed2 Xmed XYmed;
b=Ymed-a.*Xmed;
clear Xmed XYmed;

% With the coefficients, calculate the value interpolated at each Xi
% note: IF dX is varying uniformly (e.g heights), fval == Ymed
% but IF X is the molecular signal, then fval != Ymed
fval = a.*X + b;

% Calculate squared errors at each ij
Err2=(Y-fval).^2;

for j=1:nt
  % it is necessary to force 'moving average' because absolute
  % errors are random and smooth() algorithm would try to use
  % 'robust' method instead.
  Err2med(:,j)=nanmysmooth(Err2(:,j),span,span2);
end
relerr=sqrt(Err2med);

clear Err2med Err2;
return
%