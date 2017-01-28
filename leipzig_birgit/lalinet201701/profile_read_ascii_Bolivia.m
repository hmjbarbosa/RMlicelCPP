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

% bolivia does not use LICEL, we have to invent some fake header info
[PATHSTR,NAME,EXT] = fileparts(fname);
head.file=[NAME '.' EXT];

% site name is not defined
head.site='Bolivia'; 

% get date from filename
head.datei=[str2num(NAME(1:4)), str2num(NAME(6:7)), str2num(NAME(9:10))];
head.datef=head.datei;

%% OPEN FILE
fp=fopen(fname,'r');
if (fp < 0)
  error(['fail to open file: ' fname]);
end
% find out the number of columns
tmp=fgets(fp);
tmp=strfind(tmp,sprintf('\t'));
ncol=length(tmp)+1;
% find number of lines

%fclose(fp)

%% READ ALL DATA

%fp=fopen(fname,'r');
i=1;
while ~isempty(tmp)
    data(i,:)=fscanf(fp,'%f',ncol);
    tmp=fgets(fp); i=i+1
end
fclose(fp);
phy=data;
return

head.datei=fscanf(fp,'%2d/%2d/%4d',[1,3]); %% DD MM YY
head.houri=fscanf(fp,'%2d:%2d:%2d',[1,3]); %% hh mn ss
head.datef=fscanf(fp,'%2d/%2d/%4d',[1,3]); %% DD MM YY
head.hourf=fscanf(fp,'%2d:%2d:%2d',[1,3]); %% hh mn ss
head.jdi=datenum([head.datei(3:-1:1) head.houri]);
head.jdf=datenum([head.datef(3:-1:1) head.hourf]);

head.alt=fscanf(fp,'%d',[1,1]);
lon=fscanf(fp,'%s',[1,1]);  lon(lon==',')='.'; head.lon=str2num(lon);    
lat=fscanf(fp,'%s',[1,1]); lat(lat==',')='.'; head.lat=str2num(lat);
% Some old Licel does not include 00, T0 and P0 in this line. So we
% need to read the rest of the line, and from that try to read what we
% want. 
tmp=fgets(fp);
[A,n]=sscanf(tmp,'%s %s %s %s');
if n>=1
  zen=A(1); zen(zen==',')='.'; head.zen=str2num(zen);    
end
if n>=2
  idum=A(2); idum(idum==',')='.'; head.idum=str2num(idum);
end
if n>=3
  T0=A(3); T0(T0==',')='.'; head.T0=str2num(T0);
end
if n>=4
  P0=A(4); P0(P0==',')='.'; head.P0=str2num(P0);        
end

%% LINE #3
head.nshoots=fscanf(fp,'%d',[1,1]);
head.nhz=fscanf(fp,'%d',[1,1]);
head.nshoots2=fscanf(fp,'%d',[1,1]);
head.nhz2=fscanf(fp,'%d',[1,1]);
head.nch=fscanf(fp,'%d',[1,1]);

%% READ CHANNEL LINES
for i = 1:head.nch
  head.ch(i).active =fscanf(fp,'%d',[1,1]);             
  head.ch(i).photons=fscanf(fp,'%d',[1,1]);             
  head.ch(i).elastic=fscanf(fp,'%d',[1,1]);             
  head.ch(i).ndata  =fscanf(fp,'%d 1',[1,1]);           
  head.ch(i).pmtv   =fscanf(fp,'%d',[1,1]);             
  head.ch(i).binw   =fscanf(fp,'%f',[1,1]);             
  head.ch(i).wlen   =fscanf(fp,'%5d.',[1,1]);            
  head.ch(i).pol    =fscanf(fp,'%1c 0 0 00 000 ',[1,1]);
  head.ch(i).bits   =fscanf(fp,'%d',[1,1]);             
  head.ch(i).nshoots=fscanf(fp,'%d',[1,1]);             
  head.ch(i).discr  =fscanf(fp,'%f',[1,1]);             
  head.ch(i).tr     ={fscanf(fp,'%s',[1,1])};
end

% jump extra line

tmp=fgets(fp);

% takes 0.3 sec for 100 files
% close to 0.07 for reading the binary files
phy=fscanf(fp,'%f',[head.nch head.ch(1).ndata])';

fclose(fp);

% copy to final destination
nz=head.ch(1).ndata;
if (maxz==0)
    maxz=nz;
else
    maxz=min(nz, maxz);
    for ch=1:head.nch
        head.ch(ch).ndata=maxz;
    end
end

if (ach==0) 
    phy = phy(1:maxz,:);
else
    phy = phy(1:maxz,ach);
    head.ch = head.ch(ach);
    head.nch = 1;
end

%%