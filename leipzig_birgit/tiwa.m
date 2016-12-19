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
start_jd=datenum('17-Aug-2014 13:00:00');
end_jd=datenum('03-Oct-2014 13:00:00');

start_jd=datenum('1-Sep-2014 13:00:00');
end_jd=datenum('2-Sep-2014 13:00:00');

% read once just to keep everything in memory
[radiofile allradio alljd]=search_sonde(radiodir,'82332',start_jd);

% info...
fix_lr_aer=70.;
lidar_altitude=50.;
fix_angstrom=1.2;
dbin=9;
dtime=0.004;

% overlap correction
load overlap_tiwa.mat

% loop over all dates
jdi=start_jd;
while jdi<end_jd 
  jdf=min(jdi+1439/1440,end_jd);

  % read data between jdi and jdf (1-day appart)
  read_tiwa

  if (nfile==0)
    jdi=jdi+1;
    continue
  end
  
  % loop sobre os perfis medios de comprimento dt minutos
  save_beta_klett (1:4000,1:ntimes)=NaN;
  save_alpha_klett(1:4000,1:ntimes)=NaN;
  save_beta_raman (1:4000,1:ntimes)=NaN;
  save_alpha_raman(1:4000,1:ntimes)=NaN;
  save_ldr_raman  (1:4000,1:ntimes)=NaN;

  %save_beta_klett_over (1:4000,ntimes) = nan;
  %save_alpha_klett_over(1:4000,ntimes) = nan;
  %save_beta_raman_over (1:4000,ntimes) = nan;
  %save_alpha_raman_over(1:4000,ntimes) = nan;
  %save_ldr_raman_over  (1:4000,ntimes) = nan;
  %save_overlap(1:4000,ntimes)=nan;

  for k=1:ntimes
    save_times(k)=times(k);
    if (count(k)>0)

      disp('--------------------------------------------------------------------')
      disp(datestr(times(k)))
      radiofile=search_sonde_again(allradio, alljd, times(k));
      snd=read_sonde_Wyoming(radiofile, debug);
      mol=molecular(lambda, snd, cte, debug);

      P(:,1)=glue355(:,k);
      P(:,2)=nanmysmooth(glue387(:,k),0,20);

      % apply overlap correction
      P(1:600,1)=P(1:600,1)./meanover(1:600);
      P(1:600,2)=P(1:600,2)./meanover(1:600);
      
      bottomlayer=6e3;%m
      toplayer=9e3;%m
      rayleigh_fit

      Klett_Manaus
    
      save_beta_klett(1:4000,k) = beta_klett(1:4000,1);
      save_alpha_klett(1:4000,k) = alpha_klett(1:4000,1);

      ttt=datevec(times(k));
      if (ttt(4)<6 | ttt(4)>=18)
        %debug=10;
        Raman_Manaus
        Raman_beta_Manaus

        save_beta_raman(1:4000,k) = beta_raman(1:4000,1);
        save_alpha_raman(1:4000,k) = alpha_raman(1:4000,1);
        save_ldr_raman(1:4000,k) = Lidar_Ratio(1:4000);
        
        %% try to calculate the overlap
        %% n=650 => 4.875km
        %n=650
        %Ulla_Overlap
        %
        %% now re-calculate Klett
        %Klett_Manaus
        %
        %% and also alfa raman
        %Raman_Manaus
        %
        %% and the LR
        %Lidar_Ratio(bin1st:maxbin) = ...
        %    nanmysmooth(alpha_raman(bin1st:maxbin),10,100)./...
        %    nanmysmooth(beta_raman,30,300);
        %
        %save_beta_klett_over(1:4000,k) = beta_klett(1:4000,1);
        %save_alpha_klett_over(1:4000,k) = alpha_klett(1:4000,1);
        %save_beta_raman_over(1:4000,k) = beta_raman(1:4000,1);
        %save_alpha_raman_over(1:4000,k) = alpha_raman(1:4000,1);
        %save_ldr_raman_over(1:4000,k) = Lidar_Ratio(1:4000);
        %save_overlap(1:n,k) = overlap(1:n);

      else
        save_beta_raman (1:4000,k) = nan;
        save_alpha_raman(1:4000,k) = nan;
        save_ldr_raman  (1:4000,k) = nan;

        %save_beta_klett_over (1:4000,k) = nan;
        %save_alpha_klett_over(1:4000,k) = nan;
        %save_beta_raman_over (1:4000,k) = nan;
        %save_alpha_raman_over(1:4000,k) = nan;
        %save_ldr_raman_over  (1:4000,k) = nan;
        %save_overlap(1:4000,k) = nan;
      end
      
    end
  end

tmp=datevec(jdi);
if tmp(3)==1
  save_beta_raman (:,37:38)=nan;
  save_alpha_raman(:,37:38)=nan;
end
if tmp(3)==2
  save_beta_raman (:,59:60)=nan;
  save_alpha_raman(:,59:60)=nan;
end
if tmp(3)==3
  save_beta_raman (:,58:59)=nan;
  save_alpha_raman(:,58:59)=nan;
end
if tmp(3)==4
  save_beta_raman (:,50:52)=nan;
  save_alpha_raman(:,50:52)=nan;
  save_beta_raman (:,54)=nan;
  save_alpha_raman(:,54)=nan;
  save_beta_raman (:,59:60)=nan;
  save_alpha_raman(:,59:60)=nan;
end
if tmp(3)==5
  save_beta_raman (:,37)=nan;
  save_alpha_raman(:,37)=nan;
  save_beta_raman (:,56:59)=nan;
  save_alpha_raman(:,56:59)=nan;
end
if tmp(3)==7
  save_beta_raman (:,1:40)=nan;
  save_alpha_raman(:,1:40)=nan;
  save_beta_raman (:,50:end)=nan;
  save_alpha_raman(:,50:end)=nan;
end
if tmp(3)==9
  save_beta_raman (:,1:54)=nan;
  save_alpha_raman(:,1:54)=nan;
end
if tmp(3)==10
  save_beta_raman (:,41)=nan;
  save_alpha_raman(:,41)=nan;
  save_beta_raman (:,50:51)=nan;
  save_alpha_raman(:,50:51)=nan;
end

nntop=800;
figure(102); clf
[h bar]=gplot2(save_alpha_raman(50:nntop,:)*1e6,[0:1:200],times,alt(50:nntop)*1e-3);
ylabel(bar,'Extinction (Mm-1)')
title([datestr(heads(1).jdi) ' to ' datestr(heads(end).jdf)])
xlim([jdi jdi+1])
datetick('x',15,'keeplimits')
xlabel('Time (#)')
ylabel('Altitude (km)'); ylim([0 6])
prettify(gca,bar); grid
drawnow
print(['T2_Alpha_Raman_' num2str(tmp(3)) '_' num2str(tmp(2)) '.png'],'-dpng')

figure(103); clf
plot(nanmean(save_alpha_raman(50:nntop,:),2)*1e6,alt(50:nntop)*1e-3);
title([datestr(heads(1).jdi) ' to ' datestr(heads(end).jdf)])
xlim([0 200])
xlabel('Extinction Raman (Mm-1)')
ylabel('Altitude (km)'); ylim([0 6])
prettify(gca); grid
drawnow
print(['T2_Alpha_RamanProf_' num2str(tmp(3)) '_' num2str(tmp(2)) '.png'],'-dpng')

figure(104); clf
[h bar]=gplot2(save_beta_raman(50:nntop,:)*1e6,[0:0.03:3],times,alt(50:nntop)*1e-3);
ylabel(bar,'Backscattering (Mm-1 sr-1)')
title([datestr(heads(1).jdi) ' to ' datestr(heads(end).jdf)])
xlim([jdi jdi+1])
datetick('x',15,'keeplimits')
xlabel('Time (#)')
ylabel('Altitude (km)'); ylim([0 6])
prettify(gca,bar); grid
drawnow
print(['T2_Beta_Raman_' num2str(tmp(3)) '_' num2str(tmp(2)) '.png'],'-dpng')

figure(105); clf
plot(nanmean(save_beta_raman(50:nntop,:),2)*1e6,alt(50:nntop)*1e-3);
title([datestr(heads(1).jdi) ' to ' datestr(heads(end).jdf)])
xlim([0 5])
xlabel('Backscattering (Mm-1 sr-1)')
ylabel('Altitude (km)'); ylim([0 6])
prettify(gca); grid
drawnow
print(['T2_Beta_RamanProf_' num2str(tmp(3)) '_' num2str(tmp(2)) '.png'],'-dpng')

figure(106); clf
alfa=nanrunfit2(nanmean(save_alpha_raman(50:nntop,:),2),alt(50:nntop),5,100);
beta=nanmean(save_beta_raman(50:nntop,:),2);
LR=alfa./beta;
LR(beta<0.15e-6)=nan;
plot(LR,alt(50:nntop)*1e-3);
title([datestr(heads(1).jdi) ' to ' datestr(heads(end).jdf)])
xlim([0 120])
xlabel('Lidar Ratio (sr)')
ylabel('Altitude (km)'); ylim([0 6])
prettify(gca); grid
drawnow
print(['T2_LR_' num2str(tmp(3)) '_' num2str(tmp(2)) '.png'],'-dpng')

  save(['tiwa' datestr(times(1)) '.mat'],...
       'save_times',...
       'save_beta_klett',...
       'save_alpha_klett',...
       'save_beta_raman',...
       'save_alpha_raman',...
       'save_ldr_raman')
       %'save_beta_klett_over',...
       %'save_alpha_klett_over',...
       %'save_beta_raman_over',...
       %'save_alpha_raman_over',...
       %'save_ldr_raman_over',...
       %'save_overlap')

  clear glue355 glue387 save_times_save_beta_klett save_alpha_klett
  

  jdi=jdi+1;
end

%