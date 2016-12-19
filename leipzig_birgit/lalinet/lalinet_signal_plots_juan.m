%% this routine makes the plots of the signal for the week of the
% lidar paper #1 from Juan.

clear all
addpath('../matlab');

jdi=datenum(2014, 6, 2, 14, 0, 0);

while (jdi<datenum(2014, 6, 2, 20, 0, 0))

jdf=jdi+21/24;

maxbin=floor(20.01/7.5e-3);
minbin=floor(0.5/7.5e-3);

dt=5;
nslot=ceil((jdf-jdi)*1440/dt+1);
tt=((1:nslot)-1)*dt/1440+jdi; % horizontal in minutes

%% lidar data

[nfile heads chphy]=profile_read_dates(...
    '/LFANAS/ftproot/public/lidar/data',jdi,jdf,9,0.004,[],5100);

if (nfile == 0)
  jdi=jdf;
  continue
end

ch=1;

nz=5000;
signal_aero=chphy(ch).data(1:nz,:);
[nz, nfile]=size(signal_aero(:,:));

zz=(1:nz)'*7.5/1e3; % vertical in km
zz2=(zz.*zz);

% accumulate in bins of size dt minutes
clear count P
count(1:nslot)=0;
P(1:nz,1:nslot)=0;
for i=1:nfile
  j=floor((heads(i).jdi-jdi)*1440/dt+0.5);
  if (j<=nslot && j>=1)
    count(j)=count(j)+1;
    P(:,j)=P(:,j)+signal_aero(:,i);
  end
end

% calculate the mean in each dt interval
for j=1:nslot
  if count(j)==0
    P(:,j)=nan;
  else
    P(:,j)=P(:,j)/count(j);
  end
end

% remove BG and noise
Sigmean(1:nz)=nan;
Sigstd(1:nz)=nan;
for j=1:nslot
  if count(j)>0
    Sigmean(j)=mean(P(end-1000:end,j));
    Sigstd(j)=std(P(end-1000:end,j));

    mask=P(:,j)<Sigmean(j)+1*Sigstd(j);
    P(mask,j)=NaN;
    P(~mask,j)=P(~mask,j)-Sigmean(j);
  end
end

% compute RCS
clear Pr2
for j=1:nslot
  Pr2(:,j)=P(:,j).*zz2;
end
Pr2=Pr2/quantile(reshape(Pr2(minbin:maxbin,:),numel(Pr2(minbin:maxbin,:)),1),0.97);

% mask shutter closed
for i=1:nslot
  vec(i,:)=datevec(tt(i));
  if (tt(i)>=datenum([vec(i,1:3) 11 0 0]) & ...
      tt(i)<=datenum([vec(i,1:3) 14 0 0]) )
    P(:,i)=-100;
    Pr2(:,i)=-100;
  end
end

%----------------------
figure(1); clf
set(gcf,'position',[0,400,900,400]); % units in pixels!
set(gcf,'PaperUnits','inches','PaperSize',[12,4],'PaperPosition',[0 0 12 4])

clev=[0:0.01:1];
[cmap, clim]=cmapclim(clev);
% plot should be in UTC
imsc(tt+4/24,zz(minbin:maxbin),Pr2(minbin:maxbin,:),clim,cmap,...
     [1. 1. 1.],isnan(Pr2(minbin:maxbin,:)),...
     [.7 .7 .7],Pr2(minbin:maxbin,:)==-100)
set(gca,'YDir','normal');
set(gca,'yticklabel',sprintf('%.1f|',get(gca,'ytick')));
colormap(min(max(cmap,0),1));
caxis(clim);
bar = colorbar;
set(get(bar,'ylabel'),'String','Range Corrected Signal (a.u.)');

if (heads(1).ch(ch).photons==0)
  type='AN';
else
  type='PC';
end
tag=[type ' ' num2str(heads(1).ch(ch).wlen) ' nm'];

tit=title(['Manaus, ' datestr((jdi+jdf)/2,1) ' ' tag]);
%set(tit,'position',get(tit,'position')+[0 .5 0]);
datetick('x',' HH ','keeplimits')
ylabel('Altitude agl (km)')
%prettify(gca,bar);
tmp=datevec((jdi+jdf)/2);
xlabel('UTC')

tag=[type '_' num2str(heads(1).ch(ch).wlen) '_nm'];
out=sprintf('manaus_Pr2_%s_%4d_%02d_%02d_merged.png', tag, tmp(1),tmp(2),tmp(3))
print(out,'-dpng')
%eval(['!mogrify -trim ' out])

%----------------------
%

jdi=jdf;
end

%