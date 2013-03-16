%% ERASE MEMORY
clear all; 
['analysis started @ ' datestr(clock)]; tic

datain='../../Raymetrics_data';
dataout='./data_5min_ascii';
%datain='/media/work/data/EMBRAPA/lidar/data';
%dataout='/media/work/data/EMBRAPA/lidar/data_5min_ascii';

%% FIRST DATE
%jdi=datenum(2011, 7, 29, 0, 0, 0);
jdi=datenum(2011, 12, 14, 0, 0, 0);
jdf=jdi+7.;
lastdir='x';

%% READ TIME SLICE
[nfile, heads, chphy]=profile_read_dates(...
    datain, jdi, jdf, 10, 0.004, 0, 4000);
disp(['[1] data reading finished @ ' ' nfile=' num2str(nfile)]); toc

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

%