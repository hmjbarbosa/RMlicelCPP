%% ERASE MEMORY
clear all; 
['analysis started @ ' datestr(clock)]

%datain='../../Raymetrics_data';
%dataout='./ascii';
datain='/media/work/data/EMBRAPA/lidar/data';
dataout='/media/work/data/EMBRAPA/lidar/data_5min_ascii';

%% FIRST DATE
jdi=datenum(2012, 5, 25, 12, 0, 0);
jdf=jdi+1.;
ndays=1;
lastdir='x';

%while(ndays<500)
  
  %% READ TIME SLICE
  [nfile, heads, chphy]=profile_read_dates(datain, jdi, jdf, 10, 0.004);
  %nfile=numel(heads);
  if nfile==0
    jdi=jdf;
    jdf=jdf+1.;
    ndays=ndays+1;
    continue;
  end
  ['[1] data reading finished @ ' datestr(clock) ' nfile=' num2str(nfile)]
  
  %% SMOOTH IN THE VERTICAL
  for ch=1:heads(1).nch
    chphy(ch).vsmooth = ...
        smooth_region( chphy(ch).data , 3, 400, 7, 800, 10);
  end
  ['[2] vertical smoothing finished @ ' datestr(clock)]
  
  %% SMOOTH OVER TIME
  % running average of 5 minutes (+-2min)
  for ch=1:heads(1).nch
    chphy(ch).tsmooth = smooth_time( chphy(ch).vsmooth , 2);
  end
  ['[3] time smoothing finished @ ' datestr(clock)]
  
  %% CROP TIME, i.e., KEEP ONLY 1 OUT OF 5 MINUTES
  ncrop=0;
  for nf=1:nfile
    if mod(heads(nf).hourf(2), 5)==0
      ncrop=ncrop+1;
      heads_crop(ncrop) = heads(nf);
      for ch=1:heads(1).nch
        chphy(ch).crop(:,ncrop) = chphy(ch).tsmooth(:,nf);
      end
    end
  end
  ['[4] time cropping ' num2str(ncrop) ' finished @ ' datestr(clock)]
  if ncrop==0
    jdi=jdf;
    jdf=jdf+1.;
    ndays=ndays+1;
    continue;
  end

  %% REMOVE BACK GROUND NOISE
  % average noise and stdev are calculated from last 500 bins
  % values below (bg+3*std) become zero
  for ch=1:heads(1).nch
    chphy(ch).cs = remove_bg(chphy(ch).crop, 500, 3);
  end
  ['[5] bg noise finished @ ' datestr(clock)]
  
  %% COMPUTE RANGE CORRECTED SIGNAL
  for i=1:heads(1).ndata(1)
    zh(i)=(7.5*i);
  end
  
  %% GLUE ANALOG+PC
  glue355=glue(chphy(1).cs, chphy(2).cs, heads_crop(1));
  glue387=glue(chphy(3).cs, chphy(4).cs, heads_crop(1));
  ['[7] Glueing finished @ ' datestr(clock)]
  
  %% WRITE OUTPUT
  for nf=1:ncrop
    yy=heads_crop(nf).datef(3);
    mm=heads_crop(nf).datef(2);
    dd=heads_crop(nf).datef(1);
    hh=heads_crop(nf).hourf(1);
    mn=heads_crop(nf).hourf(2);
    ss=heads_crop(nf).hourf(3);
    dout=sprintf('%s/%02d/%d/%02d',dataout,yy-2000,mm,dd);
    if ~strcmp(dout,lastdir)
      mkdir(dout);
      lastdir=dout;
    end
    fname=sprintf('%s/Glue_%04d_%02d_%02d-%02d%02d.txt',dout,yy,mm, ...
                  dd,hh,mn)
    % precisa adicionar teste de erro
    fid=fopen(fname,'w');
    pt=4000;
    mat=[zh(1:pt)' chphy(1).cs(1:pt,nf) chphy(2).cs(1:pt,nf) ...
         glue355(1:pt,nf) chphy(3).cs(1:pt,nf) chphy(4).cs(1:pt,nf) ...
         glue387(1:pt,nf) chphy(5).cs(1:pt,nf)]';
    fprintf(fid,'%7.1f %9.4f %9.4f %10.4f %9.4f %9.4f %10.4f %9.4f\n',mat);
    fclose(fid);
  end

%  clear nfile heads chphy mat heads_crop;

  jdi=jdf;
  jdf=jdf+1.;
  ndays=ndays+1;

%end % loop over days

%
%