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
clear 
%
tic  % start processing time
%
disp('*** reading datafiles:');
disp('-----------------------------')
disp('')
%filepath = 'D:\RaymetricsManaus\31082011\';
filepath = '/media/work/data/EMBRAPA/lidar/31082011/';
%
fid=fopen([filepath 'files.dat'],'r')

i=0;
%
while ~feof(fid);
 i=i+1;
 filename(i,:)=fgetl(fid);
end
nfiles = i;
fclose(fid); 
%
datum = [filename(i,6:9) filename(i,11:12) filename(i,14:15)]
%
%
rangebins = 4000;
%pr2 = zeros(rangebins,nfiles,3); 
%
% -----------------
%  open datafiles 
% -----------------
 for i=1:nfiles
 clear M
 disp (filename(i,:))

M = dlmread([filepath filename(i,:)]);

                     alt = M(1:rangebins,1);%*1e-3; 
channel(1:rangebins,i,4) = M(1:rangebins,2); 
channel(1:rangebins,i,5) = M(1:rangebins,3); 
channel(1:rangebins,i,1) = M(1:rangebins,4);    % 355 glued
channel(1:rangebins,i,2) = M(1:rangebins,7);    % 387 glued
channel(1:rangebins,i,3) = M(1:rangebins,8);    % 407 glued
%   
% -----------------------------------------------------------------       
%  read info from filename and convert character string to numbers
% -----------------------------------------------------------------
           hour1(i) = str2double(filename(i,17:18));   
         minute1(i) = str2double(filename(i,19:20));  
%
% --------------------------------------------
%  read mesurement times as character strings 
% --------------------------------------------
         hourx1(i,:) = filename(i,17:18); 
       minutex1(i,:) = filename(i,19:20); 
         timex1(i,:) = [hourx1(i,:) ':' minutex1(i,:)];   
 end
 toc
            
% ----------------------
%  calculate the range 
% ----------------------
       range_corr = alt.*alt;
% -----------------------------
%   mean profile of all files
% -----------------------------
     sum_channel(:,:) = sum(channel(:,:,:),2); 
     mean_channel = sum_channel(:,:)./nfiles;
     mean_bg_corr = mean_channel; % 
     log_mean_bg_corr = log(mean_bg_corr);
     
 for j = 1:3   
     pr2(:,j) = mean_bg_corr(:,j).*range_corr(:);
 end
 %
 figure(1)
 plot(mean_channel(:,1),alt,'b')
 %plot(mean_channel(:,4),alt,'c')
 %plot(mean_channel(:,5),alt,'c--')
 xlabel('glued bg corr signal','fontsize',[10])  
 ylabel('altitude','fontsize',[10])
 title(['Embrapa Lidar at ' datum],'fontsize',[14]) 
 hold on
 plot(mean_channel(:,2),alt,'c')
 plot(mean_channel(:,3),alt,'r')
 
 figure(2)
  plot(pr2(:,1),alt,'b')
  xlabel('range corrected glued signal','fontsize',[10])  
 ylabel('altitude','fontsize',[10])
 title(['Embrapa Lidar at ' datum],'fontsize',[14]) 

 hold on 
 plot(pr2(:,2),alt,'c')
 plot(pr2(:,3),alt,'r')
 
 figure(3)
 plot(log_mean_bg_corr(:,1),alt,'b')
 xlabel('log of glued bg corr signal','fontsize',[10])  
 ylabel('altitude','fontsize',[10])
 title(['Embrapa Lidar at ' datum],'fontsize',[14]) 
 hold on
 plot(log_mean_bg_corr(:,2),alt,'c')
 plot(log_mean_bg_corr(:,3),alt,'r')
 
 % end of program read_ascii_Manaus.m ***    
     
     
