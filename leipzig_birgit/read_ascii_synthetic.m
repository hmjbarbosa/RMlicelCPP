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

filepath = datadir;
%'/Users/hbarbosa/Programs/RMlicelUSP/synthetic_signals/';
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

% bin height in [m]
r_bin=(alt(2)-alt(1)); 

% matrix to hold lidar received power P(z, lambda)
% anything user needs: time average, bg correction, glueing, etc..

%P=smooth_region(squeeze(nanmean(channel,3)), 3, 400, 7, 800, 10);
P=squeeze(nanmean(channel,3));
P(:,2)=NaN;
%clear channel;

% binning
binsize=0;
if (binsize)
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
end

% range bg-corrected signal Pr2(z, lambda)
for j = 1:2
  Pr2(:,j) = P(:,j).*altsq(:);
end

%------------------------------------------------------------------------
%  Plots
%------------------------------------------------------------------------
if (debug<2)
  return
end
%
figure
temp=get(gcf,'position'); temp(3)=260; temp(4)=650;
set(gcf,'position',temp); % units in pixels!
plot(P(:,1),alt*1.e-3,'b','linewidth',1.5)
xlabel('P(r)','fontsize',[14])  
ylabel('altitude (km)','fontsize',[14])
grid on
hold on
plot(P(:,2),alt*1.e-3,'c')
hold off;ylim([0 20])
%
if (debug<3)
  return
end
set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8]);
prettify(gca); grid on;
print('earlinet_P.png','-dpng');

figure
temp=get(gcf,'position'); temp(3)=260; temp(4)=650;
set(gcf,'position',temp); % units in pixels!
plot(Pr2(:,1),alt*1.e-3,'b','linewidth',1.5)
xlabel('P(r)*r2','fontsize',[14])  
ylabel('altitude (km)','fontsize',[14])
grid on
hold on 
plot(Pr2(:,2),alt*1.e-3,'c')
hold off;ylim([0 20])
set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8]);
prettify(gca); grid on;
print('earlinet_Pr2.png','-dpng');

% 
figure
temp=get(gcf,'position'); temp(3)=260; temp(4)=650;
set(gcf,'position',temp); % units in pixels!
plot(log(P(:,1)),alt*1.e-3,'b','linewidth',1.5)
xlabel('log(P(r)*r2)','fontsize',[14])  
ylabel('altitude (km)','fontsize',[14])
grid on
hold on
plot(log(P(:,2)),alt*1.e-3,'c')
hold off;ylim([0 20])
set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8]);
prettify(gca); grid on;
print('earlinet_logPr2.png','-dpng');


% 
% end of program read_ascii_synthetic.m ***    
