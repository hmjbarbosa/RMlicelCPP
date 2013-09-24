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
clear alpha_raman
%clear alpha_raman_sm
clear signal
clear lambda_aang tmp
%
%%------------------------------------------------------------------------
%% USER SETTING
%%------------------------------------------------------------------------

% Starting point in rangebins
bin1st = 1; 

% Angstrom coefficient 
%aang = 1;    % European Urban
% aang = 0.2;   % Saharan Desert Dust   
aang = 1.2;    % Manaus = clean Amazon = 1.2+-0.4 dry season 

% Scalling between Elastic and Raman, i.e., 
% aer_ext(elastic) = aer_ext(raman) * (elastic/raman) ^ angstron
%                  = aer_ext(raman) * lambda_aang
lambda_aang = (355/387)^aang;  

%%------------------------------------------------------------------------
%% Solve Ansman Equation
%%------------------------------------------------------------------------

% Calculate term to be derived
tmp=NaN(maxbin,1);
%inp=nanmysmooth(Pr2(:,2),0,20);
for i = 1:maxbin
  if (Pr2(i,2)==0)
%  if (inp(i)==0)
    tmp(i,1)=NaN;
  else
    tmp(i,1) = log(alpha_mol(i,2)./Pr2(i,2));
%    tmp(i,1) = log(alpha_mol(i,2)./inp(i));
  end
%  log_raman(2,i) = log(alpha_mol(i,2)./Pr2(i,2)'); % 387 nm
end 

% Compute the derivative as a simple linear fit centered in each
% point. The number of points used is 2*SPAN+1 but it varies linearly 
% between the specified limits. 
%
%   yi = a*xi + b == Y(xi) + epsi
%   [Y, a, b, sum(epsi)] = runfit2(Y, X, Span x(1), Span at x(max))
%
%[fval,angfit,linfit,relerr,smed]=runfit2(...
%    log_raman(2,bin1st:maxbin)', alt(bin1st:maxbin).*1e-3, 2, 200);
%tmp=mysmooth(tmp2,10,10);
%tmp=nanmysmooth(tmp,0,25);

%[fval,angfit2,linfit,relerr,smed]=nanrunfit2(...
%    tmp(bin1st:maxbin), alt(bin1st:maxbin).*1e-3, 5, 5);

% DERIVATIVE
clear angfit
%angfit(:,9)=angfit2;
%% 1st order backward
%for i=bin1st+1:maxbin
%%for i=maxbin:maxbin
%  angfit(i,1)=(tmp(i)-tmp(i-1))/(alt(i)-alt(i-1))*1e3;
%end
%% 1st order forward
%for i=bin1st:maxbin-1
%%for i=bin1st:bin1st
%  angfit(i,2)=(tmp(i+1)-tmp(i))/(alt(i+1)-alt(i))*1e3;
%end
%% 2nd order central
for i=bin1st+1:maxbin-1
  angfit(i,3)=(tmp(i+1)-tmp(i-1))/(alt(i+1)-alt(i-1))*1e3;
end
% 2nd order backward
%for i=bin1st+2:maxbin
for i=maxbin:maxbin
  angfit(i,3)=(tmp(i-2)-4*tmp(i-1)+3*tmp(i))/(alt(i)-alt(i-2))*1e3;
end
% 2nd order forward
%for i=bin1st:maxbin-2
for i=bin1st:bin1st
  angfit(i,3)=(-3*tmp(i)+4*tmp(i+1)-tmp(i+2))/(alt(i+2)-alt(i))*1e3;
end
%% 3rd order backward
%for i=bin1st+2:maxbin-1
%  angfit(i,6)=(tmp(i-2)-6*tmp(i-1)+3*tmp(i)+2*tmp(i+1))/(alt(i+1)-alt(i-2))*1e3/2;
%end
%% 3rd order forward
%for i=bin1st+1:maxbin-2
%  angfit(i,7)=(-2*tmp(i-1)-3*tmp(i)+6*tmp(i+1)-tmp(i+2))/(alt(i+2)-alt(i-1))*1e3/2;
%end
%% 4th order central
%for i=bin1st+2:maxbin-2
%  angfit(i,8)=(tmp(i-2)-8*tmp(i-1)+8*tmp(i+1)-tmp(i+2))/(alt(i+2)-alt(i-2))*1e3/3;
%end
%return
%angfit=nanmysmooth(angfit,0,25);

alpha_raman = NaN(maxbin,1);
alpha_raman2= NaN(maxbin,1);
for j=3:3
%for i=bin1st:RefBin(2)
for i=bin1st:maxbin
%  alpha_raman(i,j) = (angfit(i-bin1st+1,j)./tmp(i)-alpha_mol(i,1)-alpha_mol(i,2))./(1+lambda_aang);
  alpha_raman2(i,j) = (angfit(i,j)-alpha_mol(i,1)-alpha_mol(i,2))./(1+lambda_aang);
end
end
%figure(88); clf;
%n=50;
%plot(alpha_raman2(1:n,:),'o-')
%legend('1b','1f','2c','2b','2f','3b','3f','4c','tmp');
%hold on;
%plot(alpha_klett(1:n,1),'ko--')
%ylim([-1.35 1.50])

alpha_raman=alpha_raman2(:,3);

%alpha_raman=nanmysmooth(alpha_raman2(:,3),0,5);
alpha_raman=nanmysmooth(alpha_raman2(:,3),0,200);

% -------------
%   plot data
% -------------
if (debug==0)
  return
end

figure(9);
xx=xx0+4*wdx; yy=yy0+4*wdy;
% Klett
plot(alpha_klett(bin1st:maxbin,1)*1e3,alt(bin1st:maxbin)*1e-3,'b--')
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
axis([-15 400 0 alt(tope-1)*1e-3*1.1]); 
xlabel('Extinction / Mm^-1','fontsize',[12])  
ylabel('Height / km','fontsize',[12])
title(['Raman'],'fontsize',[14]) 
grid on
hold on 
% Raman 
plot(alpha_raman(bin1st:maxbin)*1e3,alt(bin1st:maxbin)*1e-3,'r');
%plot(alpha_raman_sm(bin1st:RefBin(2))*1e3,alt(bin1st:RefBin(2))*1e-3,'r');
plot(alpha_klett(RefBin(1),1)*1e3, alt(RefBin(1))*1e-3,'r*');
plot(alpha_klett(RefBin(2),1)*1e3, alt(RefBin(2))*1e-3,'g*');
legend('Klett', 'Raman', 'RefBin 355', 'RefBin 387')
hold off
%
%  end of program
%  
disp('End of program: Raman_Manaus.m, Vers. 1.0 06/2012')
%
