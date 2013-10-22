% function [head, phy, raw] = profile_read(fname, dbin, dtime, ach)
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
function [head, phy, raw] = profile_read(fname, dbin, dtime, ach, maxz)

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

%% READ HEADER LINE #1
head.file=fscanf(fp,'%s',[1,1]);

%% LINE #2
head.site=fscanf(fp,'%s',[1,1]);
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

%% FIND FIRST END OF LINE
a=' ';
while (a~=10)
  a=fread(fp,1,'schar'); 
end

for ch = 1:head.nch
  nz=head.ch(ch).ndata;
  trash=fread(fp,2,'schar'); 

  %% READ RAW CHANNELS
  tmpraw=fread(fp,nz,'int32');
    
  if (ch==ach | ach==0)
    % conversion factor from raw to physical units
    if (head.ch(ch).photons==0)
      dScale = head.ch(ch).nshoots*2^head.ch(ch).bits/(head.ch(ch).discr*1.e3);
    else 
      dScale = head.ch(ch).nshoots/20.;
    end
    tmpphy=tmpraw/dScale;
    
    % for channel 1 and 3, displace by dbin bins
    % for channel 2, 4 and 5, correct dead-time
    if (ch==1 | ch==3)
      % displace by dbin's
      tmpphy(1:nz-dbin) = tmpphy(1+dbin:nz);
      
      % repeat the last dbin values to keep size of vectors
      tmpphy(nz-dbin+1:nz) = tmpphy(nz-dbin+1:nz);
    else
      % correct for dead-time
      tmpphy(1:nz) = tmpphy(1:nz)./(1-tmpphy(1:nz)*dtime);
    end
    
    % copy to final destination
    if (maxz==0)
      maxz=nz;
    else
      maxz=min(nz, maxz);
      head.ch(ch).ndata=maxz;
    end
    if (ach==0) 
      phy(1:maxz, ch) = tmpphy(1:maxz);
      raw(1:maxz, ch) = tmpraw(1:maxz);
    else
      phy(1:maxz, 1) = tmpphy(1:maxz);
      raw(1:maxz, 1) = tmpraw(1:maxz);
    end
  end
end

% erase uncessary header
if ~(ach==0)
  head.ch(1).active  = head.ch(ach).active ;
  head.ch(1).photons = head.ch(ach).photons;
  head.ch(1).elastic = head.ch(ach).elastic;
  head.ch(1).ndata   = head.ch(ach).ndata  ;
  head.ch(1).pmtv    = head.ch(ach).pmtv   ;
  head.ch(1).binw    = head.ch(ach).binw   ;
  head.ch(1).wlen    = head.ch(ach).wlen   ;
  head.ch(1).pol     = head.ch(ach).pol    ;
  head.ch(1).bits    = head.ch(ach).bits   ;
  head.ch(1).nshoots = head.ch(ach).nshoots;
  head.ch(1).discr   = head.ch(ach).discr  ;
  head.ch(1).tr      = head.ch(ach).tr     ;

  for i = head.nch:-1:2
    head.ch(i).active  = [];             
    head.ch(i).photons = [];             
    head.ch(i).elastic = [];             
    head.ch(i).ndata   = [];           
    head.ch(i).pmtv    = [];             
    head.ch(i).binw    = [];             
    head.ch(i).wlen    = [];            
    head.ch(i).pol     = [];
    head.ch(i).bits    = [];             
    head.ch(i).nshoots = [];             
    head.ch(i).discr   = [];             
    head.ch(i).tr      = [];
  end
  head.nch=1;
end

%% CLOSE FILE
fclose(fp);

%%