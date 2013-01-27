% Raman_Manaus.m
% 
%  This program calculates the aerosol extinction coefficient 
%  from Raman lidar measurements 
% --------------------------------------------------------
%  04/06   Version 1.0 for POLIS (Munich)	
%  10/06  after successful Raman algorithm comparison (EARLINET Gelsomina Paparlardo 2005)  BHeese 
%  08/07  adaption to PollyXT (Leipzig)
%  03/10  adaption to Chinese Raman Lidar (Hefei)
%  06/2012 adaption to Embrapa Lidar near Manaus, Brazil    % BHeese
% ---------------------------------------------------------------------
%
%  first run the following programs, please:   
%
%         	read_ascii_Manaus.m
%   		read_sonde_Manaus.m
% 		    rayleigh_fit_Manaus.m
%        	Klett_Manaus.m
% --------------------------------------------------------
clear log_raman
clear abl_Raman
clear aero_ext_raman
clear aero_ext_raman_sm
clear signal
clear ray_ext
%
% starting point in rangebins
bin1st = 2; 
%
% ------------------------
%  Angström coefficient 
% ------------------------
aang = 1.05;    % European Urban
% aang = 0.2;   % Saharan Desert Dust   
%
aerosol_wave_fac(1) = (355/387)^aang;  
%
% --------------------
for i = bin1st:maxbin  
  % --------------------
  %   logarithm
  % ---------------- 
%  log_raman(2,i) = log(Nn2(i)/pr2(i,2)'); % 387 nm
  log_raman(2,i)  = log(alpha_mol(i,2)/pr2(i,2)'); % 387 nm
  log_ramanB(2,i) = log(alpha_mol(i,2)/pr2(i,2)'); % 387 nm
end 
% --------------
%    deviation
% --------------    % 5-10 am night-time, 10-20 daytime
fit_width = 5;  % 
                    % 1) deviation_chi2_increasing.m
                    % progressiv fit-width increasing with height: 
                    % am Anfang unten bis unten + fit_breite+1 ableiten 
                    % über ndata = (2*(i-unten)+1) = 3,5,7,9,11,...
                    % danach immer in 2*fit_breite Schritten 2 maxbin mehr! 
                    % bei fit_breite = 5: in 1 km ~500 m, in 2 km ~700 m, 
                    % in 3km ~900 m, in 4 km ~ 1100m, in 5 km ~ 1300m 
                    % 
                    % 2) ableitung_chi2_doubling.m, (Poisson Statistics) 
                    % the fit-width doubles with height (5, 10 oder 20
                    % maxbin) at the ranges "mitte 1", "mitte 2" und  "oben"
% -------
% * 387 *  
% -------
% 1) "devation length" increasing automatically
datum='teste';
[abl_chi2_1,chi2,q,u]=deviation_chi2_increasing_Manaus(log_raman(2,:),alt.*1e-3,Ref_Bin,fit_width,datum);

[fval,abl_chi2_1B,b,relerr,smed]=runfit2(log_ramanB(2,1:maxbin)', ...
					 alt(1:maxbin).*1e-3, 2, 200);

%
abl_Raman = abl_chi2_1; 
abl_RamanB = abl_chi2_1B; 

rb1 = size(abl_Raman,2);
% 
% ---------------------
%   Raman extinction
% ---------------------
aero_ext_raman = NaN(rb1,1);
%
for i=u:rb1
  aero_ext_raman(i)  = (abl_Raman(i)-alpha_mol(i,1)-alpha_mol(i,2))./(1+aerosol_wave_fac(1));
  aero_ext_ramanB(i) = (abl_RamanB(i)-alpha_mol(i,1)-alpha_mol(i,2))./(1+aerosol_wave_fac(1));
end

% -------------
%   plot data
% -------------
figure(9);
xx=xx0+4*wdx; yy=yy0+4*wdy;
% Klett
plot(alpha_aerosol(1,bin1st:rb-1),alt(bin1st:rb-1)*1e-3,'b--')
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
axis([-0.05 0.2 0 alt(rb1)*1e-3*1.2]); 
xlabel('Extinction / km^-1','fontsize',[12])  
ylabel('Height / km','fontsize',[12])
title(['Raman'],'fontsize',[14]) 
grid on
hold on 
% Raman 
plot(aero_ext_raman(bin1st:rb1),alt(bin1st:rb1)*1e-3,'b','LineWidth',2)
plot(aero_ext_ramanB(bin1st:rb1),alt(bin1st:rb1)*1e-3,'r','LineWidth',1)
plot(alpha_aerosol(RefBin(1)), alt(RefBin(1))*1e-3,'r*');
plot(alpha_aerosol(RefBin(2)), alt(RefBin(2))*1e-3,'g*');
legend('Klett', 'Raman', 'RamanB', 'RefBin 355', 'RefBin 387')
hold off
%
%  end of program
%  
disp('End of program: Raman_Manaus.m, Vers. 1.0 06/2012')
%
