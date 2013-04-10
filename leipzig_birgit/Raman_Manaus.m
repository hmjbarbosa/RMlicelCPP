% Raman_Manaus.m
% 
%  This program calculates the aerosol extinction coefficient 
%  from Raman lidar measurements 
% --------------------------------------------------------
%  04/06  Version 1.0 for POLIS (Munich)	
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
clear bin1st aang lambda_aang
clear log_raman
clear fval angfit linfit relerr smed
clear aero_ext_raman
clear aero_ext_raman_sm
clear signal
clear lambda_aang
%
%%------------------------------------------------------------------------
%% USER SETTING
%%------------------------------------------------------------------------

% Starting point in rangebins
bin1st = 1; 

% Angstrom coefficient 
aang = 1.05;    % European Urban
% aang = 0.2;   % Saharan Desert Dust   

% Scalling between Elastic and Raman, i.e., 
% aer_ext(elastic) = aer_ext(raman) * (elastic/raman) ^ angstron
%                  = aer_ext(raman) * lambda_aang
lambda_aang = (355/387)^aang;  

%%------------------------------------------------------------------------
%% Solve Ansman Equation
%%------------------------------------------------------------------------

% Calculate term to be derived
for i = bin1st:maxbin  
  log_raman(2,i) = log(alpha_mol(i,2)/Pr2(i,2)'); % 387 nm
end 
% avoid division by zero
log_raman(~isfinite(log_raman))=NaN;
% lower raman RefBin if necessary
%RefBin(2) = min(RefBin(2),min(find(isnan(log_raman(:,2)))));

% Compute the derivative as a simple linear fit centered in each
% point. The number of points used is 2*SPAN+1 but it varies linearly 
% between the specified limits. 
%
%   yi = a*xi + b == Y(xi) + epsi
%   [Y, a, b, sum(epsi)] = runfit2(Y, X, Span x(1), Span at x(max))
%
[fval,angfit,linfit,relerr,smed]=runfit2(...
    log_raman(2,bin1st:maxbin)', alt(bin1st:maxbin).*1e-3, 2, 200);

aero_ext_raman = NaN(maxbin,1);
for i=bin1st:RefBin(2)
  aero_ext_raman(i) = (angfit(i)-alpha_mol(i,1)-alpha_mol(i,2))./(1+lambda_aang);
end

%%------------------------------------------------------------------------
%% Smoothing and Cleaning
%%------------------------------------------------------------------------
SPAN=11;
NPOLY=3;
aero_ext_raman_sm = smooth(aero_ext_raman, SPAN, 'sgolay', NPOLY);
%aero_ext_raman_sm = mysmooth(aero_ext_raman, 5, 50);

% -------------
%   plot data
% -------------
figure(9);
xx=xx0+4*wdx; yy=yy0+4*wdy;
% Klett
plot(alpha_aerosol(1,bin1st:maxbin-1),alt(bin1st:maxbin-1)*1e-3,'b--')
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
axis([-0.05 0.2 0 alt(maxbin-1)*1e-3*1.1]); 
xlabel('Extinction / km^-1','fontsize',[12])  
ylabel('Height / km','fontsize',[12])
title(['Raman'],'fontsize',[14]) 
grid on
hold on 
% Raman 
%plot(aero_ext_raman(bin1st:RefBin(2)),alt(bin1st:RefBin(2))*1e-3,'b','LineWidth',2);
plot(aero_ext_raman_sm(bin1st:RefBin(2)),alt(bin1st:RefBin(2))*1e-3,'r');
plot(alpha_aerosol(RefBin(1)), alt(RefBin(1))*1e-3,'r*');
plot(alpha_aerosol(RefBin(2)), alt(RefBin(2))*1e-3,'g*');
legend('Klett', 'Raman', 'RefBin 355', 'RefBin 387')
hold off
%
%  end of program
%  
disp('End of program: Raman_Manaus.m, Vers. 1.0 06/2012')
%
