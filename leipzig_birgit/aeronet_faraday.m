%clear all
addpath('../matlab');
addpath('../sc');

%% ---------------------------------------------------------------------
%% DEFINE DATES DATA WILL BE USED
jdi=datenum(2011, 8, 30, 0, 0, 0);
jdf=jdi+7;

%% ---------------------------------------------------------------------
%% AERONET
load MDataModisAeronet2011.mat

% build matlab julian date
aerojd=datenum(AERONET_MAO.data(:,3), AERONET_MAO.data(:,2), ...
               AERONET_MAO.data(:,1), AERONET_MAO.data(:,4), ...
               AERONET_MAO.data(:,5), AERONET_MAO.data(:,6));

% cut data not between jdi and jdf
idxjd=aerojd>=jdi & aerojd<=jdf;
tmp=aerojd(idxjd); clear aerojd; aerojd=tmp;

%% AOD at 380 and 340
aod380=AERONET_MAO.data(idxjd,22);
aod340=AERONET_MAO.data(idxjd,23);
% calculate angstrom 340-380
angstrom=-log(aod380./aod340)/log(380./340);
% calculate AOD at 355
aod355 = aod340.*(355./340.).^angstrom;

%% AOD at 440 (for error), 380 and 340
aod440=AERONET_MAO.data(idxjd,20);
% error folowing aeronet documentation (in percent)
err355=(-1.0940*aod440.^2 + 4.0653*aod440 + 4.3270)/100.;
err355(aod440<0.4)=0.05;
err355(aod440>1.5)=0.08;

%% ---------------------------------------------------------------------
%% LIDAR
load beta_klett_dry_overlapfinal_set2011.mat
clear aodklett lidarjd

maxh=2010.; % start here
minh=525.; % stop here
binh=75;

minbin=((minh:binh:maxh)/7.5);
maxbin=floor(5000./7.5);
% for each profile between jdi and jdf
j=0;
nfile=length(totheads);
for i=1:nfile
  if (jdi <= totheads(i).jdi & totheads(i).jdi <= jdf)
    j=j+1;
    lidarjd(j)=totheads(i).jdi;

    % integrate until different lower-heights
    for k=1:length(minbin)
      aodklett(j,k)=trapz(klett_alpha_aero(minbin(k):maxbin,i))*7.5e-3...
          + minbin(k)*7.5e-3*klett_alpha_aero(minbin(k),i);
    end
  end
end

%% ---------------------------------------------------------------------
%% LIDAR x AOD times
clear twid oktime meanklett diffaod rmsaod 
for i=1:length(aod355)
  for j=1:60
    twid(j)=j;
    % UTC - 4 for local time (LIDAR)
    oktime=abs(lidarjd-aerojd(i)+4./24.) < (twid(j)/2.)/1440.; 
    % avereage times withing this time window
    meanklett(i,:,j)=nanmean(aodklett(oktime,:),1);
    
    % difference between lidar average and aeronet
    diffaod(i,:,j)=meanklett(i,:,j)-aod355(i);
  end
end
% rms of the difference
rmsaod=squeeze(sqrt(nanmean(diffaod.^2,1)));
% aeronet only where we have lidar
idx=isnan(meanklett(:,1,1));
nanaod355=aod355;
nanaod355(idx)=NaN;

% correlation
ymed=nanmean(nanaod355,1);
ymed2=nanmean((nanaod355-ymed).^2,1);
xmed=squeeze(nanmean(meanklett,1));
for i=1:length(minbin)
  for j=1:length(twid)
    xmed2(i,j)=nanmean((meanklett(:,i,j)-xmed(i,j)).^2,1);
    xymed(i,j)=nanmean((meanklett(:,i,j)-xmed(i,j)).*(nanaod355-ymed),1);
  end
end
corraod=xymed./(sqrt(xmed2.*ymed2));

%----------------------------------------------------------------
%figure(1); clf;
%x1=min(min(rmsaod));
%x2=max(max(rmsaod));
%[h, bar]=gplot2(rmsaod,(x1:(x2-x1)/100:x2),twid,minbin*7.5e-3);
%hxl=xlabel('Averaging time window [min]');
%hyl=ylabel('Mininum altitude of integration [km]');
%hzl=ylabel(bar,'AOD RMSE Lidar - Aeronet ');
%grid on;
%
%set(gca, ...
%    'FontName'    , 'Helvetica', ...
%    'FontSize'    , 12        , ...
%    'Box'         , 'on'      , ...
%    'TickLength'  , [.02 .02] , ...
%    'XMinorTick'  , 'on'      , ...
%    'YMinorTick'  , 'on'      , ...
%    'LineWidth'   , 1         );
%
%set([hxl, hyl, hzl], 'FontName', 'AvantGarde', 'FontSize', 14);
%set(bar            , 'FontName', 'AvantGarde', 'FontSize', 12);
%                  
%set(gcf, 'PaperPositionMode', 'auto');
%%print -dpdf finalPlot1.pdf
%print -r300 -dpng faraday_aod_rmse.png
%
%%----------------------------------------------------------------
%figure(2); clf;
%x1=min(min(corraod));
%x2=max(max(corraod));
%[h, bar]=gplot2(corraod,(x1:(x2-x1)/100:x2),twid,minbin*7.5e-3);
%hxl=xlabel('Averaging time window [min]');
%hyl=ylabel('Mininum altitude of integration [km]');
%hzl=ylabel(bar,'Correlation AOD Lidar x Aeronet ');
%grid on;
%
%set(gca, ...
%    'FontName'    , 'Helvetica', ...
%    'FontSize'    , 12        , ...
%    'Box'         , 'on'      , ...
%    'TickLength'  , [.02 .02] , ...
%    'XMinorTick'  , 'on'      , ...
%    'YMinorTick'  , 'on'      , ...
%    'LineWidth'   , 1         );
%
%set([hxl, hyl, hzl], 'FontName', 'AvantGarde', 'FontSize', 14);
%set(bar            , 'FontName', 'AvantGarde', 'FontSize', 12);
%                  
%set(gcf, 'PaperPositionMode', 'auto');
%%print -dpdf finalPlot1.pdf
%print -r300 -dpng faraday_aod_correlation.png
%
%%----------------------------------------------------------------
%figure(3); clf
%h=scatter(meanklett(:,11,30), aod355, 20, aerojd-4./24,'o','fill');
%hold on;
%X=(0:0.1:0.8);
%xlim([min(X) max(X)]);
%ylim([min(X) max(X)]);
%pline=plot(X,X,'--k','LineWidth',2);
%% fit 
%[obj, gof, out] = fit(meanklett(~idx,11,30),aod355(~idx),'poly1');
%pfit=plot(obj,'r');
%set(pfit,'LineWidth',2);
%M=confint(obj);
%line{1}=['Aeronet = p1 * Lidar + p2'];
%line{2}=[sprintf('p1 = %5.3f (%5.3f, %5.3f)',obj.p1,M(1,1),M(2,1))];
%line{3}=[sprintf('p2 = %5.3f (%5.3f, %5.3f)',obj.p2,M(1,2),M(2,2))];
%line{4}=['R^2 = ' num2str(gof.rsquare)];
%line{5}=['RMS = ' num2str(gof.rmse)];
%% add a color map for the days
%clev=[jdi:(jdf-jdi)/28.:jdf];
%[cmap, clim]=cmapclim(clev);
%colormap(cmap);
%caxis(clim);
%bar = colorbar;
%datetick(bar,'y',7);
%%
%hxl=xlabel('Lidar','fontsize',14);
%hyl=ylabel('Aeronet','fontsize',14);
%hzl=ylabel(bar,'day');
%hAnot=annotation('textbox',[0.50 0.34 0 0],'string',line, ...
%                 'background','white', 'fitboxtotext', 'on', ...
%                 'FontName', 'AvantGarde', 'FontSize', 11,...
%                 'VerticalAlignment','middle');
%grid on;
%
%set(gca, ...
%    'FontName'    , 'Helvetica', ...
%    'FontSize'    , 12        , ...
%    'Box'         , 'on'      , ...
%    'TickLength'  , [.02 .02] , ...
%    'XMinorTick'  , 'on'      , ...
%    'YMinorTick'  , 'on'      , ...
%    'LineWidth'   , 1         );
%
%set([hxl, hyl, hzl], 'FontName', 'AvantGarde', 'FontSize', 14);
%set([bar], 'FontName', 'AvantGarde', 'FontSize', 12);
%legend('Data','y=p1*x+p2','y=x','Location','NorthWest');
%set(gcf, 'PaperPositionMode', 'auto');
%print -r300 -dpng faraday_aod_aerolidar.png
%%----------------------------------------------------------------
%figure(4); clf
%h=scatter(lidarjd, aodklett(:,11),'or','fill');
%h=scatter(aerojd-4./24, aod355, 'ob','fill');
%hold on;
%X=(0:0.1:0.8);
%xlim([min(X) max(X)]);
%ylim([min(X) max(X)]);
%pline=plot(X,X,'--k','LineWidth',2);
%% fit 
%[obj, gof, out] = fit(meanklett(~idx,11,30),aod355(~idx),'poly1');
%pfit=plot(obj,'r');
%set(pfit,'LineWidth',2);
%M=confint(obj);
%line{1}=['Aeronet = p1 * Lidar + p2'];
%line{2}=[sprintf('p1 = %5.3f (%5.3f, %5.3f)',obj.p1,M(1,1),M(2,1))];
%line{3}=[sprintf('p2 = %5.3f (%5.3f, %5.3f)',obj.p2,M(1,2),M(2,2))];
%line{4}=['R^2 = ' num2str(gof.rsquare)];
%line{5}=['RMS = ' num2str(gof.rmse)];
%% add a color map for the days
%clev=[jdi:(jdf-jdi)/28.:jdf];
%[cmap, clim]=cmapclim(clev);
%colormap(cmap);
%caxis(clim);
%bar = colorbar;
%datetick(bar,'y',7);
%%
%hxl=xlabel('Lidar','fontsize',14);
%hyl=ylabel('Aeronet','fontsize',14);
%hzl=ylabel(bar,'day');
%hAnot=annotation('textbox',[0.50 0.34 0 0],'string',line, ...
%                 'background','white', 'fitboxtotext', 'on', ...
%                 'FontName', 'AvantGarde', 'FontSize', 11,...
%                 'VerticalAlignment','middle');
%grid on;
%
%set(gca, ...
%    'FontName'    , 'Helvetica', ...
%    'FontSize'    , 12        , ...
%    'Box'         , 'on'      , ...
%    'TickLength'  , [.02 .02] , ...
%    'XMinorTick'  , 'on'      , ...
%    'YMinorTick'  , 'on'      , ...
%    'LineWidth'   , 1         );
%
%set([hxl, hyl, hzl], 'FontName', 'AvantGarde', 'FontSize', 14);
%set([bar], 'FontName', 'AvantGarde', 'FontSize', 12);
%legend('Data','y=p1*x+p2','y=x','Location','NorthWest');
%set(gcf, 'PaperPositionMode', 'auto');
%print -r300 -dpng faraday_aod_aerolidar.png
%%
