function [nfile, head, chphy, chraw] = ... 
    profile_read_dir(basedir, dbin, dtime, ach, maxz)

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

dir=basedir;
disp(['profile_read_dir::OPENING dir=' dir]);
ff=dirpath(dir,'RM*');

% Check if any files were found
nfile=numel(ff);
if (nfile < 1)
  disp(['profile_read_dir::EMPTY_DAY!']);
  head=[]; chphy=[]; chraw=[];
  return
end

[head, chphy, chraw] = profile_read_many(ff, dbin, dtime, ach, maxz);

%