function [h, bar] = gplot2(mat2d, clev, X, Y)
% GPLOT2   shaded 2d plot
%    GPLOT2(mat2d, clev, X, Y) displays mat2d as a 2D color shaded
%    plot with contour levels specified clev and using X and Y as x-
%    and y-axis coordinates. A colorbar as added to the plot. Because
%    built-in contourf() function is VERY slow with large matrices, it
%    uses imsc() which must be available in your path:
%
%    http://www.mathworks.com/matlabcentral/fileexchange/16233-sc-powerful-image-rendering
%
%    If not given, the position index will be used as X- and Y-axis
%    coordinates. If not given, 100 contour levels distributed
%    between the 5 and 95% quantile will be used.
%
%    Examples:
%       [h, bar] = gplot2(...)
%       returns the handles to the figure and color bar.
%
%       gplot2(mat2d,[],X,Y)
%       uses X and Y ass coordinates, but calculate the contour
%       levels
%
%    See also IMSC.
%
[nx ny] = size(mat2d);

if ( nx==1 || ny==1 )
  ['Error: Matrix must be 2D!']
  return
end

if (~exist('X','var') || numel(X)==0) X=[1:nx]; end;
if (~exist('Y','var') || numel(Y)==0) Y=[1:ny]; end;
if (size(mat2d,1)~=numel(X))
  disp('Error: X and mat2d must have the same number of lines');
  return
end
if (size(mat2d,2)~=numel(Y))
  disp('Error: Y and mat2d must have the same number of columns');
  return
end

if ~exist('clev','var') || numel(clev)==0
  q=quantile(reshape(mat2d,numel(mat2d),1), [0.05 0.95]);
  dv=(q(2)-q(1))/50.;
  clev=[q(1):dv:q(2)];
end
[cmap, clim]=cmapclim(clev);

h=imsc(X, Y, mat2d,clim,cmap,[1 1 1]);
set(gca,'YDir','normal');

colormap(min(max(cmap,0),1));
caxis(clim);
endbar = colorbar;
% Don't display the handle if not requested
if nargout < 1
  clear h;
end
if nargout < 2
  clear colorbar
end

    

%end
