%% This routine opens the results from raman analysis for the week
% of the paper and make the plots for alfa, beta and lidar ratio.
clear all

addpath('../matlab');
addpath('../sc');

load beta_klett_dry_overlapfinal_set2011_night.mat
jdi=datenum(2011, 8, 30, 0, 0, 0);
jdf=jdi+7;
%jdi=datenum(2011, 9, 1, 0, 0, 0);
%jdf=jdi+1;

nfile=size(raman_beta_aero,2);
nslot=ceil((jdf-jdi)*1440+1);
tt=((1:nslot)-1)/1440+jdi; % horizontal in minutes

ndata=totheads(1).ch(1).ndata;
dz=totheads(1).ch(1).binw/1e3; % km
zz=(1:ndata)'*dz; % km

%bin_zz=binning(zz,1,1);
%bin_beta=binning(raman_beta_aero,5,1)*1e3; % Mm-1
%bin_alfa=binning(raman_alpha_aero,5,1)*1e3; % Mm-1
%bin_dz=bin_zz(2)-bin_zz(1);
%bin_ndata=length(bin_zz);
bin_zz=zz;
bin_beta=raman_beta_aero*1e3; % Mm-1
bin_alfa=raman_alpha_aero*1e3; % Mm-1
bin_dz=dz;
bin_ndata=ndata;

maxbin=floor(5.01/bin_dz);
minbin=floor(1.00/bin_dz);

beta(1:maxbin+100,1:nslot)=NaN;
alfa(1:maxbin+100,1:nslot)=NaN;

for i=1:nfile
  j=floor((totheads(i).jdi-jdi)*1440+0.5)+1;
  if (j<=nslot && j>=1)
    beta(1:maxbin+100,j)=bin_beta(1:maxbin+100,i); 
    alfa(1:maxbin+100,j)=bin_alfa(1:maxbin+100,i); 
  end
end
alfa=nanmysmooth(alfa ,8,80); % vertical
alfa=nanmysmooth(alfa',6, 6)'; % tempo
ldr=alfa./beta;
ldr(alfa<30)=NaN;
ldr(beta<0.5)=NaN;
ldr=nanmysmooth(ldr ,4,40);
ldr=nanmysmooth(ldr',7,7)';
ldr(alfa<30)=NaN;
ldr(beta<0.5)=NaN;


% mask shutter closed
for i=1:nslot
  jd(i)=(i-2-0.5)/1440+jdi;
  vec(i,:)=datevec(jd(i));
  if ((vec(i,4)>=11 & vec(i,4)<=14))
    beta(:,i)=-100;
    alfa(:,i)=-100;
    ldr(:,i)=-100;
  end
end

f1=figure(1); clf
set(gcf,'position',[0,50,900,300]); % units in pixels!
set(gcf,'PaperUnits','inches','PaperSize',[12,4],'PaperPosition',[0 0 12 4])

clev=[0.5:0.05:4.5];
[cmap, clim]=cmapclim(clev);
imsc(tt,zz(minbin:maxbin),beta(minbin:maxbin,:),clim,cmap,...
     [1. 1. 1.],isnan(beta(minbin:maxbin,:)),...
     [.7 .7 .7],beta(minbin:maxbin,:)==-100)
set(gca,'YDir','normal');
set(gca,'yticklabel',sprintf('%.1f|',get(gca,'ytick')));
bar = colorbar;
set(bar,'ytick',[0.5:1:4.5])
set(bar,'ylim',clim)
set(get(bar,'ylabel'),'String','Backscatter (Mm^{-1} sr^{-1})');
datetick('x','mm/dd')
ylabel('Altitude agl (km)')
prettify(gca,bar);
tmp=datevec(jdi);
out=sprintf('faraday_betaraman_%4d_%02d_%02d_overlap.png', tmp(1),tmp(2),tmp(3));
print(out,'-dpng')
%eval(['!mogrify -trim ' out])

%----------------------
f2=figure(2); clf
set(gcf,'position',[0,200,900,300]); % units in pixels!
set(gcf,'PaperUnits','inches','PaperSize',[12,4],'PaperPosition',[0 0 12 4])

clev=[40:1:200];
[cmap, clim]=cmapclim(clev);
h=imsc(tt,bin_zz(minbin:maxbin),alfa(minbin:maxbin,:),clim,cmap,...
     [1. 1. 1.],isnan(alfa(minbin:maxbin,:)),...
     [.7 .7 .7],alfa(minbin:maxbin,:)==-100);
set(gca,'YDir','normal');
set(gca,'yticklabel',sprintf('%.1f|',get(gca,'ytick')));
bar = colorbar;
set(bar,'ytick',[40:40:200])
set(bar,'ylim',clim)
set(get(bar,'ylabel'),'String','Extinction (Mm ^{-1})');
datetick('x','mm/dd')
ylabel('Altitude agl (km)')
prettify(gca,bar);
tmp=datevec(jdi);
out=sprintf('faraday_alfaraman_%4d_%02d_%02d_overlap.png', tmp(1),tmp(2),tmp(3));
print(out,'-dpng')
%eval(['!mogrify -trim ' out])

%----------------------
f3=figure(3); clf
set(gcf,'position',[0,400,900,300]); % units in pixels!
set(gcf,'PaperUnits','inches','PaperSize',[12,4],'PaperPosition',[0 0 12 4])

clev=[30:0.6:90];
[cmap, clim]=cmapclim(clev);
imsc(tt,zz(minbin:maxbin),ldr(minbin:maxbin,:),clim,cmap,...
     [1. 1. 1.],isnan(ldr(minbin:maxbin,:)),...
     [.7 .7 .7],ldr(minbin:maxbin,:)==-100)
set(gca,'YDir','normal');
set(gca,'yticklabel',sprintf('%.1f|',get(gca,'ytick')));
bar = colorbar;
set(bar,'ytick',[30:10:90])
set(bar,'ylim',clim)
set(get(bar,'ylabel'),'String','Lidar Ratio (sr)');
datetick('x','mm/dd')
ylabel('Altitude agl (km)')
prettify(gca,bar);
tmp=datevec(jdi);
out=sprintf('faraday_LRraman_%4d_%02d_%02d_overlap.png', tmp(1),tmp(2),tmp(3));
print(out,'-dpng')
%eval(['!mogrify -trim ' out])

%----------------------
disp(['total count=' num2str(size(beta,2))]);
disp(['sun count=' num2str(sum(beta(200,:)==-100))]);
disp(['nan count=' num2str(sum(isnan(beta(200,:))))]);
disp(['ok count=' num2str(sum(beta(200,:)>0))]);
%
