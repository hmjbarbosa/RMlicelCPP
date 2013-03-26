addpath('../sc')

maxbin=2000;
nslot=ceil((jdf-jdi)*1440+1);
data(1:maxbin,1:nslot)=NaN;
tt=((1:nslot)-1)/1440+jdi; % horizontal in minutes
zz=zh(1:maxbin)/1e3; % vertical in km

for k=1:7

  for i=1:nfile
    j=floor((heads(i).jdi-jdi)*1440+0.5)+2;
    if (j<=nslot && j>=1)
      data(:,j)=chphy(k).rcs(1:maxbin,i);
    end
  end
%  lim=quantile(reshape(data,[],1),[.995]);% dry
  lim=quantile(reshape(data,[],1),[.96]);% wet
  % 9-min time ave
  data=smooth_time(data,4)/lim*100;
  % mask shutter closed
  for i=1:nslot
    jd(i)=(i-2-0.5)/1440+jdi;
    vec(i,:)=datevec(jd(i));
    if ((vec(i,4)>=11 & vec(i,4)<=14))
      data(:,i)=-100;
    end
  end
  
  if (k==1) tipo='355an'; end
  if (k==2) tipo='355pc'; end
  if (k==3) tipo='387an'; end
  if (k==4) tipo='387pc'; end
  if (k==5) tipo='408pc'; end
  if (k==6) tipo='355gl'; end
  if (k==7) tipo='387gl'; end
  
  figure(1); clf
  set(gcf,'position',[0,0,900,300]); % units in pixels!
  set(gcf,'PaperUnits','inches','PaperSize',[12,4],'PaperPosition',[0 0 12 4])
  
  clev=[0:1:100];
  [cmap, clim]=cmapclim(clev);
  imsc(tt,zz,data,clim,cmap,[1 1 1],isnan(data),[.7 .7 .7],data==-100)
  set(gca,'YDir','normal');
  colormap(min(max(cmap,0),1));
  caxis(clim);
  bar = colorbar;
  set(get(bar,'ylabel'),'String','RCS [a.u.]');

  set(gca,'fontsize',12)
  datetick('x','mm/dd')
  ylabel('Altitude agl (km)','fontsize',14)
  tmp=datevec(jdi);
  out=sprintf('faraday_plot_%s_%4d_%02d_%02d.png',...
	      tipo,tmp(1),tmp(2),tmp(3));
  print(out,'-dpng')
  eval(['!mogrify -trim ' out])

  disp(['k=' num2str(k)]);
  disp(['total count=' num2str(size(data,2))]);
  disp(['sun count=' num2str(sum(data(1,:)==-100))]);
  disp(['nan count=' num2str(sum(isnan(data(1,:))))]);
  disp(['ok count=' num2str(sum(data(1,:)>0))]);
end
%