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
%   dtime: dead time (in us) for a correction like like S/(1-S*dtime)
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
function [head, phy, raw] = profile_read(fname, dbin, dtime, ach)

% if dbin not given, displace by zero
if ~exist('dbin','var') dbin=0; end
% if dtime not given, no dead time correction
if ~exist('dtime','var') dtime=0; end
% if ach not requested, return all channels
if ~exist('ach','var') ach=0; allch=true; else allch=false; end 

%% OPEN FILE
fp=fopen(fname,'r');

%% READ HEADER (3 LINES)
head.file=fscanf(fp,'%s',[1,1]);
head.site=fscanf(fp,'%s',[1,1]);
head.datei=fscanf(fp,'%2d/%2d/%4d',[1,3]); %% DD MM YY
head.houri=fscanf(fp,'%2d:%2d:%2d',[1,3]); %% hh mn ss
head.datef=fscanf(fp,'%2d/%2d/%4d',[1,3]); %% DD MM YY
head.hourf=fscanf(fp,'%2d:%2d:%2d',[1,3]); %% hh mn ss
head.alt=fscanf(fp,'%d',[1,1]);
head.lon=fscanf(fp,'%f',[1,1]);
head.lat=fscanf(fp,'%f',[1,1]);
head.zen=fscanf(fp,'%d',[1,1]);
head.idum=fscanf(fp,'%d',[1,1]);
head.T0=fscanf(fp,'%f',[1,1]);
head.P0=fscanf(fp,'%f',[1,1]);
head.nshoots=fscanf(fp,'%d',[1,1]);
head.nhz=fscanf(fp,'%d',[1,1]);
head.nshoots2=fscanf(fp,'%d',[1,1]);
head.nhz2=fscanf(fp,'%d',[1,1]);
head.nch=fscanf(fp,'%d',[1,1]);
head.jdi=datenum([head.datei(3:-1:1) head.houri]);
head.jdf=datenum([head.datef(3:-1:1) head.hourf]);

%% READ CHANNEL LINES
for i = 1:head.nch
  head.active (i)=fscanf(fp,'%d',[1,1]);             
  head.photons(i)=fscanf(fp,'%d',[1,1]);             
  head.elastic(i)=fscanf(fp,'%d',[1,1]);             
  head.ndata  (i)=fscanf(fp,'%d 1',[1,1]);           
  head.pmtv   (i)=fscanf(fp,'%d',[1,1]);             
  head.binw   (i)=fscanf(fp,'%f',[1,1]);             
  head.wlen   (i)=fscanf(fp,'%5d.',[1,1]);            
  head.pol    (i)=fscanf(fp,'%1c 0 0 00 000 ',[1,1]);
  head.bits   (i)=fscanf(fp,'%d',[1,1]);             
  head.nshoots(i)=fscanf(fp,'%d',[1,1]);             
  head.discr  (i)=fscanf(fp,'%f',[1,1]);             
  head.tr     (i)={fscanf(fp,'%s',[1,1])};
end

%% FIND FIRST END OF LINE
a=' ';
while (a~=10)
  a=fread(fp,1,'schar'); 
end

nz=head.ndata(1);
for ch = 1:head.nch
  trash=fread(fp,2,'schar'); 

  %% READ RAW CHANNELS
  %raw(1:nz,ch)=fread(fp,nz,'int32');
  tmpraw=fread(fp,nz,'int32');
  
  if (ch==ach | allch)
    % conversion factor from raw to physical units
    if (head.photons(1,ch)==0)
      dScale = head.nshoots(1,ch)*2^head.bits(1,ch)/(head.discr(1,ch)*1.e3);
    else 
      dScale = head.nshoots(1,ch)/20.;
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
    if (allch) 
      phy(1:nz, ch) = tmpphy;
      raw(1:nz, ch) = tmpraw;
    else
      phy(1:nz, 1) = tmpphy;
      raw(1:nz, 1) = tmpraw;
    end
  end
end

% erase uncessary header
if ~allch
  head.active (1)=head.active (ach);
  head.photons(1)=head.photons(ach);
  head.elastic(1)=head.elastic(ach);
  head.ndata  (1)=head.ndata  (ach);
  head.pmtv   (1)=head.pmtv   (ach);
  head.binw   (1)=head.binw   (ach);
  head.wlen   (1)=head.wlen   (ach);
  head.pol    (1)=head.pol    (ach);
  head.bits   (1)=head.bits   (ach);
  head.nshoots(1)=head.nshoots(ach);
  head.discr  (1)=head.discr  (ach);
  head.tr     (1)=head.tr     (ach);

  for i = head.nch:-1:2
    head.active (i)=[];             
    head.photons(i)=[];             
    head.elastic(i)=[];             
    head.ndata  (i)=[];           
    head.pmtv   (i)=[];             
    head.binw   (i)=[];             
    head.wlen   (i)=[];            
    head.pol    (i)=[];
    head.bits   (i)=[];             
    head.nshoots(i)=[];             
    head.discr  (i)=[];             
    head.tr     (i)=[];
  end
  head.nch=1;
end

%% CLOSE FILE
fclose(fp);

%%