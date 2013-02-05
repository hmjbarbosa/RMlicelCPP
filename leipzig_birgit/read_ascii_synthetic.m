%------------------------------------------------------------------------
% M-File:
%    read_ascii_synthetic.m
%
% Authors:
%    H.M.J. Barbosa (hbarbosa@if.usp.br), IF, USP, Brazil
%
% Description
%
%    Reads ascii files with EARLINET's synthetic lidar signals.
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

filepath = '/home/hbarbosa/Programs/RMlicelUSP/synthetic_signals/';
filelist{1}='Elastic_wv1';
filelist{2}='Raman_wv1';

% Loop over elastic and raman file lists
tic
for j=1:2
  
  % open file list of j-th channel
  clear filename;
  disp(['Reading file list: ' filepath filelist{j}]);
  filename=importdata([filepath filelist{j}]);
  nfiles = size(filename,1);
  disp(['Number of files found: ' int2str(nfiles)]);

  % open each file in this list
  for i=1:nfiles
    clear M;
    disp(['File #' int2str(i) ' ' filename{i}]);
    M=importdata([filepath filename{i}],' ',1);
    alt = M.data(:,2); % altitude in meters 
    channel(:,j,i) = M.data(:,3); 
  end
end
toc
rangebins=size(channel,1);

%%------------------------------------------------------------------------
%% RANGE CORRECTION AND OTHER SIGNAL PROCESSING
%%------------------------------------------------------------------------

% calculate the range^2 [m^2]
range_corr = alt.*alt;

% bin height in km
r_bin=(alt(2)-alt(1))*1e-3; 

% time average 
mean_channel = squeeze(nanmean(channel,3));

% smoothing
addpath('../matlab');
mean_bg_corr = smooth_region(mean_channel, 3, 400, 7, 800, 10);

% range bg-corrected signal
for j = 1:2
  pr2(:,j) = mean_bg_corr(:,j).*range_corr(:);
end

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
title(['EARLINET exercize'],'fontsize',[14]) 
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
title(['EARLINET exercize'],'fontsize',[14]) 
grid on
hold on 
plot(pr2(:,2),alt*1.e-3,'c')
hold off
% 
figure(3)
xx=xx0+3*wdx; yy=yy0+3*wdy;
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
plot(log(mean_bg_corr(:,1)),alt*1.e-3,'b')
xlabel('log of smooth bg-corr signal','fontsize',[10])  
ylabel('altitude (km)','fontsize',[10])
title(['EARLINET exercize'],'fontsize',[14]) 
grid on
hold on
plot(log(mean_bg_corr(:,2)),alt*1.e-3,'c')
hold off
% 
% end of program read_ascii_synthetic.m ***    
