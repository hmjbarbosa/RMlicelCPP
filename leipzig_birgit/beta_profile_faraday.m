%clear all
%load beta_klett_dry_overlap.mat

addpath('../matlab');
addpath('../sc');

jdi=datenum(2011, 7, 29, 0, 0, 0);
%load beta_klett_wet.mat
%jdi=datenum(2012,  1, 20, 0, 0, 0);
jdf=jdi+7;

maxbin=floor(4/7.5e-3);
minbin=floor(0.5/7.5e-3);
nslot=ceil((jdf-jdi)*1440+1);
dataA(1:maxbin,1:nslot)=NaN;
dataB(1:maxbin,1:nslot)=NaN;
tt=((1:nslot)-1)/1440+jdi; % horizontal in minutes
zz(1:maxbin)=(1:maxbin)'*7.5/1e3; % vertical in km

[nz, nfile]=size(klett_beta_aero);

over=nanmean(klett_beta_aero(1:maxbin,:)')'*1e3;
top=floor(1.7/7.5e-3);
%over(1:top)=over(1:top).*(1-(1:top)'/top)+1*(1:top)'/top;
%over(1:top)=over(1:top)/over(top);
over(top:maxbin)=1;


selA1=floor((datenum(2011,7,30,12,0,0)-jdi)*1440+0.5)+2;
selA2=floor((datenum(2011,8, 1,12,0,0)-jdi)*1440+0.5)+2;
selB1=floor((datenum(2011,8, 1,13,0,0)-jdi)*1440+0.5)+2;
selB2=floor((datenum(2011,8, 2,12,0,0)-jdi)*1440+0.5)+2;
totA=0; totB=0;
for i=1:nfile
  j=floor((totheads(i).jdi-jdi)*1440+0.5)+2;
  if (j<=nslot && j>=1)
    if (j>=selA1 && j<=selA2)
      if (dataA(1,j)~=NaN)
	totA=totA+1;
      end
      dataA(1:maxbin,j)=klett_beta_aero(1:maxbin,i)*1e3; % Mm-1
    end
    if (j>=selB1 && j<=selB2)
      if (dataB(1,j)~=NaN)
	totB=totB+1;
      end
      dataB(1:maxbin,j)=klett_beta_aero(1:maxbin,i)*1e3; % Mm-1
    end
  end
end
totA
totB
dataB(1:maxbin,5536)=NaN;
dataB(1:maxbin,5534)=NaN;
dataB(1:maxbin,5524)=NaN;
dataB(1:maxbin,5523)=NaN;
dataB(1:maxbin,5514)=NaN;

dataB(1:maxbin,5014:5536)=NaN;

% average periods
profA=nanmean(dataA')';
profAs=nanstd(dataA')'./sqrt(totA);
profB=nanmean(dataB')';
profBs=nanstd(dataB')'./sqrt(totB);

figure(1); clf
set(gcf,'position',[0,300,600,800]); % units in pixels!
set(gcf,'PaperUnits','inches','PaperSize',[6,8],'PaperPosition',[0 0 6 8])

plot(profA(minbin:maxbin)+0.01,zz(minbin:maxbin),'r'); hold on;
plot(profB(minbin:maxbin)+0.1,zz(minbin:maxbin),'b');
xlim([-0.1 1.2]); grid;
ylim([0.75 4]);
xlabel('Mm^{-1} sr^{-1}','fontsize',14);
ylabel('Altitude agl (km)','fontsize',14)
legend('Before','After');

out='faraday_beta_prof.png';
print(out,'-dpng');
eval(['!mogrify -trim ' out])

%
