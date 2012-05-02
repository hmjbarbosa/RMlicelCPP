%% ERASE MEMORY
clear all; 
['analysis started @ ' datestr(clock)]

vert_smooth=1;
time_smooth=1;
calc_bg=1;
remove_bg=1;
gluepc=1;
correct_range=1;

%%------------------------------------------------------------------------------
%% CREATE FILE LIST
%%------------------------------------------------------------------------------
datadir='./data/11/9/01';
%filelist={f1{:} f2{:}};
filelist=dirpath(datadir,'RM*');

nfile = numel(filelist);
if (nfile < 1)
  error('No file found!');
end
['directory listing finished @ ' datestr(clock)]

%%------------------------------------------------------------------------------
%% READ EACH FILE
%%------------------------------------------------------------------------------
ANALOG_DELAY=10;
DEAD_TIME=0.004;
for nf=1:nfile
  % READ EACH FILE
  % transform raw data to physical units
  % correct anlog delay (10 bins)
  % correct dead-time (0.004 us)
  [head(nf), tmp]=profile_read(filelist{nf}, ANALOG_DELAY, DEAD_TIME);

  % SAVE TIME-STAMP
  % jd(i)= matlab julian date of i-th file 
  % jd1(i)= minutes between i-th and first files
  jd(nf)=datenum([head(nf).datef(3:-1:1) head(nf).hourf]);
  jd1(nf)=floor(1+(jd(nf)-jd(1))*24*60+0.5);
  
  % SEPARATE DATA BY CHANNEL 
  % Note that we save each profile on the correct minute (@ jd1) and
  % not just one after the other (@ nf). Therefore, in a 2D plot
  % the horizontal axis is a time axis. Empty minutes will have NaN data.
  for ch=1:head(nf).nch
    channel(ch).phy(:,jd1(nf)) = tmp(:,ch);
  end  
end
clear tmp;
['data reading finished @ ' datestr(clock)]
nch=head(1).nch;

%%------------------------------------------------------------------------------
%% SMOOTH IN THE VERTICAL
%%------------------------------------------------------------------------------
if (vert_smooth==1)
  for ch=1:nch
    if (ch==5)
      channel(ch).phy = ...
          smooth_region( channel(ch).phy , 5, 150, 10, 300, 15);
    else
      channel(ch).phy = ...
          smooth_region( channel(ch).phy , 3, 400, 7, 800, 15);
    end
  end
  ['vertical smoothing finished @ ' datestr(clock)]
end

%%------------------------------------------------------------------------------
%% SMOOTH OVER TIME
%%------------------------------------------------------------------------------
% running average of 5 minutes (+-2min)
if (time_smooth==1)
  for ch=1:nch
    channel(ch).phy = smooth_time( channel(ch).phy , 2 );
  end
  ['time smoothing finished @ ' datestr(clock)]
end

%%------------------------------------------------------------------------------
%% REMOVE BACK GROUND NOISE
%%------------------------------------------------------------------------------
% Average and standard deviation of noise are calculated from last 500
% bins. Values below (bg+3*std) become NaN
BG_BINS=500;
BG_SNR=3;
if (calc_bg==1)
  for ch=1:nch
    [channel(ch).bg channel(ch).std] = calc_bg2(channel(ch).phy, BG_BINS);
  end
  ['bg noise calculation finished @ ' datestr(clock)]
end
if (remove_bg==1)
  for ch=1:nch
    channel(ch).phy = remove_bg2(channel(ch).phy, ...
                                 channel(ch).bg, channel(ch).std, BG_SNR);
  
    [channel(ch).bg channel(ch).std] = calc_bg2(channel(ch).phy, BG_BINS);
  end
  ['bg noise removal finished @ ' datestr(clock)]
end

%%------------------------------------------------------------------------------
%% GLUE
%%------------------------------------------------------------------------------
if (gluepc==1)
  channel(6).phy=glue(channel(1).phy, channel(2).phy, head(1));
  [channel(6).bg channel(6).std] = calc_bg2(channel(6).phy, BG_BINS);

%  channel(7).phy=glue(channel(3).phy, channel(4).phy, head(1));
%  [channel(7).bg channel(7).std] = calc_bg2(channel(7).phy, BG_BINS);
  ['Glueing finished @ ' datestr(clock)]
  
  nch=nch+2;
end

%%------------------------------------------------------------------------------
%% COMPUTE RANGE CORRECTED SIGNAL
%%------------------------------------------------------------------------------
BIN_SIZE_M=7.5;
nz=head(1).ndata(1);
for i=1:nz
  zh(i,1)= (BIN_SIZE_M*i);
  zh2(i,1)=(BIN_SIZE_M*i)^2;
end
nt=size(channel(1).phy,2);
if (correct_range==1)
  for ch=1:nch
    for nt=1:nt
      channel(ch).phy(:,nt)=channel(ch).phy(:,nt).*zh2(:);
      [channel(ch).bg channel(ch).std] = calc_bg2(channel(ch).phy, BG_BINS);
    end
  end
  ['RCS finished @ ' datestr(clock)]
end

%%------------------------------------------------------------------------------
%% PLOT FIELD
%%------------------------------------------------------------------------------
figure(1)
[C1, h1]=gplot((channel(1).phy(1:700,200:700)),[],[200:700],zh(1:700));
title(['Final Signal ' datestr(jd(1)) ' to ' datestr(jd(nfile))]);
grid on;

%