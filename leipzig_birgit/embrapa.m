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
%radiodir=['/work/hbarbosa/Dropbox/00_ANALYSIS/sondagens/' stationid '/dat'];

datain='/Users/hbarbosa/DATA/lidar/data';
%datain='/LFANAS/ftproot/public/lidar/data';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read physics constants
cte=constants(400., debug);

lambda=[0.355 0.387]*1e-6; % [m]

% date periods
%start_jd=datenum('29-Aug-2014 13:00:00');
%end_jd=datenum('1-Sep-2014 13:00:00');

start_jd=datenum('6-Sep-2014 13:00:00');
end_jd=datenum('7-Sep-2014 13:00:00');

%start_jd=datenum('5-Mar-2016 0:00:00');
%end_jd=datenum('6-Mar-2016 0:00:00');

% read once just to keep everything in memory
[radiofile allradio alljd]=search_sonde(radiodir,'82332',start_jd);

% info...
fix_lr_aer=60.;
lidar_altitude=100.;
fix_angstrom=1.2;
dbin=9;
dtime=0.004;

% overlap correction
%load /Users/hbarbosa/Dropbox/08_EQUIPAMENTOS/faraday/overlap_wide.mat
load overlap_embrapa.mat

% loop over all dates
jdi=start_jd;
while jdi<end_jd 
  jdf=min(jdi+1439/1440,end_jd);

  % read data between jdi and jdf (1-day appart)
  %debug=5
  read_manaus
%count(1:367)=0;
%count(444:471)=0;
%count(485:488)=0;
%count(496:514)=0;
%count(519:546)=0;
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
      %P(1:2000,1)=P(1:2000,1)./meanover(1:2000);
      %P(1:2000,2)=P(1:2000,2)./meanover(1:2000);
      
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

        % try to calculate the overlap
        % n=650 => 4.875km
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
%if tmp(3)==1
%  save_beta_raman (:,1:38)=nan;
%  save_alpha_raman(:,1:38)=nan;
%end
%if tmp(3)==2
%  save_beta_raman (:,38)=nan;
%  save_alpha_raman(:,38)=nan;
%  save_beta_raman (:,58:end)=nan;
%  save_alpha_raman(:,58:end)=nan;
%end
%if tmp(3)==4
%  save_beta_raman (:,49:51)=nan;
%  save_alpha_raman(:,49:51)=nan;
%  save_beta_raman (:,59:end)=nan;
%  save_alpha_raman(:,59:end)=nan;
%end
%if tmp(3)==7
%  save_beta_raman (:,1:39)=nan;
%  save_alpha_raman(:,1:39)=nan;
%  save_beta_raman (:,48:end)=nan;
%  save_alpha_raman(:,48:end)=nan;
%end
%if tmp(3)==8
%  save_beta_raman (:,50:end)=nan;
%  save_alpha_raman(:,50:end)=nan;
%end
%if tmp(3)==10
%  save_beta_raman (:,1:42)=nan;
%  save_alpha_raman(:,1:42)=nan;
%  save_beta_raman (:,52)=nan;
%  save_alpha_raman(:,52)=nan;
%end

nntop=800;
figure(102); clf
[h bar]=gplot2(save_alpha_klett(100:nntop,:)*1e6,[0:0.5:40],times,alt(100:nntop)*1e-3);
ylabel(bar,'Extinction (Mm-1)')
title([datestr(heads(1).jdi) ' to ' datestr(heads(end).jdf)])
xlim([jdi jdi+1])
datetick('x',15,'keeplimits')
xlabel('Time (#)')
ylabel('Altitude (km)'); ylim([0 4])
prettify(gca,bar); grid
drawnow
print(['T0e_Alpha_Raman_' num2str(tmp(3)) '_' num2str(tmp(2)) '.png'],'-dpng')

figure(103); clf
plot(nanmean(save_alpha_klett(100:nntop,:),2)*1e6,alt(100:nntop)*1e-3,'r');
title([datestr(heads(1).jdi) ' to ' datestr(heads(end).jdf)])
xlim([-10 40])
xlabel('Extinction (Mm-1)')
ylabel('Altitude (km)'); ylim([0 4])
prettify(gca); grid
drawnow
print(['T0e_Alpha_RamanProf_' num2str(tmp(3)) '_' num2str(tmp(2)) '.png'],'-dpng')

figure(104); clf
[h bar]=gplot2(save_beta_klett(100:nntop,:)*1e6,[0:0.01:1],times,alt(100:nntop)*1e-3);
ylabel(bar,'Backscattering (Mm-1 sr-1)')
title([datestr(heads(1).jdi) ' to ' datestr(heads(end).jdf)])
xlim([jdi jdi+1])
datetick('x',15,'keeplimits')
xlabel('Time (#)')
ylabel('Altitude (km)'); ylim([0 4])
prettify(gca,bar); grid
drawnow
print(['T0e_Beta_Raman_' num2str(tmp(3)) '_' num2str(tmp(2)) '.png'],'-dpng')

figure(105); clf
plot(nanmean(save_beta_klett(100:nntop,:),2)*1e6,alt(100:nntop)*1e-3,'r');
title([datestr(heads(1).jdi) ' to ' datestr(heads(end).jdf)])
xlim([-0.3 1])
xlabel('Backscattering (Mm-1 sr-1)')
ylabel('Altitude (km)'); ylim([0 4])
prettify(gca); grid
drawnow
print(['T0e_Beta_RamanProf_' num2str(tmp(3)) '_' num2str(tmp(2)) '.png'],'-dpng')

figure(106); clf
alfa=nanrunfit2(nanmean(save_alpha_raman(100:nntop,:),2),alt(100:nntop),5,100);
beta=nanmean(save_beta_raman(100:nntop,:),2);
LR=alfa./beta;
LR(beta<0.15e-6)=nan;
plot(LR,alt(100:nntop)*1e-3,'r');
title([datestr(heads(1).jdi) ' to ' datestr(heads(end).jdf)])
xlim([0 120])
xlabel('Lidar Ratio (sr)')
ylabel('Altitude (km)'); ylim([0 6])
prettify(gca); grid
drawnow
print(['T0e_LR_' num2str(tmp(3)) '_' num2str(tmp(2)) '.png'],'-dpng')
  
  save(['embrapa' datestr(times(1)) '.mat'],...
       'save_times',...
       'save_beta_klett',...
       'save_alpha_klett',...
       'save_beta_ramplan',...
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