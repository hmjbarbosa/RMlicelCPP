% read_licel_Hefei.m
% *************************************************************************
% 
%  reading header and lidar data in Licel format, 5 channels
%
%   - Version 1.2                              04/05  Birgit Heese, MIM 
%   - Background correction for analog signal by fit        06/06  BHe
%   - some corrections                                      10/06  BHe
%   - Heifei Lidar                                          11/09  BHe, IfT 
%   - Pretrigger of 6 rangebins and 9 Triggerdelay          06/10  BHe, IfT
% 
% copyright: Birgit Heese, IfT, 06/2010
% ------------------------------------------------------------------------
%   
%  output:
%            alt(rangebins,nfiles)
%           dist(rangebins,nfiles)
%        channel(rangebins,nfiles,4)
%             bg(nfiles,4)
%        bg_corr(rangebins,nfiles,4) 
%            pr2(rangebins,nfiles,4) 
%          datum
%           time 
%    
% *************************************************************************
%
tic  % start processing time
%
disp('*** reading datafiles:');
disp('-----------------------------')
disp('')
filepath = 'D:\RaymetricsManaus\data\';
%
fid=fopen([filepath 'files.dat'],'r');

i=0;
%
while ~feof(fid);
 i=i+1;
 filename(i,:)=fgetl(fid);
end
nfiles = i;
fclose(fid); 
%
% ---------------------------------------
%  open datafiles and read header lines 
% ---------------------------------------
 for i=1:nfiles
 fid = fopen([filepath filename(i,:)],'r');
 disp (filename(i,:))
   for j=1:8
    eval(['headerline' num2str(j) '=fgetl(fid);'])
   end   
%   
% ----------------------------------------------------------       
%  read info from header lines and convert character string to numbers
% ----------------------------------------------------------
           hour1(i) = str2double(headerline2(22:23));   
         minute1(i) = str2double(headerline2(25:26));
         second1(i) = str2double(headerline2(28:29));  
           hour2(i) = str2double(headerline2(42:43));
         minute2(i) = str2double(headerline2(45:46));
         second2(i) = str2double(headerline2(48:49)); 
%
% --------------------------------------------
%  read mesurement times as character strings 
% --------------------------------------------
         hourx1(i,:) = headerline2(22:23); 
       minutex1(i,:) = headerline2(25:26);  
       secondx1(i,:) = headerline2(28:29); 
       
         hourx2(i,:) = headerline2(42:43); 
       minutex2(i,:) = headerline2(45:46);  
       secondx2(i,:) = headerline2(48:49); 
  
       timex1(i,:) = [hourx1(i,:) ':' minutex1(i,:) ':' secondx1(i,:)];     
       timex2(i,:) = [hourx2(i,:) ':' minutex2(i,:) ':' secondx2(i,:)];         

% read further parameters
 
               mV1 = str2double(headerline4(55:59));
               mV2 = str2double(headerline6(55:59));
%          
% ******************************  
   if i==1 % read only once
% ******************************         
         %   height = str2double(headerline2(50:53));
            height = 18; % height above sea level
         longitude = str2double(headerline2(57:61));
          latitude = str2double(headerline2(63:68));
         %elevation = str2double(headerline2(70:71));
         elevation = 90; 
         rangebins = str2double(headerline4(8:12));
       wavelength1 = str2double(headerline4(28:30));
       wavelength2 = str2double(headerline6(28:30));   
           npulses = str2double(headerline4(49:53));
%   
% ----------------------------------------------------------
%   conversion factor for analog signals from both channels
%       from lsb (least significant bit) to mV
% ---------------------------------------------------------
  lsb2mV1 = mV1*1000/4096;		% 12 bit = 2^12 = 4096
  lsb2mV2 = mV2*1000/4096;
% 
% ----------------------------------------
%  Rangebins for background subtraction   
% ----------------------------------------
    upper = rangebins-1000;
    lower = rangebins-2000;
%    
% -----------------------
%  height for the plots
% -----------------------
    rbins = rangebins; 
% 
%  ********** assess channel dimensions **************
% 
            alt = zeros(rangebins,nfiles);
           dist = zeros(rangebins,nfiles);
    channel_raw = zeros(rangebins,nfiles,5);
        channel = zeros(rangebins,nfiles,5);
             bg = zeros(nfiles,5);
        bg_corr = zeros(rangebins,nfiles,5); 
            pr2 = zeros(rangebins,nfiles,5); 
         pr2_dt = zeros(rangebins,nfiles,5); 
      countrate = zeros(rangebins,nfiles,5);
        dt_corr = zeros(rangebins,nfiles,5);
  deadtime_corr = zeros(rangebins,nfiles,5);
%
% ***********************************
    end % i==1 % only once! 
% ***********************************
%
% ----------------------
%  calculate the range 
% ----------------------
       range = 7.5e-3:7.5e-3:rangebins*7.5e-3;  
       range_corr = range.*range;
% 
% --------------          
%  read Data
% --------------          
  dummy = fgetl(fid); % 1 line = crlf
  dataline = fread(fid,5*rangebins+5,'81905*uint32',1);  % 5 times rangebins 32bit binary data + 5 for each crlf! 
%  
% ------------------------------------------------------
%   convert analog signal in mV & PC in counts per puls
% ------------------------------------------------------
  channel_raw(1:rangebins,i,1) = (dataline(1:rangebins)*lsb2mV1)/npulses; % analog
  channel_raw(1:rangebins,i,2) = (dataline(rangebins+2:2*rangebins+1))/npulses; %  pc    
  channel_raw(1:rangebins,i,3) = (dataline(2*rangebins+2:3*rangebins+1)*lsb2mV2)/npulses; %analog
  channel_raw(1:rangebins,i,4) = (dataline(3*rangebins+2:4*rangebins+1))/npulses; %pc
  channel_raw(1:rangebins,i,5) = (dataline(4*rangebins+3:5*rangebins+2))/npulses; %pc
%--------------------------------------------------------------------------
%  pretrigger of 6 rangebins plus triggerdelay to analog channels 9 rangebins
%--------------------------------------------------------------------------
  channel(1:rangebins-15,i,1) = channel_raw(16:rangebins,i,1);
  channel(1:rangebins-6,i,2) = channel_raw(7:rangebins,i,2);
  channel(1:rangebins-15,i,3) = channel_raw(16:rangebins,i,3);
  channel(1:rangebins-6,i,4) = channel_raw(7:rangebins,i,4);
  channel(1:rangebins-6,i,5) = channel_raw(7:rangebins,i,5);

% -------------------------
%  background correction
% -------------------------
for j=1:3
  
%     
    bg(i,j) = mean(channel(lower:upper,i,j));
    bg_corr(:,i,j) = channel(:,i,j) - bg(i,j);
    bg_corr(1:3,i,j) = 0; 
    
% ------------------
%  range correction 
% ------------------
       pr2(:,i,j) = bg_corr(:,i,j).*range_corr';
end 
% -------------------- 
%  height calculation  
% --------------------
      alt(:,i) = height*1e-3+range.*sin(elevation*(pi/180));
% ------------------------------------------------------
%  distance calculation for 'horizontal' measurements 
% ------------------------------------------------------
      dist(:,i) = range.*cos(elevation*(pi/180)); 
% -----------------
%  close data file
% -----------------
   fclose(fid);
% ----------------------------------
end  % ***** number of files i *****
%
% ----------------------------
%   mean profile of all files
% ----------------------------
sum_pr2(:,:) = sum(pr2(:,:,:),2); 
mean_pr2 = sum_pr2(:,:)/nfiles;
sum_bg_corr(:,:) = sum(bg_corr(:,:,:),2); 
mean_bg_corr = sum_bg_corr(:,:)/nfiles;
%
% ------------------------------------
%  read date from the first data file 
% ------------------------------------
      % character
          yearx = headerline2(19:20);  
          monthx = headerline2(14:15);  
          dayx = headerline2(11:12);
      % numbers    
          day = str2double(headerline2(11:12));  
          month = str2double(headerline2(14:15));  
%
%   read date for the next day (for radio sounding at 00 utc)    
% -------------------------------------------------------------
          nextday = day+1; 
      if day < 10
          dayy = ['0' num2str(nextday)];
      else     
          dayy = num2str(nextday);
      end    
%       
       monthy = monthx;
       yeary = yearx;
% 
%  write month in character and chose next month
%  for radio sounding at 00 utc on the fisrt day of the next month
% ------------------------------------------------------------------
        switch month
      case 1
          monat='Jan' ; 
       if day == 31 
          dayy = '01'
          monthy = '02'
       end    
      case 2
          monat='Feb' ; 
       if day == 28 
          dayy = '01'
          monthy = '03'
       end    
      case 3
          monat='Mar' ; 
        if day == 31 
           dayy = '01'
           monthy = '04'
        end    
      case 4
          monat='Apr' ; 
       if day == 30 
          dayy = '01'
          monthy = '05'
       end              
      case 5
          monat='May' ; 
          if day == 31 
            dayy = '01'
            monthy = '06'
          end    
      case 6
          monat='Jun' ; 
       if day == 30 
          dayy = '01'
          monthy = '07'
       end           
     case 7
          monat='Jul' ; 
       if day == 31 
          dayy = '01'
          monthy = '08'
       end              
      case 8
          monat='Aug' ;
       if day == 31 
          dayy = '01'
          monthy = '09'
       end              
      case 9
          monat='Sep' ; 
       if day == 30 
          dayy = '01'
          monthy = '10'
       end           
      case 10
          monat='Oct' ; 
          if day == 31 
            dayy = '01'
            monthy = '11'
          end                        
      case 11
          monat='Nov' ; 
       if day == 30 ;
          dayy = '01';
          monthy = '12';
       end           
      case 12
          monat='Dec' ; 
          if day == 31 
            dayy = '01';
            monthy = '01';
            yeary ='09';
          end                        
      end
          datum = [dayx '-' monat '-20' yearx];  % datum is German for date
          datum2 = [yearx monthx dayx]; 
          datum3 = [yeary monthy dayy]; 

toc  % stop processing time
%       
%
% *************************************************************************
disp('*** End of program: read_licel_Hefei.m, Vers. 1.4 06/10')
