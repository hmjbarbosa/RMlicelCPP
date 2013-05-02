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
%    rangebins - number of bins in lidar signal
%    r_bin     - vertical resolution in [km]
%    alt  (rangebins, 1) - altitude in [m]
%    altsq(rangebins, 1) - altitude squared in [m2]
%
%    P  (rangebins, 2) - signal to be processed (avg, bg, glue, etc...)
%    Pr2(rangebins, 2) - range corrected signal to be processed 
%
% Usage
%
%    Just execute this script.
%
%------------------------------------------------------------------------
clear filepath filelist
clear channel rangebins
clear alt altsq r_bin P Pr2
clear newP newalt
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
  clear filenames;
  disp(['Reading file list: ' filepath filelist{j}]);
  filenames=importdata([filepath filelist{j}]);
  nfiles = size(filenames,1);
  disp(['Number of files found: ' int2str(nfiles)]);

  % open each file in this list
  for i=1:nfiles
    clear M;
    disp(['File #' int2str(i) ' ' filenames{i}]);
    M=importdata([filepath filenames{i}],' ',1);
    alt = M.data(:,2); % altitude in meters
    % notice: channel(z, lambda, time)
    channel(:,j,i) = M.data(:,3); 
  end
end
toc
rangebins=size(channel,1);

%%------------------------------------------------------------------------
%% RANGE CORRECTION AND OTHER SIGNAL PROCESSING
%%------------------------------------------------------------------------

% calculate the range^2 [m^2]
altsq = alt.*alt;

% bin height in km
r_bin=(alt(2)-alt(1))*1e-3; 

noise=0*randn(size(channel));
%load ruido_ruim.mat
noisechannel=channel+noise;

% matrix to hold lidar received power P(z, lambda)
% anything user needs: time average, bg correction, glueing, etc..
%P=smooth_region(squeeze(nanmean(noisechannel,3)), 3, 400, 7, 800, 10);
P=squeeze(nanmean(noisechannel,3));
%clear channel;

% binning
binsize=5;
span=(binsize-1)/2;
j=1;
for i=span+1:binsize:rangebins-span-1
  newP(j,:)=mean(P(i-span:i+span,:),1);
  newalt(j,1)=mean(alt(i-span:i+span));
  j=j+1;
end
clear P alt
alt=newalt;
altsq=alt.*alt;
P=newP;
r_bin=(alt(2)-alt(1))*1e-3; 
rangebins=size(P,1);

% range bg-corrected signal Pr2(z, lambda)
for j = 1:2
  Pr2(:,j) = P(:,j).*altsq(:);
end

%------------------------------------------------------------------------
%  Plots
%------------------------------------------------------------------------
%
%
figure(1)
xx=xx0+1*wdx; yy=yy0+1*wdy;
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
plot(P(:,1),alt*1.e-3,'b')
xlabel('smooth bg-corr signal','fontsize',[10])  
ylabel('altitude (km)','fontsize',[10])
grid on
hold on
plot(P(:,2),alt*1.e-3,'c')
hold off
%
figure(2)
xx=xx0+2*wdx; yy=yy0+2*wdy;
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
plot(Pr2(:,1),alt*1.e-3,'b')
xlabel('range corrected smooth bg-corr signal','fontsize',[10])  
ylabel('altitude (km)','fontsize',[10])
grid on
hold on 
plot(Pr2(:,2),alt*1.e-3,'c')
hold off
% 
figure(3)
xx=xx0+3*wdx; yy=yy0+3*wdy;
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
plot(log(P(:,1)),alt*1.e-3,'b')
xlabel('log of smooth bg-corr signal','fontsize',[10])  
ylabel('altitude (km)','fontsize',[10])
grid on
hold on
plot(log(P(:,2)),alt*1.e-3,'c')
hold off
% 
% end of program read_ascii_synthetic.m ***    
