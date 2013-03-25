clear all

addpath('../matlab');
addpath('../sc');

load beta_klett_seca_noclouds.mat

[nz, nt]=size(klett_beta_aero);
%jdi=totheads(1).jdi;
%jdf=totheads(nt).jdf;

jdi=datenum(2011, 7, 29, 0, 0, 0);
jdf=jdi+7;

maxbin=2000;

nslot=ceil((jdf-jdi)*1440+1);
data(1:maxbin,1:nslot)=NaN;
yy=((1:nslot)-1)/1440+jdi;

for i=1:2898
  j=floor((totheads(i).jdi-jdi)*1440+0.5)+2;
  data(:,j)=klett_beta_aero(1:maxbin,i);
end

zh=(1:maxbin)'*7.5;

figure(1); clf
set(gcf,'position',[0,0,1500,500]); % units in pixels!
set(gcf,'PaperUnits','inches','PaperSize',[12,4],'PaperPosition',[0 0 12 4])
gplot2(data*1e3,[0:0.03:2],yy,zh(1:maxbin,1)/1e3)
set(gca,'fontsize',12)
datetick('x','mm/dd')
ylabel('Altitude agl (km)','fontsize',14)
tmp=datevec(jdi);
out=sprintf('faraday_beta_%4d_%02d_%02d.png', tmp(1),tmp(2),tmp(3));
print(out,'-dpng')
eval(['!mogrify -trim ' out])
