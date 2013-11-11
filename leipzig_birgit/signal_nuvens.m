clear all
addpath('../matlab');
addpath('../sc');


jdi=datenum(2011, 8, 30, 0, 0, 0);
jdf=jdi+7;

maxbin=floor(5.99/7.5e-3);
minbin=floor(20.01/7.5e-3);
nslot=ceil((jdf-jdi)*1440+1);
tt=((1:nslot)-1)/1440+jdi; % horizontal in minutes
zz(1:maxbin)=(1:maxbin)'*7.5/1e3; % vertical in km
zz2=(zz.*zz)';

%% cloud data
load datos_henrique_week.mat
cloudsjd=datenum(double(Dc(:,1:6)));
ntimes=size(Dc,1);
nlayers=Dc(:,7);
j=0;
for i=1:ntimes
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
nclouds=j;

%% lidar data
load signal_dry_overlapfinal_set2011.mat
[nz, nfile]=size(signal_aero);
Sigmean=mean(signal_aero(nz-500:nz,:));
Sigstd=std(signal_aero(nz-500:nz,:));

P(1:maxbin,1:nslot)=NaN;
Pr2(1:maxbin,1:nslot)=NaN;
for i=1:nfile
  j=floor((totheads(i).jdi-jdi)*1440+0.5)+2;
  if (j<=nslot && j>=1)
    P(1:maxbin,j)=signal_aero(1:maxbin,i)-Sigmean(i);
%    Pr2(1:maxbin,j)=signal_aero(1:maxbin,i)-3*Sigmean(i);
  end
end
P(P<=0)=NaN;

for i=1:nfile
  j=floor((totheads(i).jdi-jdi)*1440+0.5)+2;
  if (j<=nslot && j>=1)
    Pr2(1:maxbin,j)=(P(1:maxbin,j).*zz2);
  end
end
Pr2=Pr2/2e3;

% mask shutter closed
for i=1:nslot
  jd(i)=(i-2-0.5)/1440+jdi;
  vec(i,:)=datevec(jd(i));
  if ((vec(i,4)>=11 & vec(i,4)<=14))
%    P(:,i)=-100;
    Pr2(:,i)=-100;
  end
end




%

