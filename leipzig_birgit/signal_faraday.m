clear all

addpath('../matlab');
addpath('../sc');

load signal_dry_overlapfinal_set2011.mat
jdi=datenum(2011, 8, 30, 0, 0, 0);
%load beta_klett_wet.mat
%jdi=datenum(2012,  1, 20, 0, 0, 0);
jdf=jdi+7;

maxbin=floor(5.01/7.5e-3);
minbin=floor(0.01/7.5e-3);
nslot=ceil((jdf-jdi)*1440+1);
P(1:maxbin,1:nslot)=NaN;
Pr2(1:maxbin,1:nslot)=NaN;
tt=((1:nslot)-1)/1440+jdi; % horizontal in minutes
zz(1:maxbin)=(1:maxbin)'*7.5/1e3; % vertical in km
zz2=(zz.*zz)';

[nz, nfile]=size(signal_aero);

Sigmean=mean(signal_aero(nz-500:nz,:));
Sigstd=std(signal_aero(nz-500:nz,:));

for i=1:nfile
  j=floor((totheads(i).jdi-jdi)*1440+0.5)+2;
  if (j<=nslot && j>=1)
    P(1:maxbin,j)=signal_aero(1:maxbin,i)-Sigmean(i);
    
  end
end

for i=1:nfile
  j=floor((totheads(i).jdi-jdi)*1440+0.5)+2;
  if (j<=nslot && j>=1)
    Pr2(1:maxbin,j)=log10(P(1:maxbin,j).*zz2);
  end
end

% mask shutter closed
for i=1:nslot
  jd(i)=(i-2-0.5)/1440+jdi;
  vec(i,:)=datevec(jd(i));
  if ((vec(i,4)>=11 & vec(i,4)<=14))
%    P(:,i)=-100;
    Pr2(:,i)=-100;
  end
end

%----------------------
figure(2); clf
set(gcf,'position',[0,400,900,300]); % units in pixels!
set(gcf,'PaperUnits','inches','PaperSize',[12,4],'PaperPosition',[0 0 12 4])

clev=[0:0.01:4];
[cmap, clim]=cmapclim(clev);
imsc(tt,zz(minbin:maxbin),Pr2(minbin:maxbin,:),clim,cmap,...
     [1. 1. 1.],isnan(Pr2(minbin:maxbin,:)),...
     [.7 .7 .7],Pr2(minbin:maxbin,:)==-100)
set(gca,'YDir','normal');
colormap(min(max(cmap,0),1));
caxis(clim);
bar = colorbar;
set(get(bar,'ylabel'),'String','log_{10}(P r^2) (a.u.)');

set(gca,'fontsize',12)
datetick('x','mm/dd')
ylabel('Altitude agl (km)','fontsize',14)
tmp=datevec(jdi);
out=sprintf('faraday_signalr2_%4d_%02d_%02d_overlap.png', tmp(1),tmp(2),tmp(3));
print(out,'-dpng')
eval(['!mogrify -trim ' out])

%----------------------
%disp(['total count=' num2str(size(P,2))]);
%disp(['sun count=' num2str(sum(P(200,:)==-100))]);
%disp(['nan count=' num2str(sum(isnan(P(200,:))))]);
%disp(['ok count=' num2str(sum(P(200,:)>0))]);
%
