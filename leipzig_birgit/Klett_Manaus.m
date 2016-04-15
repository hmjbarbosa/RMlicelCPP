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
clear nfkt
clear extinktion
clear beta_klett_total beta_bv
clear beta_klett 
clear alpha_klett 
clear alpha_aero j i
% 
zet_0 = 1;
if ~exist('LR_par','var')
  if ~exist('fix_lr_aer','var')
    disp(['WARNING:: lidar ratio not set! assuming 55 sr^-1...']);
    LR_par(1:maxbin,1) = 55;
  else
    disp(['Lidar ratio set to ' num2str(fix_lr_aer) ' sr^-1...']);
    LR_par(1:maxbin,1) = fix_lr_aer;
  end
end
%load('true_LR.mat')
%LR_par(:,1) = res_lrt(1:maxbin);


%% ------------------------------------------------------------------------
%%   BACKWARD INTEGRATION
%% ------------------------------------------------------------------------

%  Klett (Equ. 20; 1985):
%  fkt1: 2/B_R int(beta_R) = 2 int (alpha_R) = sum (alpha_1,R+alpha_2,R)*r_bin
%  fkt2: 2 int(beta_R/B_P) = 2 int(alpha_R*B_R/B_P) =  2 int (alpha_R*S_P/S_R)
%  Fernald, AO, 1984
fkt1(RefBin(1),1) = 0; 
fkt2(RefBin(1),1) = 0;
for i=RefBin(1)-1 : -1 : zet_0
  ext_ave = (alpha_mol(i,1) + alpha_mol(i+1,1)) * r_bin; 
  fkt1(i,1) = fkt1(i+1,1) + ext_ave; 
  fkt2(i,1) = fkt2(i+1,1) + ext_ave/mol.LR_mol(1) * LR_par(i,1); 
end

%  zfkt: exp(S'-Sm') after Klett (Equ. 22; 1985) = S-Sm+fkt1-fkt2 
for i=zet_0:RefBin(1)
  zfkt(i,1)=Pr2(i,1)/Pr2_mol(RefBin(1),1)/exp(fkt1(i,1))*exp(fkt2(i,1));
  %zfkt(i,1)=Pr2(i,1)/Pr2    (RefBin(1),1)/exp(fkt1(i,1))*exp(fkt2(i,1));
end

% Integral in denominator (2. summand); 2 cancels with 1/2 mean value 
nfkt(RefBin(1),1)=0;
for i=RefBin(1)-1: -1 : zet_0
  nfkt(i,1)=nfkt(i+1,1)+(zfkt(i,1)*LR_par(i,1)+zfkt(i+1,1)*LR_par(i+1,1))*r_bin; 
end

% Klett 1985, Equ. (22)
for i=RefBin(1) : -1 : zet_0
  beta_klett_total(i,1) = zfkt(i,1)/(1./beta_mol(RefBin(1),1) + nfkt(i,1)); 
end

%% ------------------------------------------------------------------------
%%   FORWARD INTEGRATION
%% ------------------------------------------------------------------------
for i=RefBin(1)+1 : maxbin
  ext_ave = (alpha_mol(i,1) + alpha_mol(i-1,1)) * r_bin; 
  fkt1(i) = fkt1(i-1) + ext_ave; 
  fkt2(i) = fkt2(i-1) + ext_ave/mol.LR_mol(1) * LR_par(i,1); 
end
% 
for i=RefBin(1) : maxbin
  zfkt(i,1)=Pr2(i,1)/Pr2_mol(RefBin(1),1)/exp(fkt1(i,1))*exp(fkt2(i,1));
  %zfkt(i,1)=Pr2(i,1)/Pr2    (RefBin(1),1)/exp(fkt1(i,1))*exp(fkt2(i,1));
end
%
nfkt(RefBin(1),1)=0;
for i=RefBin(1)+1 : maxbin
  nfkt(i,1)=nfkt(i-1,1)+(zfkt(i,1)*LR_par(i,1)+zfkt(i-1,1)*LR_par(i-1,1))*r_bin; 
end
% 
for i=RefBin(1) : maxbin
  beta_klett_total(i,1) = zfkt(i,1)/(1./beta_mol(RefBin(1),1) + nfkt(i,1)); 
end

%% ------------------------------------------------------------------------
%% BACKSCATTER PROFILE
%% ------------------------------------------------------------------------

%for i=1:RefBin(1)-1
for i=1:maxbin
  % substract beta_mol to achieve beta_klett
  beta_klett(i,1) = beta_klett_total(i,1) - beta_mol(i,1); 
  % careful! depends on choosen LR
  alpha_klett(i,1) = beta_klett(i,1) * LR_par(i,1); 
end   
%beta_klett=nanmysmooth(beta_klett,0,200);
%alpha_klett=nanmysmooth(alpha_klett,0,200);

%% ------------------------------------------------------------------------
%%  PLOTS
%% ------------------------------------------------------------------------
for i=1:maxbin
  if (mask_mol(i,1)==1)
    bb(i)=beta_klett(i,1);
  else
    bb(i)=nan;
  end
end

if (debug==0)
  return
end

%
%----------
%   355
%----------
tope=RefBin(1);%floor(4/r_bin);
figure
temp=get(gcf,'position'); temp(3)=260; temp(4)=650;
set(gcf,'position',temp); % units in pixels!
hold off
plot(beta_klett_total(1:maxbin,1)*1e6, alt(1:maxbin).*1e-3,'r','Linewidth',1);
axis([-0.5 20.0 0 alt(tope)*1e-3*1.1]); 
%axis([-1e-3 0.06 0 alt(tope)*1e-3]); 
xlabel('BSC / Mm-1 sr-1','fontsize',[14])  
ylabel('Height / km','fontsize',[14])
title(['Klett'],'fontsize',[14]) 
grid on
hold on
plot(beta_mol (1:maxbin,1)*1e6, alt(1:maxbin).*1e-3,'g','Linewidth',1);
plot(beta_klett(1:maxbin,1)*1e6, alt(1:maxbin).*1e-3,'b','Linewidth',1);
plot(beta_klett(RefBin(1),1)*1e6, alt(RefBin(1)).*1e-3,'r*');
legend('Total', 'Molecular', 'Klett', 'Reference Bin'); 
plot(bb(1:maxbin)*1e3, alt(1:maxbin).*1e-3,'k','Linewidth',2);
hold off

%  end of program
disp('End of program: Klett_Manaus.m, Vers. 1.0 06/12')
%
