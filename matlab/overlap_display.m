%% ERASE MEMORY
clear all; 
addpath('../sc')
['analysis started @ ' datestr(clock)]; tic

%datain='../../Raymetrics_data';
%datain='/media/work/DATA/EMBRAPA/lidar/data';
datain='/home/lidar_data/data';

topheight=[10000, 11000, 12000, 13000, 14000, 15000];
ntop=numel(topheight);
nsel(1:ntop)=0;

selection_2levels_11km

nw=numel(wjdi);
w=251;
while (w<=nw)

  clear nfile heads chphy zh yy data 
  
  %% READ TIME SLICE
  [nfile, heads, chphy]=profile_read_dates(...
      datain, wjdi(w), wjdf(w), 10, 0.004, 0, 4000);
  
  %% REMOVE BACK GROUND NOISE
  % average noise and stdev are calculated from last 500 bins
  % values below (bg+3*std) become zero
  %for ch=1:heads(1).nch
  for ch=1:5
    chphy(ch).cs = remove_bg(chphy(ch).data, 1000, -10);
  end
  
  %% RANGE CORRECTED SIGNAL
  for i=1:heads(1).ch(1).ndata
    zh(i,1:nfile)=(7.5*i);
  end
  %for ch=1:heads(1).nch
  for ch=1:5
    chphy(ch).rcs = chphy(ch).cs .* zh .* zh;
  end
  
  %% PLOT
  % files were selected based on the date and time of the
  % filename. depending on the data aquisition version, this can
  % be either the start or the end time!!
  
  % number of expected profiles (there are 10sec 30sec and 1-min profiles)
  numsec=(wjdf(w)-wjdi(w))*1440*60; % number of seconds
  nhz=max(heads(1).nhz,heads(1).nhz2);
  nshoots=max(heads(1).nshoots,heads(1).nshoots2);
  numshoots=numsec*nhz; % number of shoots
  numprof=floor(numshoots/nshoots+0.5); % number of profiles in [jdi, jdf]
  maxbin=2000;
  data(1:maxbin,1:numprof)=NaN;
  yy=(1:numprof);
  
  % no need to position the profiles in the correct time bin    
  data(:,1:nfile)=chphy(1).rcs(1:maxbin,1:nfile);
  
  %% DECIDE IF THERE IS A CLOUD OR NOT

  % low level clouds
  hascloud=0;
  tmp=diff(nanmean(data(100:400,:),2));
  if (any(abs(tmp-nanmean(tmp)) > 5 * nanstd(tmp)))
    disp(['THERE IS A CLOUD IN THE PROFILE!!!!!!!!!!!!!!!!!'])
    hascloud=1;
  end

  % compute the fraction of NaN
  frac=sum(sum(isnan(data)))/numel(data);

  for n=1:ntop
    
    for h=1:4
      critH(h)=2000*h;
      n1(h)=floor(critH(h)/(zh(2)-zh(1)));
      [v(:,h),idx(:,h)]=nanmax(data(n1(h):end,:));
      idx(:,h)=idx(:,h)+n1(h)-1;
      
      cld(h)=sum(zh(idx(:,h),1) > critH(h)*1.3 & zh(idx(:,h),1) < topheight(n));
    end
    
    if (frac<0.25 & all(cld==0) & ~hascloud)
      disp(['selected OK H=' num2str(topheight(n)/1e3)]);
    else
      disp(['NOT selected H=' num2str(topheight(n)/1e3)]);
    end
  end
  
  show=1; but=1;
  cc={ 'black', 'red', 'green', 'yellow', 'green' };
  if (show)
    figure(1); clf
    set(gcf,'position',[0,500,1400,600]); % units in pixels!
    gplot2(data,[0:3e5:3e7],yy,zh(1:maxbin,1)/1e3); hold on; grid on;
    for h=1:4
      plot(yy, zh(idx(:,h),1)/1e3,'o-','color',cc{h})
      plot(yy, yy*0 + critH(h)*1.3/1e3,'--','color',cc{h})
    end
    ylabel('Altitude agl (km)')
    dd=datevec(wjdi(w));
    out=sprintf(['%4d / %02d / %02d - %02d:%02d frac=%4.2f'... 
		 ' cld=%d %d %d %d   w= %d / %d'],...
		dd(1),dd(2),dd(3),dd(4),dd(5),...
		frac, cld, w, nw);
    title(out)
    [x,y,but]=ginput(1);
  end

  if (but==3)
    w=w-1;
  else
    w=w+1;
  end
 
end

%