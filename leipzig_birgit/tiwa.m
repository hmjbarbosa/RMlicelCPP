clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% USER CONFIG

% Level of debuging messages and graphs
debug=0;

% Radiosonde station ID
stationid='82332';

% Location of radiosonde files. Expected directory structure is: 
%    radiodir/stationid_YYYY_MM_DD_HHZ.dat
%    YYYY year with 4 digits
%    MM   month with 2 digits
%    DD   day with 2 digits
radiodir=['/Users/hbarbosa/Dropbox/00_ANALYSIS/sondagens/' stationid '/dat'];

datain='/Users/hbarbosa/DATA/Tiwa_LIDAR';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read physics constants
cte=constants(400., debug);

lambda=[0.532 0.607]*1e-6; % [m]

% date periods
%start_jd=datenum('17-Aug-2014 13:00:00');
start_jd=datenum('11-Sep-2014 19:00:00');
end_jd=datenum('12-Sep-2014 5:00:00');
%end_jd=datenum('04-Oct-2014 13:00:00');

% read once just to keep everything in memory
[radiofile allradio alljd]=search_sonde(radiodir,'82332',start_jd);

% info...
fix_lr_aer=60.;
lidar_altitude=50.;
fix_angstrom=1.2;
dbin=9;
dtime=0.004;

% loop over all dates
jdi=start_jd;
while jdi<end_jd 
  jdf=min(jdi+1,end_jd);

  read_tiwa

  % loop sobre os perfis medios de comprimento dt minutos
  save_beta_klett(1:rangebins,1:ntimes)=NaN;
  save_alpha_klett(1:rangebins,1:ntimes)=NaN;
  save_beta_raman (1:rangebins,1:ntimes) = nan;
  save_alpha_raman(1:rangebins,1:ntimes) = nan;
  save_ldr_raman  (1:rangebins,1:ntimes) = nan;

  for k=1:ntimes
    save_times(k)=times(k);
    tmp=datevec(times(k));
    % night time only
    if (count(k)>0 & (tmp(4)<5 | tmp(4)>6))
debug=0;
      radiofile=search_sonde_again(allradio, alljd, times(k));
      snd=read_sonde_Wyoming(radiofile, debug);
      mol=molecular(lambda, snd, cte, debug);

      P(:,1)=glue355(:,k);
      P(:,2)=glue387(:,k);
      
      bottomlayer=25e3;%m
      toplayer=35e3;%m
debug=5;
clear fix_lr_aer
LR_par(1:1467,1)=60;
LR_par(1468:8190,1)=22;
      rayleigh_fit

      Klett_Manaus
    
      save_beta_klett(:,k) = beta_klett(:,1);
      save_alpha_klett(:,k) = alpha_klett(:,1);
      
      %  Raman_Manaus
      %  Raman_beta_Manaus
    end
  end
  
  save(['tiwa' datestr(times(1)) '.mat'],...
       'save_times','save_beta_klett','save_alpha_klett')
  
%  clear glue355 glue387 save_times_save_beta_klett save_alpha_klett
  
  jdi=jdf;
end

%