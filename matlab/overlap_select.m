%% ERASE MEMORY
clear all; 
addpath('../sc')
['analysis started @ ' datestr(clock)]; tic

%datain='../../Raymetrics_data';
datain='/media/work/DATA/EMBRAPA/lidar/data';
%datain='/home/lidar_data/data';

%% FIRST DATE
%jdi0=datenum(2012,  1, 20, 0, 0, 0);
jdi0=datenum(2011, 7, 1, 18, 0, 0);
nsel=0; dstep=1./24.;
nday=0;
fid=fopen('list_overlap_select.m','w');
while (nday<=400)

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
    for ch=1:1
      chphy(ch).cs = remove_bg(chphy(ch).data, 500, 3);
    end
  
    %% RANGE CORRECTED SIGNAL
    for i=1:heads(1).ch(1).ndata
      zh(i,1:nfile)=(7.5*i);
    end
    %for ch=1:heads(1).nch
    for ch=1:1
      chphy(ch).rcs = chphy(ch).cs .* zh .* zh;
    end

    %% PLOT
    nslot=floor((jdf-jdi)*1440+1+0.5);
    data(1:2000,1:nslot)=NaN;
    yy=((1:nslot)-1)/1440+jdi;
    
    err=0;
    for i=1:nfile
      j=floor((heads(i).jdi-jdi)*1440+0.5)+2;
      if (j<0)
        disp(['&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&']); 
        ym=get(gca,'ylim');
        y=ym(2)*1.1;
        err=1;
        break
      end
      data(:,j)=chphy(1).rcs(1:2000,i);
    end
    if (err==1)
      break
    end

    frac=sum(sum(isnan(data)))/numel(data);
    [v,idx]=nanmax(data);
    cld=sum(zh(idx,1)>3000 & zh(idx,1)<13000 & v'>2.5e7);

    %figure(1); 
    clf
%    set(gcf,'position',[0,500,1400,600]); % units in pixels!
    gplot2(data,[0:3e5:3e7],yy,zh(1:2000,1)/1e3)
    hold on; plot(yy, zh(idx,1)/1e3,'ro-')
    datetick('x','mm/dd HH:MM')
    xlim([jdi jdf])
    ylabel('Altitude agl (km)')
    tmp=datevec(jdi);
    out=sprintf('%4d / %02d / %02d - %02d:%02d frac=%4.2f cld=%d ',...
                tmp(1),tmp(2),tmp(3),tmp(4),tmp(5),...
                frac, cld);
    title(out)

%    [x,y,but]=ginput(1);
%    if (but==1)
    if (frac<0.25 & cld==0)
      nsel=nsel+1;
      pti(nsel)=jdi;
      ptf(nsel)=jdf;
      disp('***************************************************** selected OK');
      fprintf(fid,'wjdi(%02d)=datenum(''%s''); wjdf(%02d)=datenum(''%s'');\n', ...
               nsel,datestr(pti(nsel)),nsel, datestr(ptf(nsel)));
    else
      disp('***************************************************** NOT selected');
    end
    figure(1)

%    ym=get(gca,'ylim');
%    if (y>ym(2))
%      break
%    end
    step=step+dstep;
  end
%  if (y>ym(2))
%    break
%  end
  nday=nday+1;
end
fclose(fid);

for i=1:nsel
  disp(sprintf('wjdi(%02d)=datenum(''%s''); wjdf(%02d)=datenum(''%s'');',...
	       i,datestr(pti(i)),i,datestr(ptf(i))));
end

%