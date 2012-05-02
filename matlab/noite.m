%% ERASE MEMORY
clear all; 
['analysis started @ ' datestr(clock)]

%% CREATE FILE LIST
filelist=fuf('/media/work/data/EMBRAPA/lidar/data/11/8',[1], 'detail');

nfile = numel(filelist);
if (nfile < 1)
  error('No file found!');
end
nfile

%% READ EACH FILE
ok=0;
for nf=1:nfile  
  % read file
  % get channel in physical units
  % correct anlog delay (10 bins)
  % correct dead-time (0.004 us)
  [head]=head_read(filelist{nf});

  % save time-stamp of current file
  jd(nf)=datenum([head.datef(3:-1:1) head.hourf]);
  day(nf)=datenum([head.datef(3:-1:1) [0 0 0]]);
  
  jd1(nf)=(jd(nf)-day(nf))*24;

  if (jd1(nf)<5. | jd1(nf)>20.)
    ok=ok+1;
  end
  
  if (mod(nf,1000)==0)
    [nf ok]
    [head.hourf jd1(nf)]
  end

end

[nf ok]
[head.hourf jd1(nf)]

%
%