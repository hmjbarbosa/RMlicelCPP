%% ERASE MEMORY
clear all; 
['analysis started @ ' datestr(clock)]

%% CREATE FILE LIST
%datadir='data/11/11/04';Glueing
datadir='../../Raymetrics_data/11/7/13';
%datadir='/media/work/data/EMBRAPA/lidar/data/11/8/12';
%f1 = dirpath(datadir,'RM*');
%f2 = dirpath(datadir,'RM*');
%filelist={f1{:} f2{:}};
filelist=dirpath(datadir,'RM1171302.5*');

nfile = numel(filelist);
if (nfile < 1)
  error('No file found!');
end
['[1/8] directory listing finished @ ' datestr(clock)]

%% READ EACH FILE
for nf=1:nfile

  % read file
  % get channel in physical units
  % correct anlog delay (10 bins)
  % correct dead-time (0.004 us)
  [head, tmp]=profile_read(filelist{nf}, 10, 0.004);

  % save time-stamp of current file
  jd(nf)=datenum([head.datef(3:-1:1) head.hourf]);
  if (nf==1)
    jd1(nf)=1;
  else
    jd1(nf)=floor(1+(jd(nf)-jd(1))*24*60+0.5);
  end
  
  % separate data by channel
  % struct variable 'phy' is nz:nfile
  for ch=1:head.nch
%    channel(ch).phy(:,nf) = tmp(:,ch);
    channel(ch).phy(:,jd1(nf)) = tmp(:,ch);
  end
  
end
clear tmp;
['[2/8] data reading finished @ ' datestr(clock)]

%% SMOOTH OVER TIME
% running average of 5 minutes (+-2min)
for ch=1:head.nch
  channel(ch).phy2 = smooth_time( channel(ch).phy , 2 );
end
['[4/8] time smoothing finished @ ' datestr(clock)]

%% SMOOTH IN THE VERTICAL
for ch=1:head.nch
  if (ch==5)
    channel(ch).phy = ...
        smooth_region( channel(ch).phy2 , 5, 150, 10, 300, 1);
  else
    channel(ch).phy = ...
        smooth_region( channel(ch).phy2 , 1, 400, 7, 800, 15);
  end
end
['[3/8] vertical smoothing finished @ ' datestr(clock)]

%% REMOVE BACK GROUND NOISE
% average noise and stdev are calculated from last 500 bins
% values below (bg+3*std) become zero
for ch=1:head.nch
  channel(ch).phy2 = remove_bg(channel(ch).phy, 500, 3);
end
['[5/8] bg noise finished @ ' datestr(clock)]


%% COMPUTE RANGE CORRECTED SIGNAL
for i=1:head.ndata(1)
  zh(i)=(7.5*i);
  zh2(i)=(7.5*i)^2;
end
ntime=size(channel(1).phy,2);
for ch=1:head.nch
  for nt=1:ntime
    channel(ch).phy(:,nt)=channel(ch).phy2(:,nt).*zh2(:);
  end
end
['[6/8] RCS finished @ ' datestr(clock)]

%% GLUE ANALOG+PC
H2O=channel(5).phy2;
N2=glue(channel(3).phy2, channel(4).phy2, head);
['[7/8] Glueing finished @ ' datestr(clock)]

n1=320;
n2=450;
H2O=H2O(n1:n2, :);
N2=N2(n1:n2, :);
mixr=0.7e3*H2O./N2;

figure(1)
plot(N2,zh(n1:n2),'-o',H2O*100,zh(n1:n2),'-v');
figure(2)
plot(mixr,zh(n1:n2));
figure(1)

%analise_plot;
['[8/8] Plotting finished @ ' datestr(clock)]

%
%