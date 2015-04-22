clear all
close all

debug=0;

%% windows' size
%wsx=250; wsy=650; 
%% displacement for next window
%wdx=260; xx0=-wsx;
%% start position
%wdy=0;   yy0=50;

% read physics constants
cte=constants(400., debug);

radiodir='/Users/hbarbosa/SkyDrive/sondagens/82332/dat';
datain='/Users/hbarbosa/DATA/lidar/data';

lambda=[0.355 0.387]*1e-6; % [m]

% date periods
start_jd=datenum('21-Aug-2014 13:00:00');
end_jd=datenum('3-Oct-2014 13:00:00');

% read once just to keep everything in memory
[radiofile allradio alljd]=search_sonde(radiodir,'82332',start_jd);

% info...
fix_lr_aer=60.;
lidar_altitude=100.;
fix_angstrom=1.2;
dbin=9;
dtime=0.004;

% overlap correction
load /Users/hbarbosa/SkyDrive/faraday/overlap_wide.mat

% loop over all dates
jdi=start_jd;
while jdi<end_jd 
  jdf=min(jdi+1,end_jd);

  % read data between jdi and jdf (1-day appart)
  read_manaus

  if (nfile==0)
    jdi=jdf;
    continue
  end
  
  % loop sobre os perfis medios de comprimento dt minutos
  save_beta_klett(1:rangebins,1:ntimes)=NaN;
  save_alpha_klett(1:rangebins,1:ntimes)=NaN;
  save_beta_raman (1:rangebins,1:ntimes) = nan;
  save_alpha_raman(1:rangebins,1:ntimes) = nan;
  save_ldr_raman  (1:rangebins,1:ntimes) = nan;

  for k=1:ntimes
    save_times(k)=times(k);
    if (count(k)>0)

      radiofile=search_sonde_again(allradio, alljd, times(k));
      snd=read_sonde_Wyoming(radiofile, debug);
      mol=molecular(lambda, snd, cte, debug);

      P(:,1)=glue355(:,k);
      P(:,2)=glue387(:,k);

%      P(1:2000,1)=P(1:2000,1)./overmean(1:2000);
%      P(1:2000,2)=P(1:2000,2)./overmean(1:2000);
      
      bottomlayer=6e3;%m
      toplayer=9e3;%m
      rayleigh_fit

      Klett_Manaus

      save_beta_klett(:,k) = beta_klett(:,1);
      save_alpha_klett(:,k) = alpha_klett(:,1);

      ttt=datevec(times(k));
      if (ttt(4)<6 | ttt(4)>=18)
%      if (ttt(4)<1)
        Raman_Manaus
        Raman_beta_Manaus

        save_beta_raman(:,k) = beta_raman(:,1);
        save_alpha_raman(:,k) = alpha_raman(:,1);
        save_ldr_raman(:,k) = Lidar_Ratio(:);

      else
        save_beta_raman(1:4000,k) = nan;
        save_alpha_raman(1:4000,k) = nan;
        save_ldr_raman(1:4000,k) = nan;
      end
      
    end
  end
  
  save(['embrapa' datestr(times(1)) '.mat'],...
       'save_times','save_beta_klett','save_alpha_klett','save_beta_raman',...
       'save_alpha_raman','save_ldr_raman')
  
  clear glue355 glue387 save_times_save_beta_klett save_alpha_klett
  
  jdi=jdf;
end

%