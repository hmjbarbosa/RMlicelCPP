function [head, phy, raw] = profile_read2(fname, dbin, dtime, mych)
%% Reads a Raymetrics Licel lidar data file

if ~exist('dbin','var') dbin=10; end
if ~exist('dtime','var') dtime=0.004; end

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
head.lon=fscanf(fp,'%s',[1,1]);
head.lat=fscanf(fp,'%s',[1,1]);
head.zen=fscanf(fp,'%d',[1,1]);
head.idum=fscanf(fp,'%d',[1,1]);
head.T0=fscanf(fp,'%s',[1,1]);
head.P0=fscanf(fp,'%s',[1,1]);
head.nshoots=fscanf(fp,'%d',[1,1]);
head.nhz=fscanf(fp,'%d',[1,1]);
head.nshoots2=fscanf(fp,'%d',[1,1]);
head.nhz2=fscanf(fp,'%d',[1,1]);
head.nch=fscanf(fp,'%d',[1,1]);

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
  head.tr (1:3,i)=fscanf(fp,'%s',[1,1]);
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
  tmpraw=fread(fp,nz,'int32');
  
  if (ch==mych)
    % copy to final destination
    raw=tmpraw;

    % conversion factor from raw to physical units
    if (head.photons(1,ch)==0)
      dScale = head.nshoots(1,ch)*2^head.bits(1,ch)/(head.discr(1,ch)*1.e3);
    else 
      dScale = head.nshoots(1,ch)/20.;
    end
    
    phy(1:nz)=tmpraw(1:nz)/dScale;

    % for channel 1 and 3, displace by dbin bins
    % for channel 2, 4 and 5, correct dead-time
    if (ch==1 | ch==3)
      % displace by dbin's
      phy(1:nz-dbin) = phy(1+dbin:nz);
      
      % repeat the last dbin values to keep size of vectors
      phy(nz-dbin+1:nz) = phy(nz-dbin+1:nz);
    else
      % correct for dead-time
      phy(1:nz) = phy(1:nz)./(1-phy(1:nz)*dtime);
    end
  end
  
end

%% CLOSE FILE
fclose(fp);

%%