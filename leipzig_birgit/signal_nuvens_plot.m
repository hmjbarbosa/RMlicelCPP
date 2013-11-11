figure(1); clf
set(gcf,'position',[0,300,900,300]); % units in pixels!
set(gcf,'PaperUnits','inches','PaperSize',[12,4],'PaperPosition',[0 0 12 4])

clev=[0:0.05:5];
[cmap, clim]=cmapclim(clev);
imsc(tt,zz(minbin:maxbin),Pr2(minbin:maxbin,:),clim,cmap,...
     [1. 1. 1.],isnan(Pr2(minbin:maxbin,:)),...
     [.7 .7 .7],logical(Pr2(minbin:maxbin,:)==-100))
set(gca,'YDir','normal');
colormap(min(max(cmap,0),1));
caxis(clim);
bar = colorbar;
set(get(bar,'ylabel'),'String','Backscatter (Mm^{-1} sr^{-1})','fontsize',14);

set(gca,'fontsize',12)
datetick('x','mm/dd')
ylabel('Altitude agl (km)','fontsize',14)
tmp=datevec(jdi);
out=sprintf('faraday_cirrus_%4d_%02d_%02d_overlap.png', tmp(1),tmp(2),tmp(3));
print(out,'-dpng')
eval(['!mogrify -trim ' out])

%
