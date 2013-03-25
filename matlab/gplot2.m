% Makes a 2D color shaded plot from a matrix. If not give, it will
% comput the X- and Y-axis automatically, as well as the contour
% levels. Because built-in contourf() function is VERY slow with
% large matrices, now we use imsc:
% http://www.mathworks.com/matlabcentral/fileexchange/16233-sc-powerful-image-rendering
function [C, h, bar] = gplot2(mat2d, clev, X, Y)

[nz nt] = size(mat2d);

if ( nz==1 || nt==1 )
  ['Matrix must be 2D!']
  return
end

if ~exist('X','var') X=[1:nt]; end;
if ~exist('Y','var') Y=[1:nz]; end;
if (size(mat2d,2)~=nt)
  disp('Error: X and mat2d must have the same number of columns');
  return
end
if (size(mat2d,1)~=nz)
  disp('Error: Y and mat2d must have the same number of lines');
  return
end

if ~exist('clev','var') || numel(clev)==0
  q=quantile(nanmax(mat2d), [0.5 0.95]);
  vmax=q(2);
  dv=vmax/50.;
  clev=[0:dv:vmax];
end
[cmap, clim]=cmapclim(clev);

imsc(X, Y, mat2d,clim,cmap,[1 1 1]);
set(gca,'YDir','normal');

colormap(min(max(cmap,0),1));
caxis(clim);
bar = colorbar;

%fim
