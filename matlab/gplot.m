function [C, h, bar] = gplot(mat2d, clev, X, Y)

[nz nt] = size(mat2d);

if ( nz==1 || nt==1 )
  ['Matrix must be 2D!']
  return
end

if ~exist('X','var') X=[1:nt]; end;
if ~exist('Y','var') Y=[1:nz]; end;

if ~exist('clev','var') || numel(clev)==0
  q=quantile(max(mat2d), [0.5 0.75]);
  dv=(q(2)-q(1))/5;
  vmax=q(2);
  clev=[0:dv:vmax];
%  clev=unique(quantile(reshape(mat2d,nz*nt,1), (0:0.02:1)));
end

[cmap, clim]=cmapclim(clev);

[C, h]=contourf(X, Y, mat2d,clev);
set(h,'edgecolor','none');

colormap(min(max(cmap,0),1));
caxis(clim);
bar = colorbar;

['fim']

%fim
