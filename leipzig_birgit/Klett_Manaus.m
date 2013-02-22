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
%
% ***************************************************
%  set reference values for alpha und beta Particle 
% ***************************************************
%
LR_par(1,1:maxbin) = 55;
LR_par(2,1:maxbin) = 55;

j=1; n=0;   
for k=1:maxbin-1
  if (mask_mol(k,1)==0)
    trychi2(k)=nan;
    continue;
  else
    n=n+1;
    RefBin(1)=k;
    trybin(n)=k;
  end
%for k=1:1
%RefBin(1)=2200;
  
  % -------------------------------------------------------------------------
  %  Klett (Equ. 20; 1985):
  %  fkt1: 2/B_R int(beta_R) = 2 int (alpha_R) = sum (alpha_1,R+alpha_2,R)*r_bin
  %  fkt2: 2 int(beta_R/B_P) = 2 int(alpha_R*B_R/B_P) =  2 int (alpha_R*S_P/S_R)
  % -------------------------------------------------------------------------
  %  Fernald, AO, 1984
  %
  % 
  %  +++++++++++++++++++++++
  %   backward integration
  %  +++++++++++++++++++++++
  fkt1(RefBin(1)) = 0; 
  fkt2(RefBin(1)) = 0;
  for i=RefBin(1)-1 : -1 : zet_0
    ext_ave = (alpha_mol(i,j) + alpha_mol(i+1,j)) * r_bin; 
    fkt1(i) = fkt1(i+1) + ext_ave; 
    fkt2(i) = fkt2(i+1) + ext_ave/LR_mol(j) * LR_par(j,i); 
  end
  % 
  % -----------------------------------------------------------------------
  %  zfkt: exp(S'-Sm') after Klett (Equ. 22)(Paper 1985) = S-Sm+fkt1-fkt2 
  % -----------------------------------------------------------------------
  for i=zet_0:RefBin(1)
    zfkt(i)=Pr2(i,j)/Pr2_mol(RefBin(1),j)/exp(fkt1(i))*exp(fkt2(i));
%    zfkt(i)=Pr2(i,j)/mean(Pr2(RefBin(1)-40:RefBin(1)+40,j))/exp(fkt1(i))*exp(fkt2(i));
%    zfkt(i)=Pr2(i,j)/Pr2(RefBin(1),j)/exp(fkt1(i))*exp(fkt2(i));
  end
  %
  % Integral in denominator (2. summand); 2 cancels with 1/2 mean value 
  
  nfkt(RefBin(1))=0;
  for i=RefBin(1)-1: -1 : zet_0
    nfkt(i)=nfkt(i+1)+(zfkt(i)*LR_par(j,i)+zfkt(i+1)*LR_par(j,i+1))*r_bin; 
  end
  % 
  % Klett 1985, Equ. (22)
  %
  for i=RefBin(1)-1 : -1 : zet_0+1
    beta_aero(j,i) = zfkt(i)/(1./beta_mol(RefBin(1),j) + nfkt(i)); 
  end
  %  
  %  +++++++++++++++++++++++
  %    forward integration
  %  +++++++++++++++++++++++
  for i=RefBin(1)+1 : maxbin-1
    ext_ave = (alpha_mol(i,j) + alpha_mol(i-1,j)) * r_bin; 
    fkt1(i) = fkt1(i-1) + ext_ave; 
    fkt2(i) = fkt2(i-1) + ext_ave/LR_mol(j) * LR_par(j,i); 
  end
  % 
  % -----------------------------------------------------------------------
  %  zfkt: exp(S'-Sm') after Klett (Equ. 22)(Paper 1985) = S-Sm+fkt1-fkt2 
  % -----------------------------------------------------------------------
  for i=RefBin(1) : maxbin-1
    zfkt(i)=Pr2(i,j)/Pr2_mol(RefBin(1),j)/exp(fkt1(i))*exp(fkt2(i));
%    zfkt(i)=Pr2(i,j)/mean(Pr2(RefBin(1)-40:RefBin(1)+40,j))/exp(fkt1(i))*exp(fkt2(i));
%    zfkt(i)=Pr2(i,j)/Pr2(RefBin(1),j)/exp(fkt1(i))*exp(fkt2(i));
  end
  %
  % Integral in denominator (2. summand); 2 cancels with 1/2 mean value 
  
  nfkt(RefBin(1))=0;
  for i=RefBin(1)+1 : maxbin-1
    nfkt(i)=nfkt(i-1)+(zfkt(i)*LR_par(j,i)+zfkt(i-1)*LR_par(j,i-1))*r_bin; 
  end
  % 
  % Klett 1985, Equ. (22)
  %
  for i=RefBin(1) : maxbin-1
    beta_aero(j,i) = zfkt(i)/(1./beta_mol(RefBin(1),j) + nfkt(i)); 
  end
  % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  % ---------------------
  % Backscatter profile
  % ---------------------
  %for i=1:RefBin(1)-1
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
  
  %%%hmjb
  ndf=sum(mask_mol(1:maxbin-1,j));
  trychi2(k)=sqrt(nansum(beta_aerosol(j,1:maxbin-1).*beta_aerosol(j,1:maxbin-1)...
			 .*mask_mol(1:maxbin-1,j)')/ndf);
%  ndf=sum(mask_mol(1:RefBin(1),j));
%  trychi2(k)=sqrt(nansum(beta_aerosol(j,1:RefBin(1)).*beta_aerosol(j,1:RefBin(1))...
%			 .*mask_mol(1:RefBin(1),j)')/ndf);
  ['refbin=' num2str(RefBin(1)) ' alt=' num2str(alt(RefBin(1))) ...
   ' chi2=' num2str(trychi2(k)) ]
   
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
rb = RefBin(1); 

for i=1:maxbin-1
  if (mask_mol(i,1)==1)
    bb(i)=beta_aero(1,i);
  else
    bb(i)=nan;
  end
end


%
%----------
%   355
%----------
figure(8); hold off
xx=xx0+5*wdx; yy=yy0+5*wdy;
%set(gcf,'position',[xx,yy,2*wsx,wsy]); % units in pixels!
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
plot(bb(1:maxbin-1), alt(1:maxbin-1).*1e-3,'k','Linewidth',2);
hold off
%  end of program
disp('End of program: Klett_Manaus.m, Vers. 1.0 06/12')
%