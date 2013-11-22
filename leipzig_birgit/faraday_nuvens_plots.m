%% This routine takes the matrix prepared by faraday_nuvens.m and
% make the plots for the paper. It read the sonde data as well so
% that we can have the tropopause line and the line for -25degC.
figure(1); clf
set(gcf,'position',[0,300,900,300]); % units in pixels!
set(gcf,'PaperUnits','inches','PaperSize',[12,4],'PaperPosition',[0 0 12 4])

clev=[2:0.01:6];
[cmap, clim]=cmapclim(clev);
imsc(tt,zz,Pr2,clim,cmap,...
     [1. 1. 1.],isnan(Pr2),...
     [.7 .7 .7],Pr2==-100)
set(gca,'YDir','normal');
colormap(min(max(cmap,0),1));
caxis(clim);
bar = colorbar;
set(get(bar,'ylabel'),'String','Log Range Corrected Signal (a.u.)','fontsize',14);

set(gca,'fontsize',12)
datetick('x','mm/dd')
xlim([jdi jdf]);
ylabel('Altitude agl (km)','fontsize',14)

hold on;
plot(time,base*1e-3,'+k');
plot(time,topo*1e-3,'.m');

load faraday_sonde.mat
plot(jdsonde,temp25_alt*1e-3,'-g','linewidth',2);
plot(jdsonde,tropo_alt*1e-3,'--g','linewidth',2);

tmp=datevec(jdi);
out=sprintf('faraday_cirrus_%4d_%02d_%02d_overlap.png', tmp(1),tmp(2),tmp(3));
print(out,'-dpng')
eval(['!mogrify -trim ' out])

%
