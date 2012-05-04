%% ERASE MEMORY
clear all; 
['analysis started @ ' datestr(clock)]

%% CREATE FILE LIST
datadir='../../Raymetrics_data/11/9/06';
filelist=dirpath(datadir,'RM*');

nfile = numel(filelist);
if (nfile < 1)
  error('No file found!');
end
['[1/8] directory listing finished @ ' datestr(clock)]

%% READ EACH FILE
[heads, chphy]=profile_read_many(filelist, 10, 0.004);

%% create time vector
for nf=1:nfile  
  jd(nf)=heads(nf).jdf;
  if (nf==1)
    jd1(nf)=1;
  else
    jd1(nf)=floor(1+(jd(nf)-jd(1))*24*60+0.5);
  end  
end
clear tmp;
['[2/8] data reading finished @ ' datestr(clock)]

%% SMOOTH IN THE VERTICAL
for ch=1:heads(1).nch
  if (ch==5)
    chphy(ch).vsmooth = ...
        smooth_region( chphy(ch).data , 5, 150, 10, 300, 15);
  else
    chphy(ch).vsmooth = ...
        smooth_region( chphy(ch).data , 3, 400, 7, 800, 15);
  end
end
['[3/8] vertical smoothing finished @ ' datestr(clock)]

%% SMOOTH OVER TIME
% running average of 5 minutes (+-2min)
for ch=1:heads(1).nch
  chphy(ch).tsmooth = smooth_time( chphy(ch).vsmooth , 2 );
end
['[4/8] time smoothing finished @ ' datestr(clock)]

%% REMOVE BACK GROUND NOISE
% average noise and stdev are calculated from last 500 bins
% values below (bg+3*std) become zero
for ch=1:heads(1).nch
  chphy(ch).cs = remove_bg(chphy(ch).tsmooth, 500, 3);
end
['[5/8] bg noise finished @ ' datestr(clock)]


%% COMPUTE RANGE CORRECTED SIGNAL
for i=1:heads(1).ndata(1)
  zh(i)=(7.5*i);
  zh2(i)=(7.5*i)^2;
end
for ch=1:heads(1).nch
  for nt=1:nfile
    chphy(ch).rcs(:,nt)=chphy(ch).cs(:,nt).*zh2(:);
  end
end
['[6/8] RCS finished @ ' datestr(clock)]

%% GLUE ANALOG+PC
H2O=chphy(5).cs;
N2=glue(chphy(3).cs, chphy(4).cs, heads(1));
['[7/8] Glueing finished @ ' datestr(clock)]

H2O=H2O(1:1000, :);
N2=N2(1:1000, :);
mixr=0.7e3*H2O./N2;

analise_plot;
['[8/8] Plotting finished @ ' datestr(clock)]

%
%