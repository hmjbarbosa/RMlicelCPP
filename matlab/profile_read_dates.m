function [nfile, head, chphy, chraw] = ... 
    profile_read_dates(basedir, jdi, jdf, dbin, dtime, ach, maxz)

% if dbin not given, displace by zero
if ~exist('dbin','var') dbin=0; end
if isempty(dbin) dbin=0; end
% if dtime not given, no dead time correction
if ~exist('dtime','var') dtime=0; end
if isempty(dtime) dtime=0; end
% if ach not requested, return all channels
if ~exist('ach','var') ach=0; end 
if isempty(ach) ach=0; end 
% if maxz not requested, return all levels
if ~exist('maxz','var') maxz=0; end 
if isempty(maxz) maxz=0; end 

% Directories are organized by days
% List all files in day-dir from jdi to jdf
jd=jdi; ff={};
while (jd<jdf)
  time=datevec(jd)
  dir=sprintf('%s/%02d/%d/%02d',basedir,time(1)-2000,time(2),time(3));
  tmpf=dirpath(dir,'RM*');
  ff=[ff,tmpf];
  jd=jd+1;
end

% Check if any files were found
nfile=numel(ff);
if (nfile < 1)
  disp(['No files found!']);
  head=[]; chphy=[]; chraw=[];
  return
end

% from all files listed, check those actually in [jdi, jdf]
j=0;
filelist={};
for i=1:nfile
  jd=datenum(RMname2date(ff{i}));
  if (jd>=jdi & jd<=jdf)
    j=j+1;
    filelist{j}=ff{j};
  end
end
nfile=j;

% Check how many files are left
if (nfile < 1)
  disp(['No file found in the time interval!']);
  head=[]; chphy=[]; chraw=[];
  return
end

[head, chphy, chraw] = profile_read_many(filelist, dbin, dtime, ach, maxz);

%