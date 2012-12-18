%read_ascii_synthetic.m
%   12/2012 hbarbosa
%   06/2012 BHeese
%
%  reads glued ascii data from the Raymetrics Lidar in Embrapa near Manaus 
%
%  index    alt    Some channels
%  1        7.5    7.5426
%  2       15.0    7.3432
%  3       22.5    7.1841
%  4       30.0    7.0186
%  5       37.5    6.6409
%
%--------------------------------------------------------------------------
%
clear all
%
tic  % start processing time
%
disp('*** reading SYNTHETIC datafiles:');
disp('--------------------------------')
disp('')
filepath = '/home/hbarbosa/Programs/RMlicelUSP/synthetic_signals/';
filelist{1}='Elastic_wv1';
filelist{2}='Raman_wv1';
filelist{3}='Elastic_wv2';
filelist{4}='Raman_wv2';
filelist{5}='Elastic_wv3';

for j=1:5
  disp (filelist{j});
  
  % -----------------
  % open file list 
  % -----------------
  clear filename fid;
  [filepath filelist{j}]
  pwd
  [filepath filelist{j}]
  [fid, message]=fopen([filepath filelist{j}],'r')
  i=0;
  while ~feof(fid);
    i=i+1;
    filename(i,:)=fgetl(fid);
  end
  nfiles = i;
  fclose(fid); 

  % -----------------
  %  open datafiles in the j-th list 
  % -----------------
  for i=1:nfiles
    clear M;
    disp (filename(i,:))
    
    M = importdata([filepath filename(i,:)],' ',1);
  
    alt = M.data(:,2); % altitude in meters 
    channel(:,i,j) = M.data(:,3); 
                                                  
  end
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
mean_channel = squeeze(nanmean(channel,2));
% need to do bg correction??
addpath('../matlab');
mean_bg_corr = smooth_region(mean_channel, 3, 400, 7, 800, 10);
log_mean_bg_corr = log(mean_bg_corr);
%
for j = 1:3   
  pr2(:,j) = mean_bg_corr(:,j).*range_corr(:);
end
%
figure(1)
plot(mean_channel(:,1),alt*1.e-3,'b')
xlabel('glued bg corr signal','fontsize',[10])  
ylabel('altitude (km)','fontsize',[10])
title(['EARLINET exercize'],'fontsize',[14]) 
grid on
hold on
plot(mean_channel(:,2),alt*1.e-3,'c')
%plot(mean_channel(:,3),alt*1.e-3,'r')
%
figure(2)
plot(pr2(:,1),alt*1.e-3,'b')
xlabel('range corrected glued signal','fontsize',[10])  
ylabel('altitude (km)','fontsize',[10])
title(['EARLINET exercize'],'fontsize',[14]) 
grid on
hold on 
plot(pr2(:,2),alt*1.e-3,'c')
%plot(pr2(:,3),alt*1.e-3,'r')
% 
figure(3)
plot(log_mean_bg_corr(:,1),alt*1.e-3,'b')
xlabel('log of glued bg corr signal','fontsize',[10])  
ylabel('altitude (km)','fontsize',[10])
title(['EARLINET exercize'],'fontsize',[14]) 
grid on
hold on
plot(log_mean_bg_corr(:,2),alt*1.e-3,'c')
%plot(log_mean_bg_corr(:,3),alt*1.e-3,'r')
% 
% end of program read_ascii_synthetic.m ***    
