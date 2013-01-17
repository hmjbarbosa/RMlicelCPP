%read_ascii_Manaus.m
%
%   06/2012 BHeese
%
%  reads glued ascii data from the Raymetrics Lidar in Embrapa near Manaus 
%
% alt    355 ana  355 pc    355 glued   387 ana  387 pc    387 glued    407 pc
%  7.5    7.5426  285.3874   474.0031    1.2650   97.2419    96.2509    1.9387
% 15.0    7.3432  282.6181   461.4732    1.2413   94.7120    94.4500    1.8420
% 22.5    7.1841  279.4925   451.4758    1.2160   92.1686    92.5277    1.7977
% 30.0    7.0186  276.8932   441.0794    1.1856   89.5527    90.2177    1.7141
% 37.5    6.6409  270.4291   417.3522    1.1622   83.2097    88.4374    1.5305
%
%--------------------------------------------------------------------------
%
clear all
%
tic  % start processing time
%
disp('*** reading MANAUS datafiles:');
disp('--------------------------------')
disp('')
%filepath = './31082011/';
filepath = '../matlab/data_5min_ascii/';
%
fid=fopen([filepath 'files.dat'],'r')

i=0;
while ~feof(fid);
 i=i+1;
 filename(i,:)=fgetl(fid);
end
nfiles = i;
fclose(fid); 
%
datum = [filename(i,6:9) filename(i,11:12) filename(i,14:15)]
%
%rangebins = 4000;
%pr2 = zeros(rangebins,nfiles,3); 
%
% -----------------
%  open datafiles 
% -----------------
for i=1:nfiles
  clear M
  disp (filename(i,:))
  
  M = dlmread([filepath filename(i,:)]);
  
  alt = M(:,1); %*1e-3; % altitude in meters 
  channel(:,i,1) = M(:,4); % 355 glued
  channel(:,i,2) = M(:,7); % 387 glued
  channel(:,i,3) = M(:,8); % 407 glued
  channel(:,i,4) = M(:,2); % 355 ANA
  channel(:,i,5) = M(:,3); % 355 PC
                                                  
  % -----------------------------------------------------------------       
  %  read info from filename and convert character string to numbers
  % -----------------------------------------------------------------
  hour1(i) = str2double(filename(i,17:18));   
  minute1(i) = str2double(filename(i,19:20));  

  % --------------------------------------------
  %  read mesurement times as character strings 
  % --------------------------------------------
  hourx1(i,:) = filename(i,17:18); 
  minutex1(i,:) = filename(i,19:20); 
  timex1(i,:) = [hourx1(i,:) ':' minutex1(i,:)];   
end
toc
rangebins=size(channel,1);

% ----------------------
%  calculate the range^2 [m^2]
% ----------------------
range_corr = alt.*alt;

% bin height in km
r_bin=(alt(2)-alt(1))*1e-3; 

% -----------------------------
%   mean profile of all files
% -----------------------------
addpath('../matlab');
%sum_channel(:,:) = sum(channel(:,:,:),2); 
%mean_channel = sum_channel(:,:)./nfiles;
%hmjb/bb - 4/dec - to skip over nan values in the end of the profile
mean_channel = nanmean(channel,2);
% these files already have BG removed
% values below BG+3*sigma were transformed into NaN
mean_bg_corr = mean_channel; % 
log_mean_bg_corr = log(mean_bg_corr);
%
for j = 1:3   
  pr2(:,j) = mean_bg_corr(:,j).*range_corr(:);
end
%
wsx=300;  wdx=310; xx0=-wsx;
wsy=900; wdy=0;   yy0=30;
figure(1)
xx=xx0+1*wdx; yy=yy0+1*wdy;
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
plot(mean_channel(:,1),alt*1.e-3,'b')
xlabel('smooth bg-corr signal','fontsize',[10])  
ylabel('altitude (km)','fontsize',[10])
title(['Embrapa Lidar at ' datum],'fontsize',[14]) 
grid on
hold on
plot(mean_channel(:,2),alt*1.e-3,'c')
hold off
%
figure(2)
xx=xx0+2*wdx; yy=yy0+2*wdy;
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
plot(pr2(:,1),alt*1.e-3,'b')
xlabel('range corrected smooth bg-corr signal','fontsize',[10])  
ylabel('altitude (km)','fontsize',[10])
title(['Embrapa Lidar at ' datum],'fontsize',[14]) 
grid on
hold on 
plot(pr2(:,2),alt*1.e-3,'c')
hold off
% 
figure(3)
xx=xx0+3*wdx; yy=yy0+3*wdy;
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
plot(log_mean_bg_corr(:,1),alt*1.e-3,'b')
xlabel('log of smooth bg-corr signal','fontsize',[10])  
ylabel('altitude (km)','fontsize',[10])
title(['Embrapa Lidar at ' datum],'fontsize',[14]) 
grid on
hold on
plot(log_mean_bg_corr(:,2),alt*1.e-3,'c')
hold off
% 
% end of program read_ascii_Manaus.m ***    
