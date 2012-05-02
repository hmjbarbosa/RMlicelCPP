function [head] = head_read(fname)
%%function [head, varargout] = profile_read(fname, dbin, dtime)
%% Reads a Raymetrics Licel lidar data file

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

%% CLOSE FILE
fclose(fp);

%%