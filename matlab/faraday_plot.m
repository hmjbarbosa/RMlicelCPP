addpath('../sc')

nslot=(jdf-jdi)*1440+1;
data(1:2000,1:nslot)=NaN;
yy=((1:nslot)-1)/1440+jdi;

for k=1:7

  for i=1:nfile
    j=floor((heads(i).jdi-jdi)*1440+0.5)+1;
    data(:,j)=chphy(k).rcs(1:2000,i);
  end
  
  if (k==1) tipo='355an'; end
  if (k==2) tipo='355pc'; end
  if (k==3) tipo='387an'; end
  if (k==4) tipo='387pc'; end
  if (k==5) tipo='408pc'; end
  if (k==6) tipo='355gl'; end
  if (k==7) tipo='387gl'; end
  
  
  figure(1); clf
  set(gcf,'position',[0,0,1500,500]); % units in pixels!
  set(gcf,'PaperUnits','inches','PaperSize',[12,4],'PaperPosition',[0 0 12 4])

  lim=quantile(reshape(data,[],1),[.98]);
  gplot2(smooth_time(data,2)/lim*100,[0:1:100],yy,zh(1:2000)/1e3)
  set(gca,'fontsize',12)
  datetick('x','mm/dd')
  ylabel('Altitude agl (km)','fontsize',14)
  tmp=datevec(jdi);
  out=sprintf('faraday_plot_%s_%4d_%02d_%02d.png',...
	      tipo,tmp(1),tmp(2),tmp(3));
  print(out,'-dpng')
  eval(['!mogrify -trim ' out])
  
end
%