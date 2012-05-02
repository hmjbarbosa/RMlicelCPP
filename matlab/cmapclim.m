function [cmap, clim] = cmapclim(clev)

Nclev = length(clev);
clim = [min(clev) max(clev)];
dclev = min(diff(clev));
y = clim(1):dclev:clim(2);

for k=1:Nclev-1, y(y>clev(k) & y<=clev(k+1)) = clev(k+1); end % NEW
cmap2 = colormap(jet(Nclev));
cmap = [...
    interp1(clev(:),cmap2(:,1),y(:)) ...
    interp1(clev(:),cmap2(:,2),y(:)) ...
    interp1(clev(:),cmap2(:,3),y(:)) ...
        ];

