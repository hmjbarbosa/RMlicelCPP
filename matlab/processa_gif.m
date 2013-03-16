%% ERASE MEMORY
clear all; 
addpath ../sc
['analysis started @ ' datestr(clock)]
tic

datain='/lfa-data/lidar/data';
dataout='/lfa-data/lidar/gifs';

%% FIRST DATE
%jdi=datenum(2010, 1, 1, 0, 0, 0);
jdi=datenum(2011, 7, 1, 0, 0, 0);
jdf=jdi+1.;
ndays=1;

while(ndays<=365*2)

  %% VERIFY IF FILES ALREADY PROCESSED (FIGURE CREATED)
  idate=datevec(jdi);
  yy=idate(1); mm=idate(2); dd=idate(3);
  skip=0;
  for ch=1:5
    fname=sprintf('%s/RM_%04d_%02d_%02d_ch%1d.png',...
                  dataout,yy,mm,dd,ch);
    if exist(fname,'file')
      disp(['SKIP. Figures already created for day: ' datestr(jdi)]);
%      skip=1;
    end
  end
  if (skip)
    jdi=jdf;
    jdf=jdf+1.;
    ndays=ndays+1;
    continue;
  end

  %% READ TIME SLICE
  [nfile, heads, phy]=profile_read_dates(datain, jdi, jdf, 10, 0.004);

  %% IF NO FILES IN THIS DAY, SKIP TO NEXT
  if nfile==0
    disp(['SKIP. No files for dat ' datestr(jdi)]);
    jdi=jdf;
    jdf=jdf+1.;
    ndays=ndays+1;
    continue;
  end
  %% CHECK IF ALL FILES HAVE THE SAME NUMBER OF CHANNELS
  nch=heads(1).nch; skip=0;
  for t=2:nfile
    if (nch ~= heads(t).nch)
      disp(['SKIP. Files with different channels! ' datestr(jdi)]);
      skip=1;
      break;
    end
  end
  if (skip) 
    jdi=jdf;
    jdf=jdf+1.;
    ndays=ndays+1;
    continue;
  end
  ['[1] data reading finished @ ' num2str(toc) ' nfile=' num2str(nfile)]

  %% GLUE ANALOG+PC
  for ch=heads(1).nch+1:5
    heads(1).ch(ch).active=0;
    heads(1).nch=heads(1).nch+1;
  end
  if (heads(1).ch(1).active & heads(1).ch(2).active)
    phy(6).data=glue(phy(1).data, heads(1).ch(1), phy(2).data, heads(1).ch(2));
    heads(1).ch(6).active=1;
    heads(1).ch(6).photons=2;
    heads(1).ch(6).wlen=heads(1).ch(1).wlen;
    heads(1).ch(6).elastic=heads(1).ch(1).elastic;
    heads(1).nch=heads(1).nch+1;
  end
  if (heads(1).ch(3).active & heads(1).ch(4).active)
    phy(7).data=glue(phy(3).data, heads(1).ch(3), phy(4).data, heads(1).ch(4));
    heads(1).ch(7).active=1;
    heads(1).ch(7).photons=2;
    heads(1).ch(7).wlen=heads(1).ch(3).wlen;
    heads(1).ch(7).elastic=heads(1).ch(3).elastic;
    heads(1).nch=heads(1).nch+1;
  end
  ['[2] Glueing finished @ ' num2str(toc)]

  %% REMOVE BACK GROUND NOISE
  % average noise and stdev are calculated from last 500 bins
  % values below (bg+3*std) become zero
  for ch=1:heads(1).nch
    if (heads(1).ch(ch).active)
      phy(ch).bg = remove_bg(phy(ch).data, 500, 3);
    end
  end
  ['[3] bg noise finished @ ' num2str(toc)]
  
  %% RANGE IN KM
  for i=1:heads(1).ch(1).ndata
    zh(i)=(7.5*i);
  end
  zh2=zh.*zh;
  
  %% RANGE CORRECTED
  for ch=1:heads(1).nch
    if (heads(1).ch(ch).active)
      % average time interval (sec)
      % laser is 10Hz
      if (ch==1)
        tint=0;
        for t=1:nfile
          tint=tint+heads(t).ch(ch).nshoots;
        end
        tint=tint/nfile/10;
        % number of intervals in a day
        dint=floor(86400/tint + 1.5);
        % time axis
        taxis=((1:dint)-1)*tint/3600;
      end
      % nan fill
      phy(ch).rcs=NaN(heads(1).ch(1).ndata,dint);
      % rcs and re-positioning
      for t=1:nfile
        % count time from start point: jdi 
        idx=floor( (heads(t).jdf-jdi)*24.*3600./tint + 1.5 );
        for i=1:heads(1).ch(1).ndata
          phy(ch).rcs(i,idx)=phy(ch).bg(i,t)*zh2(i);
        end
      end
    end
  end
  ['[4] range corrected @ ' num2str(toc)]
  
  %yy=heads(1).datef(3);
  %mm=heads(1).datef(2);
  %dd=heads(1).datef(1);

  for ch=1:heads(1).nch
      fname=sprintf('%s/RM_%04d_%02d_%02d_ch%1d.png',...
                    dataout,yy,mm,dd,ch);
    if (heads(1).ch(ch).active)
      if (ch==1)
        vmax=4e7;
      elseif (ch==2)
        vmax=1e9;
      elseif (ch==3)
        vmax=4e6;
      elseif (ch==4)
        vmax=4e8;
      elseif (ch==5)
        vmax=4e6;
      elseif (ch==6)
        vmax=2e9;
      elseif (ch==7)
        vmax=3e8;
      end

      clf;
      gplot2(phy(ch).rcs(1:2000,:)./vmax,[0:1/50:1],taxis,zh(1:2000)/1e3);

      xlabel('Local Time (UTC-4)');
      ylabel('Range above ground (km)');
      tag=sprintf(' %04d-%02d-%02d',yy,mm,dd);
      if (heads(1).ch(ch).elastic==1)
        type=['Elastic '];
      else
        type=['Raman '];
      end
      type=[type sprintf('%dnm/',heads(1).ch(ch).wlen)];
      if (heads(1).ch(ch).photons==0)
        type=[type 'Analog']
      elseif (heads(1).ch(ch).photons==1)
        type=[type 'PC']
      else
        type=[type 'Glue']
      end
      title({'Range and BG corrected signal [a.u.]'; [type tag]});
      set(gca,'FontSize',12);
      hand = get(gca,'title');  set(hand,'fontsize',14)
      hand = get(gca,'xlabel'); set(hand,'fontsize',13)
      hand = get(gca,'ylabel'); set(hand,'fontsize',13)
      set(gcf,'PaperUnits','inches','PaperSize',[8,6],...
              'PaperPosition',[0 0 8 6])
      print('-dpng','-r72',fname);
      ['[5] plotting ' fname ' @ ' num2str(toc)]
    end
  end

  % step forward
  clear nfile heads phy zh zh2 taxis fname;
  jdi=jdf;
  jdf=jdf+1.;
  ndays=ndays+1;

end % loop over days

%
%