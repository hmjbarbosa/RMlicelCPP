%% This routine prepares 4 plots for the lidar paper #1 % All
% comparing lidar and aeronet AOD. First need to run faraday_aeronet.m

%----------------------------------------------------------------
figure(1); clf;
x1=min(min(rmsaod));
x2=max(max(rmsaod));
[h, bar]=gplot2(rmsaod,(x1:(x2-x1)/100:x2),twid,minbin*7.5e-3);
hxl=xlabel('Averaging time window [min]');
hyl=ylabel('Height of constant extinction layer [km]');
hzl=ylabel(bar,'AOD RMSE Lidar - Aeronet ');
grid on;

set(gca, ...
    'FontName'    , 'Helvetica', ...
    'FontSize'    , 12        , ...
    'Box'         , 'on'      , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'LineWidth'   , 1         );

set([hxl, hyl, hzl], 'FontName', 'AvantGarde', 'FontSize', 14);
set(bar            , 'FontName', 'AvantGarde', 'FontSize', 12);
                  
set(gcf, 'PaperPositionMode', 'auto');
%print -dpdf finalPlot1.pdf
print -r300 -dpng faraday_aod_rmse.png

%----------------------------------------------------------------
figure(2); clf;
x1=min(min(corraod));
x2=max(max(corraod));
[h, bar]=gplot2(corraod,(x1:(x2-x1)/100:x2),twid,minbin*7.5e-3);
hxl=xlabel('Averaging time window [min]');
hyl=ylabel('Height of constant extinction layer [km]');
hzl=ylabel(bar,'Correlation AOD Lidar x Aeronet ');
grid on;

set(gca, ...
    'FontName'    , 'Helvetica', ...
    'FontSize'    , 12        , ...
    'Box'         , 'on'      , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'LineWidth'   , 1         );

set([hxl, hyl, hzl], 'FontName', 'AvantGarde', 'FontSize', 14);
set(bar            , 'FontName', 'AvantGarde', 'FontSize', 12);
                  
set(gcf, 'PaperPositionMode', 'auto');
%print -dpdf finalPlot1.pdf
print -r300 -dpng faraday_aod_correlation.png

%----------------------------------------------------------------
figure(3); clf
h=scatter(meanklett(:,11,30), aod355, 20, aerojd-4./24,'o','fill');
hold on;
X=(0:0.1:0.8);
xlim([min(X) max(X)]);
ylim([min(X) max(X)]);
pline=plot(X,X,'--k','LineWidth',2);
% fit 
[obj, gof, out] = fit(meanklett(~idx,11,30),aod355(~idx),'poly1');
pfit=plot(obj,'r');
set(pfit,'LineWidth',2);
M=confint(obj);
line{1}=['Aeronet = p1 * Lidar + p2'];
line{2}=[sprintf('p1 = %5.3f (%5.3f, %5.3f)',obj.p1,M(1,1),M(2,1))];
line{3}=[sprintf('p2 = %5.3f (%5.3f, %5.3f)',obj.p2,M(1,2),M(2,2))];
line{4}=['R^2 = ' num2str(gof.rsquare)];
line{5}=['RMS = ' num2str(gof.rmse)];
% add a color map for the days
clev=[jdi:(jdf-jdi)/28.:jdf];
[cmap, clim]=cmapclim(clev);
colormap(cmap);
caxis(clim);
bar = colorbar;
datetick(bar,'y',7);
%
hxl=xlabel('AOD Lidar 355nm','fontsize',14);
hyl=ylabel('AOD Aeronet 355nm','fontsize',14);
hzl=ylabel(bar,'day');
hAnot=annotation('textbox',[0.50 0.34 0 0],'string',line, ...
                 'background','white', 'fitboxtotext', 'on', ...
                 'FontName', 'AvantGarde', 'FontSize', 11,...
                 'VerticalAlignment','middle');
grid on;

set(gca, ...
    'FontName'    , 'Helvetica', ...
    'FontSize'    , 12        , ...
    'Box'         , 'on'      , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'LineWidth'   , 1         );

set([hxl, hyl, hzl], 'FontName', 'AvantGarde', 'FontSize', 14);
set([bar], 'FontName', 'AvantGarde', 'FontSize', 12);
legend('Data','y=x','y=p1*x+p2','Location','NorthWest');
set(gcf, 'PaperPositionMode', 'auto');
print -r300 -dpng faraday_aod_aerolidar.png
%%----------------------------------------------------------------
figure(4); clf
set(gcf,'position',[0,300,900,300]); % units in pixels!
set(gcf,'PaperUnits','inches','PaperSize',[12,4],'PaperPosition',[0 0 12 4])

nslot=ceil((jdf-jdi)*1440+1);
tt=((1:nslot)-1)/1440+jdi; % horizontal in minutes

Y=(0:0.1:0.8); n=length(Y);
for i=1:nslot
  tmp=datevec(tt(i));
  hh=tmp(4)+tmp(5)/60.+tmp(6)/3600.;
  if (hh>=11 & hh<=14)
    alfa(1:n,i)=-100;
  else
    alfa(1:n,i)=NaN;
  end
end

imsc(lidarjd,Y,alfa,[1. 1. 1.],isnan(alfa),[.7 .7 .7],alfa==-100)
set(gca,'YDir','normal');
ylim([min(X) max(X)]);
datetick('x','mm/dd')
hold on;

hLidar=plot(lidarjd, aodklett(:,11),'or');
set(hLidar,'MarkerSize',4,'markerfacecolor','r');
hAero=plot(aerojd-4./24, aod355, 'sb');
set(hAero,'MarkerSize',4,'markerfacecolor','b');

x=(550./355.)^1.11;
hMod=plot(MOD04L2_MAO(:,1)-4./24., MOD04L2_MAO(:,10)*x, '+k');
set(hMod,'MarkerSize',14,'markerfacecolor','k','LineWidth', 2);
hMyd=plot(MYD04L2_MAO(:,1)-4./24., MYD04L2_MAO(:,10)*x, 'xg');
set(hMyd,'MarkerSize',14,'markerfacecolor','g','LineWidth', 2);

hyl=ylabel('AOD 355nm','fontsize',14, 'FontName', 'AvantGarde');
grid on;

set(gca, ...
    'FontName'    , 'Helvetica', ...
    'FontSize'    , 12        , ...
    'Box'         , 'on'      , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'LineWidth'   , 1         );

legend('Lidar','Aeronet','Terra','Aqua','Location','NorthWest');
set(gcf, 'PaperPositionMode', 'auto');
print -r300 -dpng faraday_aod_timeseries.png
%%
