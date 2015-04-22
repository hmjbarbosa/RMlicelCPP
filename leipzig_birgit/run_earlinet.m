clear all
close all

debug=50;

% earlinet synthetic data folder
datadir='/Users/hbarbosa/SkyDrive/synthetic_signals/';
file=[datadir 'Solutions/txt/aerowv1.000.txt'];
solution=importdata(file, ' ', 1);
res_pres=solution.data(:,3);  % P in hPa!
res_alti=solution.data(:,2); % in m 
res_alfa=solution.data(:,5); % in m-1
res_lrt=solution.data(:,6); % in ??
res_beta=1e3*res_alfa./res_lrt; % in km-1 ??

% read P,T profile
snd=read_sonde_synthetic([datadir 'Temperature_and_Pressure/txt/PTsim.txt.txt'],2);

% molecular 
lambda=[355e-9];
cte=constants;
mol=molecular(lambda,snd,cte,debug);

% read lidar data
read_ascii_synthetic
nch=1;

% calculate molecular fit
lidar_altitude=0;
bottomlayer=8e3;
toplayer=12e3;
rayleigh_fit_synth2

% Klett
fix_lr_aer=55;
Klett_Manaus
set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8]);
prettify(gca); grid on; xlim([-0.5 12])
print('earlinet_Klett_Mol.png','-dpng');
hold on
plot(res_beta*1e3, res_alti*1e-3,'k','LineWidth',2);
print('earlinet_Klett_Solut.png','-dpng');
xlim([-0.5 5])
print('earlinet_Klett_Solut55.png','-dpng');

figure(11)
temp=get(gcf,'position'); temp(3)=260; temp(4)=650;
set(gcf,'position',temp); % units in pixels!
set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8]);
plot(res_lrt, res_alti*1e-3,'r','LineWidth',2);
grid on;ylim([0 9]); 
xlabel('Lidar Ratio / sr','fontsize',[14])  
ylabel('Height / km','fontsize',[14])
title(['LR'],'fontsize',[14]) 
prettify(gca); grid on;
print('earlinet_LidarRatio.png','-dpng');

% run for different lidar ratios, and make a different plot
beta_mol55=beta_mol;
beta_klett55=beta_klett;
beta_klett_total5=beta_klett_total;

fix_lr_aer=40;
Klett_Manaus
hold on
plot(res_beta*1e3, res_alti*1e-3,'k','LineWidth',2);
set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8]);
prettify(gca); grid on;
print('earlinet_Klett_Solut40.png','-dpng');
beta_mol40=beta_mol;
beta_klett40=beta_klett;
beta_klett_total40=beta_klett_total;

fix_lr_aer=70;
Klett_Manaus
hold on
plot(res_beta*1e3, res_alti*1e-3,'k','LineWidth',2);
set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8]);
prettify(gca); grid on;
print('earlinet_Klett_Solut70.png','-dpng');
beta_mol70=beta_mol;
beta_klett70=beta_klett;
beta_klett_total70=beta_klett_total;

figure(20); hold on
temp=get(gcf,'position'); temp(3)=260; temp(4)=650;
set(gcf,'position',temp); % units in pixels!
set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8]);
plot(beta_klett40(1:maxbin)*40e6, alt(1:maxbin)*1e-3,'r','LineWidth',2);
plot(beta_klett55(1:maxbin)*55e6, alt(1:maxbin)*1e-3,'g','LineWidth',2);
plot(beta_klett70(1:maxbin)*70e6, alt(1:maxbin)*1e-3,'b','LineWidth',2);
plot(res_alfa*1e6, res_alti*1e-3,'k','LineWidth',2);
grid on;ylim([0 9]); xlim([-30 250]);
xlabel('Extinction / Mm-1','fontsize',[14])  
ylabel('Height / km','fontsize',[14])
title(['alfa'],'fontsize',[14]) 
prettify(gca); grid on;
print('earlinet_alfa.png','-dpng');

figure(21); hold on
temp=get(gcf,'position'); temp(3)=260; temp(4)=650;
set(gcf,'position',temp); % units in pixels!
set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8]);
plot(beta_klett40(1:maxbin)*1e6, alt(1:maxbin)*1e-3,'r','LineWidth',2);
plot(beta_klett55(1:maxbin)*1e6, alt(1:maxbin)*1e-3,'g','LineWidth',2);
plot(beta_klett70(1:maxbin)*1e6, alt(1:maxbin)*1e-3,'b','LineWidth',2);
plot(res_beta*1e3, res_alti*1e-3,'k','LineWidth',2);
grid on;ylim([0 9]); xlim([-0.5 5]);
xlabel('BSC / Mm-1 sr-1','fontsize',[14])  
ylabel('Height / km','fontsize',[14])
title(['beta'],'fontsize',[14]) 
prettify(gca); grid on;
print('earlinet_beta.png','-dpng')




% return