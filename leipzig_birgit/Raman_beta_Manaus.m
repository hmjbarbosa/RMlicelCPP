% raman_beta_Manaus.m
% --------------------------------------------------------
% calculates the backscatter coefficient following Ansmann (1992):
%
% beta_aero_355(z) = 
%            - beta_ray_355(z)+(beta_par(z0)+ beta_mol(z0)) ...
%           .*(P_387(z0).*P_355(z).*NR(z)/P_355(z0).*P_387(z0).*NR(z0) ...
%           .* exp(-int_z0_z(aero_ext_387 + ray_ext_387)/      
%              exp(-int_z0_z(aero_ext_355 + ray_ext_355)
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
zet_0 = 1; %no overlap dependence because of signal ratios -> start at the bottom
%
clear p_ave_raman_1 p_ave_elast_1 p_ave_raman_2 p_ave_elast_2
clear m_ave_elast_1 m_ave_raman_1 m_ave_elast_2 m_ave_raman_2
clear exp_z_1 exp_n_1 exp_z_2 exp_n_2
clear xx yy 
clear beta_raman beta_raman_sm
clear Lidar_Ratio
%
% define upper boundary from Raman Ext coeff
upp = size(aero_ext_raman); 
up = upp(1)
%
Ref_1 = RefBin(2) 
%
% when cirrus clouds are present set the alttude bin
% cir=1000
% Ref_1 = cir
%
%------------------------------------
% reference value for beta particle
%------------------------------------
beta_par(1,Ref_1)= 1e-12;  % in km
%--------------------
% in case of cirrus
%--------------------
% beta_par(1,cir)= 8e-3;
%
exp_z_1(up)=1;
exp_n_1(up)=1;
%
% *********
%  355 nm 
% *********
% for i=Ref_1 : -1 : zet_0 + 1
   for i=up : -1 : zet_0 + 1
% Raman Particle extinction at 387
   p_ave_raman_1(i) = 0.5*(aero_ext_raman(i) + aero_ext_raman(i-1))*aerosol_wave_fac(1); 
% Raman molecular extinction at 387
   m_ave_raman_1(i) = 0.5*(ray_ext(2,i)+ray_ext(2,i-1));    
% Elastic particle  extinction at 355
   p_ave_elast_1(i) = 0.5*(aero_ext_raman(i) + aero_ext_raman(i-1)); 
% Elastic molecular extinction at 355
   m_ave_elast_1(i) = 0.5*(ray_ext(1,i)+ray_ext(1,i-1));
%       
   exp_z_1(i-1) = exp_z_1(i)* exp(-(p_ave_raman_1(i) + m_ave_raman_1(i))*deltar); 
   exp_n_1(i-1) = exp_n_1(i)* exp(-(p_ave_elast_1(i) + m_ave_elast_1(i))*deltar);
  end
% -------------------------
% calculate beta Raman
% -------------------------
   for i=up : -1 : zet_0   
 signals_1(i) =(mean_bg_corr(Ref_1,2)'*mean_bg_corr(i,1)'*beta_mol(1,i))/...
    (mean_bg_corr(Ref_1,1)'*mean_bg_corr(i,2)'*beta_mol(1,Ref_1));  
 beta_raman(i)= -beta_mol(1,i)+(beta_par(1,Ref_1)+ beta_mol(1,Ref_1))*signals_1(i)*exp_z_1(i)/exp_n_1(i);
   end
%  
% --------------------------------------
%  smoothing 7.5 m * smothing length sl
% --------------------------------------
 sl = 11; 
 beta_raman_sm = smooth(beta_raman,sl,'sgolay',3);
% 
% -------------
%  Lidar Ratio 
% -------------
Lidar_Ratio(zet_0:up) = aero_ext_raman(zet_0:up)./beta_raman(zet_0:up)';  
Lidar_Ratio_sm(zet_0:up) = aero_ext_raman(zet_0:up)./beta_raman_sm(zet_0:up);  
%    
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%   Plots
% ------------------------
% Backscatter coeffcient
% ------------------------
%rbbb = size(beta_aerosol);
rbbr = size(beta_raman_sm(:));
%
figure(15)
  %  set(gcf,'position',[50,100,600,800]); % units in pixels! *** 19 " ***
   set(gcf,'position',[50,100,500,600]); % units in pixels! *** Laptop ***
  title(['Embrapa Raman Lidar on ' datum ', '  ' UTC '],'fontsize',[10]) 
  xlabel('BSC km-1 sr-1','fontsize',[12])  
  ylabel('Height agl / km','fontsize',[12])
% axis([-1e-3 5e-3 0 alt(Ref_1)]); 
 axis([-0.2e-3 10e-3 0 alt(up).*1e-3]); 
  box on
  hold on
  plot(beta_aerosol_sm(1,zet_0:rbbr(1)), alt(zet_0:rbbr(1)).*1e-3,'b--'); %Klett
%  plot(beta_mol(1,zet_0:rbbr(1)), alt(zet_0:rbbr(1)).*1e-3,'r'); 
%
  plot(beta_raman_sm(zet_0:rbbr(1)), alt(zet_0:rbbr(1)).*1e-3,'b','LineWidth',2)
  betaref_1 =  num2str(beta_par(1,Ref_1), '%5.1e'); 
  refheight = [num2str(alt(Ref_1)*1e-3,'%5.1f') ' km'];
  text(0.4*5e-3, 0.74*alt(Ref_1), ['Beta-Ref. 355 =' betaref_1 ' at ' refheight],'fontsize',10,'HorizontalAlignment','left','Rotation',[0])
  grid on

 legend('355 Klett')
%  
% -------------- 
%  Lidar Ratio
% --------------
  rLR_1 = size(Lidar_Ratio(1,:));
%  
  figure(16)
  %  set(gcf,'position',[50,100,600,800]); % units in pixels! *** 19 " ***
   set(gcf,'position',[50,100,500,600]); % units in pixels! *** Laptop ***
  
  title(['Embrapa Raman Lidar on ' datum ', '  ' UTC '],'fontsize',[10]) 
  xlabel('Lidar Ratio / sr','fontsize',[12])  
  ylabel('Height agl / km','fontsize',[12])
%  axis([0 100 0 alt(Ref_1)]); 
  axis([0 100 0 alt(up).*1e-3]); 
box on
  hold on
  plot(Lidar_Ratio_sm(zet_0:rLR_1(2)),alt(zet_0:rLR_1(2)).*1e-3,'b')
  grid on
  legend('355 nm')
%  
  disp('End of program: Raman_beta_Manaus.m, Vers. 1.0 06/12')
