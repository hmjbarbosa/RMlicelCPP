% Function: 
%    function [fval, a, b, r2] = findclouds2(S, z, sidepoint)
%
% Input:
%    S(nz, nt) - Input signal with nz levels and nt times
%    z(nz) - Range of each level
%    sidepoint - Use 2*sidepoint+1 points for the linear fit
%
% Output:
%    fval - fitted values interpolated at the original zi's
%    a - angular coeffient of the linear fit at each zi
%    b - linear coeffient of the linear fit at each zi
%    r2 - R squared of the linear fit at each zi
%
% Description: 
%
%    Does a running un-weighted least square fit of S(z)=a*z + b, ie,
%    for each point zi in the vertical, fits a straight line using
%    sidepoint points to the left and to the right of zi.
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
%    SPAN=2*sidepoint+1 to evaluate the running mean values in the
%    above equations.
%
function [fval, a, b, r2] = findclouds2(S, z, sidepoint)

[nz, nt] = size(S);

if ~exist('z','var') z(:,1)=(1:nz)'; end
if ~exist('sidepoint','var') sidpoint=5; end

% squared distance
z2(:,1)=z(:,1).*z(:,1);

% smooth(S,SPAN) is a running average using SPAN points. Therefore,
% for even SPAN, the number of points on each side of central point is
% the same, i.e., (SPAN-1)/2
span=1+2*sidepoint;
% calculate <z>, <z*z> and <z>^2
zmed=smooth(z,span);
zmed2=zmed.*zmed;
z2med=smooth(z2,span);

% repeat the values on all nt rows
for j=2:nt
  z(:,j)=z(:,1);
  zmed(:,j)=zmed(:,1);
  zmed2(:,j)=zmed2(:,1);
  z2med(:,j)=z2med(:,1);
end

% calculate <S> and <z*S> for all nt rows
for j=1:nt
  Smed(:,j)=smooth(S(:,j),span);
  zSmed(:,j)=smooth(S(:,j).*z(:,1),span);
end

%
% Because all of our z and S matrices are nz x nt, the solution can
% be found for all (i,j) points by just multiplying the matrices.
%
a=(zSmed-zmed.*Smed)./(z2med-zmed2);
b=(Smed.*z2med-zmed.*zSmed)./(z2med-zmed2);

% With the coefficients, calculate the value interpolated at each zi
for j=1:nt
  for i=1:nz
    fval(i,j)=a(i,j)+b(i,j)*z(i,j);
  end
end

return
% finite difference of the log of the raw signal
tmp=diff((S));

tmp2=smooth(tmp, 5);

tmp3=abs(tmp-tmp2);

tmp4=smooth(tmp3, 10);

%q=quantile(tmp4,[0.159, 0.841])
%sig=(q(2)-q(1))/2

figure(1)
%plot(tmp2(1:700))

figure(2)
%plot(abs(diff(tmp4(1:700))))

figure(3)
tmp4=tmp4(1:3000);
points=(1:3000)';

key=0;
while(key == 0)

%  ymed=nanmean(tmp4);
%  ysd=nanttd(tmp4);
q=quantile(tmp4,[0 0.5 1]);
ymed=q(2);
y0=q(1);
y1=q(3);

ylim=ymed+(ymed-y0);

sig=nanttd(tmp4)+nanmean(tmp4);

  plot(points(1:700),tmp4(1:700),'o-', ...
       points(1:700),ymed,'b-',...
       points(1:700),y0  ,'g-',...
       points(1:700),y1  ,'r-',...
       points(1:700),ylim,'m-')
return
  key = waitforbuttonpress;

  if (key==0)
    for i=size(points):-1:1  
      if (tmp4(i)>ylim)
        tmp4(i)=NaN;
      end
    end
  end

end
  
figure(3)
plot(tmp4(1:400))


%fim