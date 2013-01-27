% klett_Manaus.m
%
% -----------------------------------------------
% derived from Klett.m          01/07 BHeese 
% Adaption to Manaus Lidar      06/12 BHeese
%
% -------------------------------------------
%  first run the following programs, please:   
%
%       read_ascii_Manaus.m
%       read_sonde_Manaus.m
%       rayleigh_fit_Manaus.m
% ------------------------------------------------
%
clear beta_par alpha_par
clear rc_signal
clear ext_par
clear fkt1
clear fkt2
clear zfkt
clear nfunk
clear extinktion
clear beta_aero beta_bv
clear beta_aerosol beta_aerosol_sm
clear alpha_aerosol alpha_aerosol_sm
clear alpha_aero
% 
zet_0 = 2;   % bin
sm_span = 11;  % Range for Savitzky-Golay smoothing  * r_bin
%hmjb ja definido em read_sonde_Manaus maxbin = 3000; 
%
% ***************************************************
%  set reference values for alpha und beta Particle 
% ***************************************************
beta_par(1,RefBin(1)) = 1e-6; % km-1
%
LR_par(1,1:maxbin) = 55;
LR_par(2,1:maxbin) = 55;

alpha_par(1,RefBin(1)) = beta_par(1,RefBin(1))*LR_par(1,RefBin(1)); 
%   
for j=1:1
  % ----------------------------                
  %  use range corrected signal
  % ----------------------------
  rc_signal(j,:) = pr2(:,j);
  %  
  %  Ref_Bin = min(RefBin); 
  Ref_Bin = RefBin(j); 
  %
  % ***********************************
  %  Backscatter coefficient: beta_par
  % ***********************************
  %   
  beta_par(j,Ref_Bin-1) = beta_par(j,Ref_Bin); 
  beta_bv(j) = beta_par(j,Ref_Bin)+ beta_mol(Ref_Bin,j);

  % -------------------------------------------------------------------------
  %  Klett (Equ. 20; 1985):
  %  fkt1: 2/B_R int(beta_R) = 2 int (alpha_R) = sum (alpha_1,R+alpha_2,R)*r_bin
  %  fkt2: 2 int(beta_R/B_P) = 2 int(alpha_R*B_R/B_P) =  2 int (alpha_R*S_P/S_R)
  % -------------------------------------------------------------------------
  %  Fernald, AO, 1984
  %
  ext_ave =(alpha_mol(Ref_Bin,j) + alpha_mol(Ref_Bin-1,j)) * r_bin;
  fkt1(Ref_Bin) = ext_ave; 
  fkt2(Ref_Bin) = ext_ave/LR_mol(j) * LR_par(j,Ref_Bin); 
  % 
  %  +++++++++++++++++++++++
  %   backward integration
  %  +++++++++++++++++++++++
  for i=Ref_Bin-1 : -1 : zet_0
    ext_ave = (alpha_mol(i,j) + alpha_mol(i-1,j)) * r_bin; 
    fkt1(i) = fkt1(i+1) + ext_ave; 
    fkt2(i) = fkt2(i+1) + ext_ave/LR_mol(j) * LR_par(j,i); 
  end

  % 
  % -----------------------------------------------------------------------
  %  zfkt: exp(S'-Sm') after Klett (Equ. 22)(Paper 1985) = S-Sm+fkt1-fkt2 
  % -----------------------------------------------------------------------
  for i=zet_0:Ref_Bin
    zfkt(i)=rc_signal(j,i)/rc_signal(j,Ref_Bin)/exp(fkt1(i))*exp(fkt2(i));
  end
  %
  % Integral in denominator (2. summand); 2 cancels with 1/2 mean value 
  
%hmjb nfkt(Ref_Bin)=zfkt(Ref_Bin)*r_bin/LR_par(j,Ref_Bin); 
  nfkt(Ref_Bin)=(zfkt(Ref_Bin)+zfkt(Ref_Bin-1))*r_bin/LR_par(j,Ref_Bin); 
  for i=Ref_Bin-1: -1 : zet_0
    nfkt(i)=nfkt(i+1)+(zfkt(i)+zfkt(i+1))*r_bin*LR_par(j,i); 
  end
  % 
  % Klett 1985, Equ. (22)
  %
  for i=Ref_Bin-1 : -1 : zet_0+1
    beta_aero(j,i) = zfkt(i)/(1./beta_bv(j) + nfkt(i)); 
  end
  %  
  %  +++++++++++++++++++++++
  %    forward integration
  %  +++++++++++++++++++++++
  for i=Ref_Bin : maxbin-1
    ext_ave = (alpha_mol(i,j) + alpha_mol(i+1,j)) * r_bin; 
    fkt1(i) = fkt1(i-1) + ext_ave; 
    fkt2(i) = fkt2(i-1) + ext_ave/LR_mol(j) * LR_par(j,i); 
  end
  % 
  % -----------------------------------------------------------------------
  %  zfkt: exp(S'-Sm') after Klett (Equ. 22)(Paper 1985) = S-Sm+fkt1-fkt2 
  % -----------------------------------------------------------------------
  for i=Ref_Bin : maxbin-1
    zfkt(i)=rc_signal(j,i)/rc_signal(j,Ref_Bin)/exp(fkt1(i))*exp(fkt2(i));
  end
  %
  % Integral in denominator (2. summand); 2 cancels with 1/2 mean value 
  
%hmjb nfkt(Ref_Bin)=zfkt(Ref_Bin)*r_bin/LR_par(j,Ref_Bin); 
  nfkt(Ref_Bin)=(zfkt(Ref_Bin)+zfkt(Ref_Bin-1))*r_bin/LR_par(j,Ref_Bin); 
  for i=Ref_Bin : maxbin-1
    nfkt(i)=nfkt(i-1)+(zfkt(i)+zfkt(i-1))*r_bin*LR_par(j,i); 
  end
  % 
  % Klett 1985, Equ. (22)
  %
  for i=Ref_Bin : maxbin-1
    beta_aero(j,i) = zfkt(i)/(1./beta_bv(j) + nfkt(i)); 
  end
  % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  % ---------------------
  % Backscatter profile
  % ---------------------
  %for i=1:Ref_Bin-1
  for i=1:maxbin-1
    if i <= zet_0
      beta_aerosol(j,i) = NaN; 
      alpha_aerosol(j,i) = NaN; 
    else      
      % substract beta_mol to achieve beta_aerosol
      beta_aerosol(j,i) = beta_aero(j,i) - beta_mol(i,j); 
      alpha_aerosol(j,i) = beta_aerosol(j,i) * LR_par(j,i); % careful! 
    end
  end   
%*****************************
end %  number of wavelength
%*****************************
%-------------
%  smoothing 
%-------------
for j=1:1
  beta_aerosol_sm(j,:) = smooth(beta_aerosol(j,:),sm_span,'sgolay',3);
  alpha_aerosol_sm(j,:) = smooth(alpha_aerosol(j,:),sm_span,'sgolay',3);
end 
%----------
%  Plots
%----------
rb = Ref_Bin; 
%
%----------
%   355
%----------
figure(8)
xx=xx0+5*wdx; yy=yy0+5*wdy;
set(gcf,'position',[xx,yy,2*wsx,wsy]); % units in pixels!
plot(beta_aero(1,1:maxbin-1), alt(1:maxbin-1).*1e-3,'r','Linewidth',1); 
axis([-1e-3 9e-3 0 alt(maxbin)*1e-3]); 
xlabel('BSC / km-1 sr-1','fontsize',[14])  
ylabel('Height / km','fontsize',[14])
title(['Klett'],'fontsize',[14]) 
grid on
hold on
plot(beta_mol (1:maxbin-1,1), alt(1:maxbin-1).*1e-3,'g','Linewidth',1); 
plot(beta_aerosol_sm(1,1:maxbin-1), alt(1:maxbin-1).*1e-3,'b','Linewidth',1); 
plot(beta_aerosol(1,RefBin(1)), alt(RefBin(1)).*1e-3,'r*');
legend('Total', 'Molecular', 'Klett', 'Reference Bin'); 
hold off
%  end of program
disp('End of program: Klett_Manaus.m, Vers. 1.0 06/12')
%