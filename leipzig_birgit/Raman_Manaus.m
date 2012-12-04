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
zet_0 = 2; 
%
% --------------------------------- 
%  Rayleigh wavelength dependence
% ---------------------------------
ray_fac(1) = (355/387)^4.085; 
%  ray_fac(2) = (532/607)^4.085; 
%  ray_fac(3) = (532/1064)^4.085; 
% 
% ------------------------
%  Angström coefficient 
% ------------------------
aang = 1.05;    % European Urban
% aang = 0.2;     % Saharan Desert Dust   
%
 aerosol_wave_fac(1) = (355/387)^aang;  
% aerosol_wave_fac(2) = (532/607)^aang;  
% aerosol_wave_fac(3) = (532/1064)^aang; 
% 
ray_ext(1,:) = alpha_mol(1,:);   % 355 
ray_ext(2,:) = ray_ext(1,:).*ray_fac(1); % 387
%
% --------------------
for i = zet_0:rbins  
  % --------------------
  %   logarithm
  % ---------------- 
  log_raman(2,i) = log(ray_ext(2,i)/pr2(i,2)'); % 387 nm
end 
% --------------
%    deviation
% --------------    % 5-10 am night-time, 10-20 daytime
fit_width = 5;  % 
                    % 1) deviation_chi2_increasing.m
                    % progressiv fit-width increasing with height: 
                    % am Anfang unten bis unten + fit_breite+1 ableiten 
                    % über ndata = (2*(i-unten)+1) = 3,5,7,9,11,...
                    % danach immer in 2*fit_breite Schritten 2 rbins mehr! 
                    % bei fit_breite = 5: in 1 km ~500 m, in 2 km ~700 m, 
                    % in 3km ~900 m, in 4 km ~ 1100m, in 5 km ~ 1300m 
                    % 
                    % 2) ableitung_chi2_doubling.m, (Poisson Statistics) 
                    % the fit-width doubles with height (5, 10 oder 20
                    % rbins) at the ranges "mitte 1", "mitte 2" und  "oben"
% -------
% * 387 *  
% -------
% 1) "devation length" increasing automatically
[abl_chi2_1,chi2,q,u] = deviation_chi2_increasing_Manaus(log_raman(2,:),alt.*1e-3,Ref_Bin,fit_width,datum);
% [abl_chi2_1,chi2,q,u] = deviation_chi2_increasing_Manaus(log_raman(2,:),alt,rbins/2-1,fit_width,datum);
 
% 2) doubling manually
% [abl_chi2_1,chi2,q,u] = deviation_chi2_increasing_doubling(log_raman(5,:),alt,rbins-1,fit_width,datum2);
%
abl_Raman = abl_chi2_1; 
rb1 = size(abl_Raman);
rb2=rb1(2); 
% 
% ---------------------
%   Raman extinction
% ---------------------
aero_ext_raman = NaN(2,rb1);
%
for i=u:rb2
  aero_ext_raman(i) = (abl_Raman(i)-ray_ext(1,i)-ray_ext(2,i))./(1+aerosol_wave_fac(1));
end
% -------------
%   plot data
% -------------
rbb_a = rb2; 
rbb_p = RefBin(1); 
rbb_ka = RefBin(2); 
%
figure(9) 
%  set(gcf,'position',[50,100,600,800]); % units in pixels! *** 19 " ***
set(gcf,'position',[50,100,500,600]); % units in pixels! *** Laptop ***
title(['Embrapa Raman Lidar on ' datum ', ' timex1(1,1:5) ' LT '],'fontsize',[14]) 
xlabel('Extinction / km^-1','fontsize',[12])  
ylabel('Height / km','fontsize',[12])
axis([-0.05 0.2 alt(zet_0) alt(rbb_p)]); 
box on 
hold on 
% Klett
plot(alpha_aerosol(1,zet_0:rb-1),alt(zet_0:rb-1),'b--')
%
% Raman 
plot(aero_ext_raman(zet_0+60:rbb_a),alt(zet_0+60:rbb_a),'b','LineWidth',2)
%
legend('Klett 355')%, 'Raman 355')
grid on
%
%  end of program
%  
disp('End of program: Raman_Manaus.m, Vers. 1.0 06/2012')
%
