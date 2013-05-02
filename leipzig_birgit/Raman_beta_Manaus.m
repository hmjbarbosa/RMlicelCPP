% raman_beta_Manaus.m
% --------------------------------------------------------
% calculates the backscatter coefficient following Ansmann (1992):
%
% beta_aero_355(z) = 
%            - beta_ray_355(z)+(beta_par(z0)+ beta_mol(z0)) ...
%           .*(P_387(z0).*P_355(z).*NR(z)/P_355(z0).*P_387(z0).*NR(z0) ...
%           .* exp(-int_z0_z(aero_ext_387 + alpha_mol_387)/      
%              exp(-int_z0_z(aero_ext_355 + alpha_mol_355)
%
% z0 is aerosolfree layer -> beta_mol(z0) >> beta_par(z0) 
%                         -> beta_mol(z0) + beta_par(z0) ... 
%                         =~ beta_mol(z0)
%
% --------------------------------------------------------
%  04/06  Version 1.0 for POLIS (Munich); 	BHeese
%  10/06  after successful Raman algorithm comparison (EARLINET Gelsomina Paparlardo 2005)  
%  08/07  adaption to PollyXT (Leipzig)
%  03/10  adaption to Chinese Raman Lidar (Hefei)
%  06/12  adaption to Manaus Raman Lidar
% -------------------------------------------------------
%  first run the following programs, please:   
%
%         	read_ascii_Manaus.m
%   		read_sonde_Manaus.m
% 		    rayleigh_fit_Manaus.m
%        	Klett_Manaus.m
%           Raman_Manaus.m
% ---------------------------------------------------------
%
bin1st = 2; %no overlap dependence because of signal ratios -> start at the bottom
%
clear p_ave_raman_1 p_ave_elast_1 p_ave_raman_2 p_ave_elast_2
clear m_ave_elast_1 m_ave_raman_1 m_ave_elast_2 m_ave_raman_2
clear exp_z_1 exp_n_1 exp_z_2 exp_n_2
clear xx yy 
clear beta_raman 
clear Lidar_Ratio
%
% define upper boundary from Raman Ext coeff
up = RefBin(2);
%up=1400;
%------------------------------------
% reference value for beta particle
%------------------------------------
Ref_1=up;
beta_par(1,Ref_1)= 1e-12;  % in km
%beta_par(1,Ref_1)= 9.1e-5;  % in km
%beta_par(1,Ref_1)= 8e-3; % in case of cirrus
%
%figure(123)
%clf
%hold on
%for up=RefBin(2):-1:RefBin(2)-100
  
p_ave_raman_1(up)=0;
m_ave_raman_1(up)=0;
p_ave_elast_1(up)=0;
m_ave_elast_1(up)=0;
for i=up - 1 : -1 : bin1st
  % Raman Particle extinction at 387
  p_ave_raman_1(i) = p_ave_raman_1(i+1) + 0.5*(aero_ext_raman(i) + aero_ext_raman(i+1))*lambda_aang; 
  % Raman molecular extinction at 387
  m_ave_raman_1(i) = m_ave_raman_1(i+1) + 0.5*(alpha_mol(i,2)+alpha_mol(i+1,2));    
  % Elastic particle  extinction at 355
  p_ave_elast_1(i) = p_ave_elast_1(i+1) + 0.5*(aero_ext_raman(i) + aero_ext_raman(i+1)); 
  % Elastic molecular extinction at 355
  m_ave_elast_1(i) = m_ave_elast_1(i+1) + 0.5*(alpha_mol(i,1)+alpha_mol(i+1,1));
end
for i=up : -1 : bin1st
  exp_z_1(i) = exp(+(p_ave_raman_1(i) + m_ave_raman_1(i))*r_bin); 
  exp_n_1(i) = exp(+(p_ave_elast_1(i) + m_ave_elast_1(i))*r_bin);
end

%plot(exp_z_1(200:up)./exp_n_1(200:up),alt(200:up))
%pause
%end
%return

% -------------------------
% calculate beta Raman
% -------------------------
for i=up : -1 : bin1st
% use the fitted molecular signal instead of real signal to avoid
% random fluctuations 
  signals_1(i) =(P_mol(Ref_1,2)*P(i,1)'*beta_mol(i,1))/...
                (P_mol(Ref_1,1)*P(i,2)'*beta_mol(Ref_1,1));  
%  signals_1(i) =(mean(P(Ref_1-100:Ref_1+100,2))*P(i,1)'*beta_mol(i,1))/...
%                (mean(P(Ref_1-100:Ref_1+100,1))*P(i,2)'*beta_mol(Ref_1,1));  
%  signals_1(i) =(P(Ref_1,2)'*P(i,1)'*beta_mol(i,1))/...
%                (P(Ref_1,1)'*P(i,2)'*beta_mol(Ref_1,1));

  %hmjb testando como definir beta_par em Ref_1
  
  
  beta_raman(i)= -beta_mol(i,1)+(beta_par(1,Ref_1)+ ...
                                 beta_mol(Ref_1,1))*signals_1(i)*exp_z_1(i)/exp_n_1(i);
end

%plot(beta_raman(50:up),alt(50:up))
%pause
%end
%return

%  
% --------------------------------------
%  smoothing 7.5 m * smothing length sl
% --------------------------------------
%sl = 11; 
%beta_raman_sm = smooth(beta_raman,sl,'sgolay',3);
%aero_ext_raman_sm = smooth(aero_ext_raman,sl,'sgolay',3);
% 
% -------------
%  Lidar Ratio 
% -------------
Lidar_Ratio(bin1st:up) = aero_ext_raman(bin1st:up)./beta_raman(bin1st:up)';  
%Lidar_Ratio_sm(bin1st:up) = aero_ext_raman_sm(bin1st:up)./beta_raman_sm(bin1st:up);  
%    
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%   Plots
% ------------------------
% Backscatter coeffcient
% ------------------------
%rbbb = size(beta_aerosol);
rbbr = size(beta_raman(:));
%maxbin=RefBin(1);
%
figure(10); clf;
xx=xx0+3*wdx; yy=yy0+3*wdy;
% Klett
%plot(beta_aerosol_sm(1,bin1st:tope-1), alt(bin1st:tope-1).*1e-3,'b--');
plot(beta_aerosol(1,bin1st:tope-1), alt(bin1st:tope-1).*1e-3,'b--');
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
axis([-3e-3 4e-3 0 alt(tope-1)*1e-3*1.1]);
xlabel('BSC km-1 sr-1','fontsize',[12])  
ylabel('Height agl / km','fontsize',[12])
title(['Raman'],'fontsize',[14]) 
grid on
hold on
% Raman
%plot(beta_raman_sm(bin1st:rbbr(1)), alt(bin1st:rbbr(1)).*1e-3,'b','LineWidth',2)
plot(beta_raman(bin1st:rbbr(1)), alt(bin1st:rbbr(1)).*1e-3,'b','LineWidth',2)
%plot(beta_aerosol_sm(RefBin(1)), alt(RefBin(1))*1e-3,'r*');
%plot(beta_aerosol_sm(RefBin(2)), alt(RefBin(2))*1e-3,'g*');
%legend('Klett', 'Raman', 'RefBin 355', 'RefBin 387')
legend('Klett', 'Raman')
hold off
%  
% -------------- 
%  Lidar Ratio
% --------------
rLR_1 = size(Lidar_Ratio(1,:));
%  
figure(11); clf;
xx=xx0+2*wdx; yy=yy0+2*wdy;
%plot(Lidar_Ratio_sm(bin1st:rLR_1(2)),alt(bin1st:rLR_1(2)).*1e-3,'b')
plot(Lidar_Ratio(bin1st:rLR_1(2)),alt(bin1st:rLR_1(2)).*1e-3,'b')
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
axis([0 100 0 alt(tope-1)*1e-3*1.1]); 
xlabel('Lidar Ratio / sr','fontsize',[12])  
ylabel('Height agl / km','fontsize',[12])
title(['Raman'],'fontsize',[14])
grid on
hold off
%  
disp('End of program: Raman_beta_Manaus.m, Vers. 1.0 06/12')
