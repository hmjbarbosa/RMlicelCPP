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
function [head, phy] = profile_read_ascii(fname, dbin, dtime, ach, maxz)

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
end

%% READ HEADER LINE #1
head.file=fscanf(fp,'%s',[1,1]);

%% LINE #2
head.site=''; %fscanf(fp,'%s',[1,1]);
%% some site might have spaces.
%% keep reading until we find something like ??/??/????
pos=ftell(fp);
[tmp, n]=fscanf(fp,'%s',[1,1]);
while (length(tmp)~=10 || tmp(3)~='/' || tmp(6)~='/')
  head.site=[head.site ' ' tmp];
  pos=ftell(fp);
  [tmp,n]=fscanf(fp,'%s',[1,1]);
end
fseek(fp,pos,'bof');

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

%% READ PHY CHANNELS

% jump extra line
tmp=fgets(fp);
tmp=fgets(fp);

% takes 0.3 sec for 100 files
% close to 0.07 for reading the binary files
phy=fscanf(fp,'%f',[head.nch head.ch(1).ndata])';

fclose(fp);

% takes 4 sec for 100 files
%phy=dlmread(fname,'\t',3+head.nch+1,0);

% takes 2 sec for 100 files
%tmp=importdata(fname,'\t',3+head.nch+1);
%phy=tmp.data;

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