%% ERASE MEMORY
clear all; 
['analysis started @ ' datestr(clock)]; tic

%datain='../../Raymetrics_data';
%datain='/media/work/data/EMBRAPA/lidar/data';
datain='/home/lidar_data/data';

%% FIRST DATE
%jdi=datenum(2011, 7, 29, 0, 0, 0);
jdi=datenum(2012,  1, 20, 0, 0, 0);
jdf=jdi+7;

%% READ TIME SLICE
[nfile, heads, chphy]=profile_read_dates(...
    datain, jdi, jdf, 10, 0.004, 0, 4000);
disp(['[1] data reading finished @ ' ' nfile=' num2str(nfile)]); toc

%% GLUE ANALOG+PC
chphy(6).data=glue(chphy(1).data, heads(1).ch(1), ...
                   chphy(2).data, heads(1).ch(2));
chphy(7).data=glue(chphy(3).data, heads(1).ch(3), ...
                   chphy(4).data, heads(1).ch(4));
disp(['[2] Glueing finished @ ']); toc

%% REMOVE BACK GROUND NOISE
% average noise and stdev are calculated from last 500 bins
% values below (bg+3*std) become zero
for ch=1:heads(1).nch+2
  chphy(ch).cs = remove_bg(chphy(ch).data, 500, 3);
end
disp(['[3] bg noise finished @ ']); toc
chphy=rmfield(chphy,'data');

%% RANGE CORRECTED SIGNAL
for i=1:heads(1).ch(1).ndata
  zh(i,1)=(7.5*i);
end
for ch=1:heads(1).nch+2
  for i=1:nfile
    chphy(ch).rcs(:,i) = chphy(ch).cs(:,i) .* zh(:) .* zh (:);
  end
end
chphy=rmfield(chphy,'cs');
disp(['[4] range corrected signal finished @ ']); toc

%