%% ERASE MEMORY
clear all; 
addpath('../sc')
['analysis started @ ' datestr(clock)]; tic

%datain='../../Raymetrics_data';
%datain='/media/work/DATA/EMBRAPA/lidar/data';
datain='/home/lidar_data/data';

%% FIRST DATE
%jdi0=datenum(2012, 5, 24, 18, 0, 0);
jdi0=datenum(2011, 7, 1, 18, 0, 0);
dstep=1./24.;
nday=0;

clear nsel;
bar='*****************************************************';

topheight=[8000, 9000, 10000, 11000, 12000, 13000, 14000, 15000, 16000];
ntop=numel(topheight);
nsel(1:ntop)=0;

for n=1:ntop
  fid(n)=fopen(sprintf('selection_2levels_%03dkm.m',topheight(n)/1000),'w');
end

while (nday<=800)

  step=0;
  while(step<0.5)

    jdi=jdi0+nday+step;
    jdf=jdi0+nday+step+abs(dstep);
  
    clear nfile heads chphy ncrop heads_crop zh x y yy tmp out nslot data but
  
    %% READ TIME SLICE
    [nfile, heads, chphy]=profile_read_dates(...
        datain, jdi, jdf, 10, 0.004, 0, 4000);
    if (nfile==0)
      step=step+dstep;
      y=0;
      continue;
    end
  
    %% REMOVE BACK GROUND NOISE
    % average noise and stdev are calculated from last 500 bins
    % values below (bg+3*std) become zero
    %for ch=1:heads(1).nch
    for ch=1:5
      chphy(ch).cs = remove_bg(chphy(ch).data, 500, 3);
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
    numsec=(jdf-jdi)*1440*60; % number of seconds
    nhz=max(heads(1).nhz,heads(1).nhz2);
    nshoots=max(heads(1).nshoots,heads(1).nshoots2);
    numshoots=numsec*nhz; % number of shoots
    numprof=floor(numshoots/nshoots+0.5); % number of profiles in [jdi, jdf]
    data(1:2000,1:numprof)=NaN;
    yy=(1:numprof);
 
    % no need to position the profiles in the correct time bin    
    data(:,1:nfile)=chphy(1).rcs(1:2000,1:nfile);

    %% DECIDE IF THERE IS A CLOUD OR NOT
    % compute the fraction of NaN
    frac=sum(sum(isnan(data)))/numel(data);
    % on each profile, find the height of the maximum
    [v,idx]=nanmax(data);
    % on each profile, find the height of the maximum above critH
    % there should be no aerosols, so the maximum should be very
    % close to critH... otherwise it is a cloud
    critH=5000; % meters
    n1=floor(critH/(zh(2)-zh(1)));
    [v2,idx2]=nanmax(data(n1:end,:));
    idx2=idx2+n1-1;

    for n=1:ntop
    
      % flag for a thick cloud between 3km and 15km
      cld=sum(zh(idx,1)>3000 & zh(idx,1)<topheight(n));

      % flag for a thin cloud between critH+1km and 15km
      % if noise it too large, 1km might not be enought
      cld2=sum(zh(idx2,1)>critH+1000 & zh(idx2,1)<topheight(n));
      
      if (frac<0.25 & cld==0 & cld2==0)
	nsel(n)=nsel(n)+1;
	disp([bar 'selected OK H=' num2str(topheight(n)/1e3)]);
	fprintf(fid(n),'wjdi(%02d)=datenum(''%s''); wjdf(%02d)=datenum(''%s'');\n', ...
		nsel(n),datestr(jdi),nsel(n), datestr(jdf));
      else
	disp([bar 'NOT selected H=' num2str(topheight(n)/1e3)]);
      end
    end

    show=0;
    if (show)
      figure(1); clf
      set(gcf,'position',[0,500,1400,600]); % units in pixels!
      gplot2(data,[0:3e5:3e7],yy,zh(1:2000,1)/1e3); hold on; grid on;
      plot(yy, zh(idx,1)/1e3,'ro-')
      plot(yy, zh(idx2,1)/1e3,'ko-')
      ylabel('Altitude agl (km)')
      tmp=datevec(jdi);
      out=sprintf('%4d / %02d / %02d - %02d:%02d frac=%4.2f cld=%d cld2=%d ',...
		  tmp(1),tmp(2),tmp(3),tmp(4),tmp(5),...
		  frac, cld, cld2);
      title(out)
      [x,y,but]=ginput(1);
    end


    step=step+dstep;
  end

  nday=nday+1;
end

for n=1:ntop
  fclose(fid(n));
end


%