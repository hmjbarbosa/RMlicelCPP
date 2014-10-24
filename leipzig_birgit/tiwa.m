clear all
debug=0;

% windows' size
wsx=250; wsy=650; 
% displacement for next window
wdx=260; xx0=-wsx;
% start position
wdy=0;   yy0=50;

% read physics constants
cte=constants(400., debug);

radiodir='/Users/hbarbosa/SkyDrive/sondagens/dat';
datain='/Users/hbarbosa/DATA/Tiwa_LIDAR';
%lambda=[0.532 0.607]*1e-6; % [m]
lambda=[0.532]*1e-6; % [m]

% date periods
start_jd=datenum('17-Aug-2014 13:00:00');
end_jd=datenum('04-Oct-2014 13:00:00');

% read once just to keep everything in memory
[radiofile allradio alljd]=search_sonde(radiodir,'82332',start_jd);

% info...
fix_lr_aer=55.;
lidar_altitude=50.;

% loop over all dates
nprof=0;
jdi=start_jd;
while jdi<end_jd 
  jdf=jdi+1;

  read_manaus

  % loop sobre os perfis medios de comprimento dt minutos
  save_beta_klett(1:rangebins,1:ntimes)=NaN;
  save_alpha_klett(1:rangebins,1:ntimes)=NaN;

  for k=1:ntimes
    if (count(k)>0)

      radiofile=search_sonde_again(allradio, alljd, times(k));
      snd=read_sonde_Wyoming(radiofile, debug);
      mol=molecular(lambda, snd, cte, debug);

      P(:,1)=glue355(:,k);
      
      bottomlayer=6.5e3;%m
      toplayer=10e3;%m
      rayleigh_fit

      Klett_Manaus
    
      nprof=nprof+1;
      save_beta_klett(:,nprof) = beta_klett(:,1);
      save_alpha_klett(:,nprof) = alpha_klett(:,1);

      %  Raman_Manaus
      %  Raman_beta_Manaus
    end
  end
  
  jdi=jdf;
end

%