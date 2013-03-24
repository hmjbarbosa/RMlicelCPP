%% ERASE MEMORY
clear all; 
addpath('../sc')
['analysis started @ ' datestr(clock)]; tic

%datain='../../Raymetrics_data';
%datain='/media/work/data/EMBRAPA/lidar/data';
datain='/home/lidar_data/data';

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

%% FIRST DATE
jdi0=datenum(2011, 7, 29, 0, 0, 0);
%jdi0=datenum(2011, 12, 14, 0, 0, 0);
%jdi0=datenum(2011, 12, 21, 0, 0, 0);
%jdi0=datenum(2012,  1, 19,12, 0, 0);

nsel=0; nday=0; step=0.25;
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
  
  %% SMOOTH OVER TIME
  % running average of 5 minutes (+-2min)
  % this is wrong! files may not be continous in time!!!
  for ch=1:heads(1).nch
    chphy(ch).tsm = smooth_time( chphy(ch).data , 2);
  end
  disp(['[2] time smoothing finished @ ']); toc
  chphy=rmfield(chphy,'data');
  
  %% CROP TIME, i.e., KEEP ONLY 1 OUT OF 5 MINUTES
  ncrop=0;
  for nf=1:nfile
    if mod(heads(nf).hourf(2), 5)==0
      ncrop=ncrop+1;
      heads_crop(ncrop) = heads(nf);
      for ch=1:heads(1).nch
	chphy(ch).crop(:,ncrop) = chphy(ch).tsm(:,nf);
      end
    end
  end
  disp(['[3] Cropping @ ']); toc
  chphy=rmfield(chphy,'tsm');
  
  %% GLUE ANALOG+PC
  chphy(6).crop=glue(chphy(1).crop, heads_crop(1).ch(1), ...
		     chphy(2).crop, heads_crop(1).ch(2));
  chphy(7).crop=glue(chphy(3).crop, heads_crop(1).ch(3), ...
		     chphy(4).crop, heads_crop(1).ch(4));
  disp(['[4] Glueing finished @ ']); toc
  
  %% SMOOTH IN THE VERTICAL
  for ch=1:heads(1).nch+2
    chphy(ch).vsm = ...
	smooth_region( chphy(ch).crop , 3, 400, 7, 800, 10);
  end
  disp(['[5] vertical smoothing finished @ ']); toc
  chphy=rmfield(chphy,'crop');
  
  %% REMOVE BACK GROUND NOISE
  % average noise and stdev are calculated from last 500 bins
  % values below (bg+3*std) become zero
  for ch=1:heads(1).nch+2
    chphy(ch).cs = remove_bg(chphy(ch).vsm, 500, 3);
  end
  disp(['[6] bg noise finished @ ']); toc
  chphy=rmfield(chphy,'vsm');
  
  %% RANGE CORRECTED SIGNAL
  for i=1:heads(1).ch(1).ndata
    zh(i,1:ncrop)=(7.5*i);
  end
  for ch=1:heads(1).nch+2
    chphy(ch).rcs = chphy(ch).cs .* zh .* zh;
  end
  disp(['[7] range corrected signal finished @ ']); toc

  %% PLOT
  nslot=(jdf-jdi)*1440/5+1;
  data(1:2000,1:nslot)=NaN;
  yy=((1:nslot)-1)*5/1440+jdi;

  for i=1:ncrop
    j=floor((heads_crop(i).jdi-jdi)*1440/5+0.5)+1;
    data(:,j)=chphy(6).rcs(1:2000,i);
  end
  
  figure(1)
  set(gcf,'position',[0,500,1400,600]); % units in pixels!
  gplot2(data,[0:1.e7:1.5e9],yy,zh(1:2000,1)/1e3)
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
      ptf(nsel)=x;
      disp(sprintf('endt #%d jdf=%f datef=%s',nsel,ptf(nsel),datestr(ptf(nsel))));
    end
    if (but==1)
      if (last==3 | last==-1)
	nsel=nsel+1;
      end
      pti(nsel)=x;
      disp(sprintf('start #%d jdi=%f datei=%s',nsel,pti(nsel),datestr(pti(nsel))));
    end
    last=but;
  end

  %
  if (x<jdi)
    step=-step
  end
  nday=nday+step
end

for i=1:nsel
  disp(sprintf('jdi=datenum(''%s''); jdf=datenum(''%s'')',...
	       datestr(pti(i)),datestr(ptf(i))));
end

%