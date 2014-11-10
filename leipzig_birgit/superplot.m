clear all
close all

files=dirpath('./','embrapa*.mat');
nfiles=length(files);

k=0;
for nf=1:nfiles
  load(files{nf});
  for j=1:length(save_times)
    if any(~isnan(save_beta_klett(:,j)))
      k=k+1;
      beta_klett(:,k)=save_beta_klett(1:1000,j);
      time_klett(k)=save_times(j);
    end
  end
  clear save_beta_klett save_alpha_klett save_times
end

files=dirpath('./','tiwa*.mat');
nfiles=length(files);

k=0;
for nf=1:nfiles
  load(files{nf});
  for j=1:length(save_times)
    if any(~isnan(save_beta_klett(:,j)))
      k=k+1;
      beta_klett2(:,k)=save_beta_klett(1:1000,j);
      time_klett2(k)=save_times(j);
    end
  end
  clear save_beta_klett save_alpha_klett save_times
end

%%------------------------------------------------------------------------
%% Maximum and minimum times actually read from disk
%%------------------------------------------------------------------------
minjd=max(min(time_klett), min(time_klett2));
maxjd=min(max(time_klett), max(time_klett2));
disp(['first date = ' datestr(minjd)]);
disp(['last date = ' datestr(maxjd)]);
tmp=datevec(minjd); tmp(4)=0; tmp(5)=0; tmp(6)=0; minday=datenum(tmp);
tmp=datevec(maxjd); tmp(4)=0; tmp(5)=0; tmp(6)=0; maxday=datenum(tmp)+1;

dt=5.; % min
% Create the vector of times 
times=(0:dt:(maxday-minday)*1440)/1440.+minday;
ntimes=length(times);

%%------------------------------------------------------------------------
%% ORGANIZE
%%------------------------------------------------------------------------

sort_beta(1:1000,1:ntimes)=NaN;
sort_time(1:ntimes)=NaN;
for j=1:length(time_klett)
  idx=floor((time_klett(j)-minday)*1440./dt+0.5);
  if (idx>0 & idx<=ntimes)
    sort_beta(:,idx)=beta_klett(:,j);
    sort_time(idx)=time_klett(j);
  end
end

sort_beta2(1:1000,1:ntimes)=NaN;
sort_time2(1:ntimes)=NaN;
for j=1:length(time_klett2)
  idx=floor((time_klett2(j)-minday)*1440./dt+0.5);
  if (idx>0 & idx<=ntimes)
    sort_beta2(:,idx)=beta_klett2(:,j);
    sort_time2(idx)=time_klett2(j);
  end
end

%fim