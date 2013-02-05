%------------------------------------------------------------------------
% M-File:
%    read_ascii_synthetic.m
%
% Authors:
%    H.M.J. Barbosa (hbarbosa@if.usp.br), IF, USP, Brazil
%    B. Hesse (heese@tropos.de), IFT, Leipzig, Germany
%
% Description
%
%    Reads data from Manaus/Embrapa Lidar in ascii format. This
%    version is based on original code written by Birgit Hesse, from
%    iFT, Leipzig. Cleaning, debugging, commenting and modification in
%    variable's names done by hbarbosa.
%
%    File format is shown below. Here only the glued elastic (355nm
%    column #4) and glued raman (387nm column #7) channels are used.
%
%    alt  355 An  355 PC  355 GL 387 An  387 PC  387 GL  407 PC
%     7.5  7.542  285.38  474.00  1.265   97.24   96.25  1.9387
%    15.0  7.343  282.61  461.47  1.241   94.71   94.45  1.8420
%    22.5  7.184  279.49  451.47  1.216   92.16   92.52  1.7977
%    30.0  7.018  276.89  441.07  1.185   89.55   90.21  1.7141
%    37.5  6.640  270.42  417.35  1.162   83.20   88.43  1.5305
%
% Input
%
%    filelist{1} - path and filename to list of elastic files
%    filelist{2} - path and filename to list of raman files
%
% Ouput
%
%    alt_snd(nlev_snd, 1) - column with altitude in m
%
% Usage
%
%    First run: 
%
%        constants.m
%
%    Then execute this script.
%
%------------------------------------------------------------------------


%%------------------------------------------------------------------------
%%  READ DATA
%%------------------------------------------------------------------------

tic  % start processing time
%
disp('*** reading MANAUS datafiles:');
disp('--------------------------------')
disp('')

filepath = '../matlab/data_5min_ascii/';
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
mean_channel = squeeze(nanmean(channel,2));
% these files already have BG removed
% values below BG+3*sigma were transformed into NaN
mean_bg_corr = mean_channel; % 
log_mean_bg_corr = log(mean_bg_corr);
%
for j = 1:3   
  pr2(:,j) = mean_bg_corr(:,j).*range_corr(:);
end
%
%------------------------------------------------------------------------
%  Plots
%------------------------------------------------------------------------
%
%
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
