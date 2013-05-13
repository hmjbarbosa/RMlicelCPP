%% ERASE MEMORY
clear all; 
addpath('../sc')
['analysis started @ ' datestr(clock)]; tic

%datain='../../Raymetrics_data';
datain='/media/work/DATA/EMBRAPA/lidar/data';
%datain='/home/lidar_data/data';

%WET - CEU LIMPO
%jdi=datenum('20-Jan-2012 17:15:21'); jdf=datenum('20-Jan-2012 22:32:17')
%jdi=datenum('21-Jan-2012 08:42:52'); jdf=datenum('21-Jan-2012 09:09:21')
%jdi=datenum('22-Jan-2012 01:34:24'); jdf=datenum('22-Jan-2012 03:12:31')
%jdi=datenum('23-Jan-2012 08:13:56'); jdf=datenum('23-Jan-2012 09:36:52')
%jdi=datenum('24-Jan-2012 07:14:17'); jdf=datenum('24-Jan-2012 08:23:28')
%jdi=datenum('24-Jan-2012 19:36:10'); jdf=datenum('24-Jan-2012 20:58:45')
%%WET - NUVENS, SEM CHUVA, ACIMA DE 4KM
%jdi=datenum('20-Jan-2012 04:35:49'); jdf=datenum('20-Jan-2012 05:58:03')
%jdi=datenum('20-Jan-2012 05:58:45'); jdf=datenum('20-Jan-2012 07:17:28')
%jdi=datenum('20-Jan-2012 22:39:00'); jdf=datenum('20-Jan-2012 23:00:31')
%jdi=datenum('21-Jan-2012 02:32:38'); jdf=datenum('21-Jan-2012 05:59:07')
%jdi=datenum('21-Jan-2012 05:57:21'); jdf=datenum('21-Jan-2012 09:03:21')
%jdi=datenum('21-Jan-2012 17:58:24'); jdf=datenum('21-Jan-2012 18:24:10')
%jdi=datenum('22-Jan-2012 18:20:38'); jdf=datenum('22-Jan-2012 18:35:49')
%jdi=datenum('22-Jan-2012 22:24:10'); jdf=datenum('22-Jan-2012 22:59:49')
%jdi=datenum('23-Jan-2012 05:35:07'); jdf=datenum('23-Jan-2012 06:00:52')
%jdi=datenum('23-Jan-2012 05:58:24'); jdf=datenum('23-Jan-2012 09:29:07')
%jdi=datenum('23-Jan-2012 16:53:07'); jdf=datenum('23-Jan-2012 18:00:10')
%jdi=datenum('23-Jan-2012 21:52:03'); jdf=datenum('23-Jan-2012 23:38:17')
%jdi=datenum('24-Jan-2012 06:05:07'); jdf=datenum('24-Jan-2012 08:58:45')
%jdi=datenum('24-Jan-2012 18:13:56'); jdf=datenum('24-Jan-2012 19:25:56')
%jdi=datenum('25-Jan-2012 00:03:42'); jdf=datenum('25-Jan-2012 02:45:42')
%jdi=datenum('25-Jan-2012 19:09:42'); jdf=datenum('25-Jan-2012 21:14:38')
%jdi=datenum('26-Jan-2012 00:10:45'); jdf=datenum('26-Jan-2012 01:41:07')
%jdi=datenum('26-Jan-2012 02:33:21'); jdf=datenum('26-Jan-2012 02:58:24')
%jdi=datenum('26-Jan-2012 16:03:42'); jdf=datenum('26-Jan-2012 16:51:21')
%% DRY NO CLOUDS
%jdi=datenum('29-Jul-2011 06:31:30'); jdf=datenum('29-Jul-2011 08:19:47')
%jdi=datenum('29-Jul-2011 17:30:26'); jdf=datenum('29-Jul-2011 18:00:05')
%jdi=datenum('29-Jul-2011 18:00:37'); jdf=datenum('29-Jul-2011 22:06:01')
%jdi=datenum('30-Jul-2011 06:36:51'); jdf=datenum('30-Jul-2011 08:05:22')
%jdi=datenum('30-Jul-2011 09:23:12'); jdf=datenum('30-Jul-2011 11:03:40')
%jdi=datenum('30-Jul-2011 14:15:40'); jdf=datenum('30-Jul-2011 14:39:33')
%jdi=datenum('30-Jul-2011 15:34:44'); jdf=datenum('30-Jul-2011 17:25:30')
%jdi=datenum('30-Jul-2011 21:57:47'); jdf=datenum('30-Jul-2011 23:59:15')
%jdi=datenum('30-Jul-2011 23:50:44'); jdf=datenum('31-Jul-2011 05:15:37')
%jdi=datenum('31-Jul-2011 06:48:47'); jdf=datenum('31-Jul-2011 11:01:12')
%jdi=datenum('31-Jul-2011 21:21:58'); jdf=datenum('01-Aug-2011 00:03:47')
%jdi=datenum('31-Jul-2011 23:59:22'); jdf=datenum('01-Aug-2011 04:44:44')
%jdi=datenum('01-Aug-2011 17:21:22'); jdf=datenum('01-Aug-2011 17:46:05')
%jdi=datenum('01-Aug-2011 21:04:40'); jdf=datenum('01-Aug-2011 23:20:08')
%jdi=datenum('02-Aug-2011 00:24:54'); jdf=datenum('02-Aug-2011 01:16:22')
%jdi=datenum('02-Aug-2011 07:17:37'); jdf=datenum('02-Aug-2011 09:51:12')
%jdi=datenum('02-Aug-2011 22:06:26'); jdf=datenum('03-Aug-2011 00:00:05')
%jdi=datenum('02-Aug-2011 23:59:22'); jdf=datenum('03-Aug-2011 06:01:44')
%jdi=datenum('03-Aug-2011 05:59:22'); jdf=datenum('03-Aug-2011 09:04:15')
%jdi=datenum('03-Aug-2011 23:09:01'); jdf=datenum('04-Aug-2011 00:00:54')
%jdi=datenum('05-Aug-2011 07:28:19'); jdf=datenum('05-Aug-2011 08:33:22')
%% DRY, NO RAIN, CLOUDS ABOVE 4KM
%jdi=datenum('30-Jul-2011 01:26:17'); jdf=datenum('30-Jul-2011 06:00:31')
%jdi=datenum('01-Aug-2011 04:55:56'); jdf=datenum('01-Aug-2011 06:02:17')
%jdi=datenum('01-Aug-2011 05:59:07'); jdf=datenum('01-Aug-2011 11:02:17')
%jdi=datenum('01-Aug-2011 17:59:49'); jdf=datenum('01-Aug-2011 20:49:14')
%jdi=datenum('02-Aug-2011 01:24:10'); jdf=datenum('02-Aug-2011 06:02:17')
%jdi=datenum('02-Aug-2011 06:06:10'); jdf=datenum('02-Aug-2011 06:59:28')
%jdi=datenum('04-Aug-2011 17:20:17'); jdf=datenum('04-Aug-2011 18:02:38')
%jdi=datenum('04-Aug-2011 17:57:00'); jdf=datenum('04-Aug-2011 23:28:45')
%jdi=datenum('05-Aug-2011 02:32:38'); jdf=datenum('05-Aug-2011 05:43:35')
%jdi=datenum('05-Aug-2011 05:58:45'); jdf=datenum('05-Aug-2011 07:27:00')


%% FIRST DATE
%jdi0=datenum(2012,  1, 20, 0, 0, 0);
jdi0=datenum(2011, 7, 9, 18, 0, 0);

nsel=0; nday=0; step=0.5;
while (nday<=7)
  jdi=jdi0+nday;
  jdf=jdi0+nday+abs(step);
  
  clear nfile heads chphy ncrop heads_crop zh x y yy tmp out nslot data but
  
  %% READ TIME SLICE
  [nfile, heads, chphy]=profile_read_dates(...
      datain, jdi, jdf, 10, 0.004, 0, 4000);
  disp(['[1] data reading finished @ ' ' nfile=' num2str(nfile)]); toc
  if (nfile==0)
    nday=nday+step;
    continue;
  end
  
  %% REMOVE BACK GROUND NOISE
  % average noise and stdev are calculated from last 500 bins
  % values below (bg+3*std) become zero
  for ch=1:heads(1).nch
    chphy(ch).cs = remove_bg(chphy(ch).data, 500, 3);
  end
  disp(['[6] bg noise finished @ ']); toc
  
  %% RANGE CORRECTED SIGNAL
  for i=1:heads(1).ch(1).ndata
    zh(i,1:nfile)=(7.5*i);
  end
  for ch=1:heads(1).nch
    chphy(ch).rcs = chphy(ch).cs .* zh .* zh;
  end
  disp(['[7] range corrected signal finished @ ']); toc

  %% PLOT
  nslot=(jdf-jdi)*1440+1;
  data(1:2000,1:nslot)=NaN;
  yy=((1:nslot)-1)/1440+jdi;

  for i=1:nfile
    j=floor((heads(i).jdi-jdi)*1440+0.5)+2;
    data(:,j)=chphy(1).rcs(1:2000,i);
  end
  
  figure(1)
  set(gcf,'position',[0,500,1400,600]); % units in pixels!
  gplot2(data,[0:3e5:3e7],yy,zh(1:2000,1)/1e3)
  datetick('x','mm/dd HH:MM')
  ylabel('Altitude agl (km)')
  tmp=datevec(jdi);
  out=sprintf('%4d / %02d / %02d - %02d:%02d',tmp(1),tmp(2),tmp(3),tmp(4),tmp(5));
  title(out)

  but=-1; last=-1;x=jdi+1;step=abs(step);
  
  while (but~=2)
    figure(1)
    [x,y,but]=ginput(1);
    if (but==3)
      ptf(nsel)=max(min(x,jdf),jdi);
      disp(sprintf('endt #%d jdf=%f datef=%s',nsel,ptf(nsel),datestr(ptf(nsel))));
    end
    if (but==1)
      if (last==3 | last==-1)
        nsel=nsel+1;
      end
      pti(nsel)=max(min(x,jdf),jdi);
      disp(sprintf('start #%d jdi=%f datei=%s',nsel,pti(nsel),datestr(pti(nsel))));
    end
    last=but;
  end

  %
  if (x<jdi)
    step=-step
  end
  ym=get(gca,'ylim');
  if (y>ym(2))
    break
  end
  nday=nday+step
end

for i=1:nsel
  disp(sprintf('wjdi(%02d)=datenum(''%s''); wjdf(%02d)=datenum(''%s'');',...
	       i,datestr(pti(i)),i,datestr(ptf(i))));
end

%