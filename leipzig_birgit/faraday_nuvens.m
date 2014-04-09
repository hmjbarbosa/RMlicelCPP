%% this routine opens the cirrus data file from Boris and the
% signal file from my routines and prepare those to be plotted by a
% second routine. For the paper, I have to run this twice, shifting
% by 3.5 days in between to make two plots. Otherwise it is too
% much in the same plot and we cannot see what is going on.
clear all
addpath('../matlab');
addpath('../sc');

jdi=datenum(2011, 8, 30, 0, 0, 0);
% shift initial date
jdi=jdi+3.5;
jdf=jdi+3.5;

maxbin=floor(18.01/7.5e-3);
minbin=floor(6.99/7.5e-3);
nslot=ceil((jdf-jdi)*1440+1);
tt=((1:nslot)-1)/1440+jdi; % horizontal in minutes
zz(1:maxbin)=(1:maxbin)'*7.5/1e3; % vertical in km
zz2=(zz.*zz)';

%% cloud data
load faraday_cirrus.mat 
cloudsjd=datenum(double(Dc(:,1:6)));
ntimes=size(Dc,1);
nlayers=Dc(:,7);
j=0;
for i=1:ntimes
  tmp=datevec(cloudsjd(i));
  hh=tmp(4)+tmp(5)/60.+tmp(6)/3600.;
  if (hh<=11 | hh>=14)
  for k=1:nlayers(i)
    j=j+1;
    if (nlayers(i)>1)
      base(j)=Bc{i}{2}(k);
      topo(j)=Bc{i}{3}(k);
      maxb(j)=Bc{i}{4}(k);
    else
      base(j)=Bc{i}{2};
      topo(j)=Bc{i}{3};
      maxb(j)=Bc{i}{4};
    end
    time(j)=cloudsjd(i);
  end
  end
end
nclouds=j;

%% lidar data
load signal_dry_overlapfinal_set2011.mat
[nz, nfile]=size(signal_aero);
disp(['aqui 1']);
Sigmean=mean(signal_aero(nz-500:nz,:));
Sigstd=std(signal_aero(nz-500:nz,:));
disp(['aqui 2']);
signal_aero=signal_aero(minbin:maxbin,:);
zz=zz(minbin:maxbin);
zz2=zz2(minbin:maxbin);
disp(['aqui 3']);
[nz, nfile]=size(signal_aero);
signal_aero=nanmysmooth(signal_aero,5,10);
disp(['aqui 4']);

P(1:nz,1:nslot)=NaN;
Pr2(1:nz,1:nslot)=NaN;
for i=1:nfile
%  j=floor((totheads(i).jdi-jdi)*1440+0.5)+2;
  j=floor((totheads(i).jdi-jdi)*1440+0.5)+1;
  if (j<=nslot && j>=1)
    P(:,j)=signal_aero(:,i)-Sigmean(i);
    Pr2(:,j)=P(:,j)-1*Sigstd(i);
  end
end
P(Pr2<=0)=NaN;

disp(['aqui 5']);
for i=1:nfile
%  j=floor((totheads(i).jdi-jdi)*1440+0.5)+2;
  j=floor((totheads(i).jdi-jdi)*1440+0.5)+1;
  if (j<=nslot && j>=1)
    Pr2(:,j)=log(P(:,j).*zz2(:));
  end
end
disp(['aqui 6']);
%Pr2=Pr2/2e3;

% mask shutter closed
for i=1:nslot
%  jd(i)=(i-2-0.5)/1440+jdi;
  jd(i)=(i-1)/1440+jdi;
  vec(i,1:6)=datevec(jd(i));
  hh=vec(i,4)+vec(i,5)/60.+vec(i,6)/3600.;
  if (hh>=11 & hh<=14)
%    P(:,i)=-100;
    Pr2(:,i)=-100;
    vec(i,7)=1;
  else
    vec(i,7)=0;    
  end
end




%

