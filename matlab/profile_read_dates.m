function [nfile, head, chphy, chraw] = ... 
    profile_read_dates(basedir, datei, datef, dbin, dtime, ach)

timei=datevec(datei)
timef=datevec(datef)

jdi=datenum(timei);
jdf=datenum(timef);
%if (jdf-jdi)>1
%  error('profile_read_dates:: Do not try to read more than a day!');
%end

d1=sprintf('%s/%02d/%d/%02d',basedir,timei(1)-2000,timei(2),timei(3));
f1=dirpath(d1,'RM*');
if (timef(3)>timei(3))
  d2=sprintf('%s/%02d/%d/%02d',basedir,timef(1)-2000,timef(2),timef(3));
  f2=dirpath(d2,'RM*');
  ff={f1{:},f2{:}};
else
  ff=f1;
end

nfile=numel(ff);
if (nfile < 1)
%  error('No files found!');
  ['No files found!'];
  head=[]; chphy=[]; chraw=[];
  return
end
j=0;
filelist={};
for i=1:nfile
  jd=datenum(RMname2date(ff{i}));
  if (jd>=jdi & jd<=jdf)
    j=j+1;
    filelist{j}=ff{i};
  end
end
nfile=numel(filelist);
if (nfile < 1)
%  error('No file found in the time interval!');
  ['No file found in the time interval!'];
  head=[]; chphy=[]; chraw=[];
  return
end

% if dbin not given, displace by zero
if ~exist('dbin','var') dbin=0; end
% if dtime not given, no dead time correction
if ~exist('dtime','var') dtime=0; end
% if ach not requested, return all channels
if ~exist('ach','var') allch=true; else allch=false; end 

if allch
  [head, chphy, chraw] = profile_read_many(filelist, dbin, dtime);
else
  [head, chphy, chraw] = profile_read_many(filelist, dbin, dtime, ach);
end

%