% Function: 
%    function [fval, a, b, relerr] = fastfit(S, z)
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
function [a, b, fval, sa, sb, chi2red, ndf] = fastfit(X, Y)

% size of Y
[ny1, ny2] = size(Y);

% check if X was given, otherwise use indexes as coordenates
if ~exist('X','var') X(:,1)=(1:ny1)'; end

% size of X
[nx1, nx2] = size(X);

% error checking
if ny1~=nx1
  error('FASTFIT::','X must have the same number of rows as Y!');
end
if nx2~=1
  if ny2~=nx2
    error('FASTFIT::','X must have the same number of columns as Y!');
  end
end

% if only one column in X, that means all columns in Y correspond to
% the same X column.
if nx2==1
  for j=2:ny2
    X(:,j)=X(:,1);
  end
end

% if there is a NaN in Xij, it should be set in Yij, and vice-versa
% otherwise, the calulation below would be wrong (different number
% of valid data points in Y and X).
Y(isnan(X))=NaN;
X(isnan(Y))=NaN;

% calculate <X>, <X*X> and <X>^2
X2=X.*X;
Xmed=nanmean(X);
Xmed2=Xmed.*Xmed;
X2med=nanmean(X2);
clear X2;

% calculate <Y> and <X*Y> for all rows
Ymed=nanmean(Y);
XYmed=nanmean(Y.*X);

% Because all of our X and Y matrices are 1 x ny2, the solution can
% be found for all (i,j) points by just multiplying the matrices.
a=(XYmed-Xmed.*Ymed)./(X2med-Xmed2);
b=Ymed-a.*Xmed;
clear Xmed XYSmed;

% With the coefficients, calculate the value 
% interpolated at each Xij
fval = bsxfun(@plus, bsxfun(@times,X,a), b);

% Calculate squared errors at each ij
Err2=(Y-fval).^2;

% calculate degrees of freedom
N=nansum(~isnan(Y));
ndf=N-2*ones(1,ny2);

% calculate chi2red=Sum[(Y-fval)^2]
chi2red=nansum(Err2)./ndf;

% other errors
varx=X2med-Xmed2;
sa=sqrt(chi2red./varx./N);
sb=sa.*sqrt(X2med);
clear X2med Xmed2;

return
%end