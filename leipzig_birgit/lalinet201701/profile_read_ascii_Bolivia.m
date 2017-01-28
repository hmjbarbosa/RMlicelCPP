% function [head, phy, raw] = profile_read_ascii(fname, dbin, dtime, ach)
%
% Reads a Raymetrics/Licel data file applying an analog displacement,
% and a dead time correction. Data can be output in both physical or
% raw units.
%
% Input:
% 
%   fname: full path to data file
% 
%    dbin: delay, in number of bins, between analog and PC channels
%
%   dtime: dead time (in sec) for a correction like like S/(1-S*dtime)
%
%     ach: read only channel number 'ach', instead of all channels
%
% Output:
%
%    head: Is a matlab structure which contains all information in the
%          file header. It has two extra fields: the matlab
%          julian-day-number of the initial and final dates.
%
%     phy: Is a matrix with vertical bins as rows, and channels as
%          columns. Values are in physical units.
%
%     raw: Is a matrix with vertical bins as rows, and channels as
%          columns. Values are in raw units.
%
function [head, phy] = profile_read_ascii_Bolivia(fname, dbin, dtime, ach, maxz)

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

%% OPEN FILE
fp=fopen(fname,'r');
if (fp < 0)
  error(['fail to open file: ' fname]);
else
  disp(['File= ' fname]);
end
% find out the number of columns
tmp=fgets(fp);
colidx=strfind(tmp,sprintf('\t'));
ncol=length(colidx)+1;
disp(['Number of cols= ' num2str(ncol)]);
if maxz==0
  maxz=ncol-4;
end
fclose(fp);

% find number of lines
[status cmdout]=system(['wc -l ' fname]);
scanCell = textscan(cmdout,'%u %s');
lineCount = scanCell{1};
disp(['Number of lines= ' num2str(lineCount)]);

%% READ ALL DATA
disp(['Reading data...']);
tic
fp=fopen(fname,'r');
%data=fscanf(fp,'%f',[ncol inf]);
data=fscanf(fp,'%f',[ncol lineCount]);
fclose(fp);
toc

%% CREATE HEADER
disp(['Creating header...']);
% bolivia does not use LICEL, we have to invent some fake header info
[PATHSTR,NAME,EXT] = fileparts(fname);
% get date from filename
datei=[str2num(NAME(9:10)), str2num(NAME(6:7)), str2num(NAME(1:4))];
datef=datei;
% get time from first 3 columns
timei=data(1:3,:)';

for i=1:lineCount
  head(i).file=[NAME '.' EXT];
  head(i).site='Bolivia'; 

  head(i).datei=datei;
  head(i).datef=datei;

  head(i).houri=timei(i,:);
  head(i).hourf=timei(i,:);
  
  head(i).jdi=datenum([head(i).datei(3:-1:1) head(i).houri]);
  head(i).jdf=head(i).jdi;
  
  head(i).alt=3420;
  head(i).lon=-68;
  head(i).lat=-16.5;
  head(i).zen=0;
  head(i).idum=0;
  head(i).T0=23;
  head(i).P0=1013;

  head(i).nshoots=3;
  head(i).nhz=10;
  head(i).nshoots2=head(i).nshoots;
  head(i).nhz2=head(i).nhz;
  head(i).nch=1;

  % channel info
  for j = 1:head(i).nch
    head(i).ch(j).active =1;
    head(i).ch(j).photons=0;
    head(i).ch(j).elastic=1;
    head(i).ch(j).ndata  =min(ncol-4, maxz);
    head(i).ch(j).pmtv   =0;
    head(i).ch(j).binw   =data(4,i)*3e8; 
    head(i).ch(j).wlen   =532;
    head(i).ch(j).pol    ='o';
    head(i).ch(j).bits   =0;
    head(i).ch(j).nshoots=3;
    head(i).ch(j).discr  =0;
    head(i).ch(j).tr     =0;
  end
  
end  

phy=data(5:4+head(1).ch(1).ndata , : );



%%