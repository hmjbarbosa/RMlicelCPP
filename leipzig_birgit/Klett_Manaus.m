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
clear ext_ray
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
zet_0 = 100;   % bin
sm_span = 11;  % Range for Savitzky-Golay smoothing  * 7.5 m 
%hmjb ja definido em read_sonde_Manaus rbins = 3000; 
%
% ***************************************************
%  set reference values for alpha und beta Particle 
% ***************************************************
beta_par(1,RefBin(1)) = 1e-6; % km-1
%
alpha_par(1,RefBin(1)) = beta_par(1,RefBin(1))*LidarRatio(1,RefBin(1)); 
%   
for j=1:1
  % ----------------------------                
  %  use range corrected signal
  % ----------------------------
  rc_signal(j,:) = pr2(:,j);
  %  
  %  Ref_Bin = min(RefBin); 
  Ref_Bin = RefBin(j); 
  ext_ray(j,:) = alpha_mol(j,:); 
  %
  % ***********************************
  %  Backscatter coefficient: beta_par
  % ***********************************
  %   
  beta_par(j,Ref_Bin-1) = beta_par(j,Ref_Bin); 
  beta_bv(j) = beta_par(j,Ref_Bin)+ beta_mol(j,Ref_Bin);

% -------------------------------------------------------------------------
%  Klett (Equ. 20; 1985):
%  fkt1: 2/B_R int(beta_R) = 2 int (alpha_R) = sum (alpha_1,R+alpha_2,R)*deltar
%  fkt2: 2 int(beta_R/B_P) = 2 int(alpha_R*B_R/B_P) =  2 int (alpha_R*S_P/S_R)
% -------------------------------------------------------------------------
%  Fernald, AO, 1984
%
deltar = 7.5e-3;
ext_ave =(ext_ray(j,Ref_Bin) + ext_ray(j,Ref_Bin-1)) * deltar;
fkt1(Ref_Bin) = ext_ave; 
fkt2(Ref_Bin) = ext_ave/xlidar(j) * LidarRatio(j,Ref_Bin); 
% 
%  +++++++++++++++++++++++
%   backward integration
%  +++++++++++++++++++++++
for i=Ref_Bin-1 : -1 : zet_0
  ext_ave = (ext_ray(j,i) + ext_ray(j,i-1)) * deltar; 
  fkt1(i) = fkt1(i+1) + ext_ave; 
  fkt2(i) = fkt2(i+1) + ext_ave/xlidar(j) * LidarRatio(j,i); 
end

% 
% -----------------------------------------------------------------------
%  zfkt: exp(S'-Sm') after Klett (Equ. 22)(Paper 1985) = S-Sm+fkt1-fkt2 
% -----------------------------------------------------------------------
for i=zet_0:Ref_Bin
  zfkt(i)=rc_signal(j,i)/rc_signal(j,Ref_Bin)/exp(fkt1(i))*exp(fkt2(i));
%hmjb  zfkt(i)=rc_signal(j,i)/rc_signal(j,Ref_Bin)*exp(fkt1(i))/exp(fkt2(i));
end
%
% Integral in denominator (2. summand); 2 cancels with 1/2 mean value 

%hmjb nfkt(Ref_Bin)=zfkt(Ref_Bin)*deltar/LidarRatio(j,Ref_Bin); 
nfkt(Ref_Bin)=(zfkt(Ref_Bin)+zfkt(Ref_Bin-1))*deltar/LidarRatio(j,Ref_Bin); 
for i=Ref_Bin-1: -1 : zet_0
  nfkt(i)=nfkt(i+1)+(zfkt(i)+zfkt(i+1))*deltar*LidarRatio(j,i); 
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
for i=Ref_Bin : rbins-1
   ext_ave = (ext_ray(j,i) + ext_ray(j,i+1)) * deltar; 
   fkt1(i) = fkt1(i-1) + ext_ave; 
   fkt2(i) = fkt2(i-1) + ext_ave/xlidar(j) * LidarRatio(j,i); 
  end
% 
% -----------------------------------------------------------------------
%  zfkt: exp(S'-Sm') after Klett (Equ. 22)(Paper 1985) = S-Sm+fkt1-fkt2 
% -----------------------------------------------------------------------
  for i=Ref_Bin : rbins-1
    zfkt(i)=rc_signal(j,i)/rc_signal(j,Ref_Bin)/exp(fkt1(i))*exp(fkt2(i));
  end
%
% Integral in denominator (2. summand); 2 cancels with 1/2 mean value 

%hmjb   nfkt(Ref_Bin)=zfkt(Ref_Bin)*deltar/LidarRatio(j,Ref_Bin); 
   nfkt(Ref_Bin)=(zfkt(Ref_Bin)+zfkt(Ref_Bin-1))*deltar/LidarRatio(j,Ref_Bin); 
     for i=Ref_Bin : rbins-1
       nfkt(i)=nfkt(i-1)+(zfkt(i)+zfkt(i-1))*deltar*LidarRatio(j,i); 
     end
% 
% Klett 1985, Equ. (22)
%
  for i=Ref_Bin : rbins-1
  beta_aero(j,i) = zfkt(i)/(1./beta_bv(j) + nfkt(i)); 
  end
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% ---------------------
% Backscatter profile
% ---------------------
%for i=1:Ref_Bin-1
   for i=1:rbins-1
    if i <= zet_0
      beta_aerosol(j,i) = NaN; 
     alpha_aerosol(j,i) = NaN; 
    else      
 % substract beta_mol to achieve beta_aerosol
     beta_aerosol(j,i) = beta_aero(j,i) - beta_mol(j,i); 
    alpha_aerosol(j,i) = beta_aerosol(j,i) * LidarRatio(j,i); % careful! 
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
scrsz = get(0,'ScreenSize'); 
%
figure(8)
%set(gcf,'position',[scrsz(3)-0.95*scrsz(3) scrsz(4)-0.95*scrsz(4) scrsz(3)-0.6*scrsz(3) scrsz(4)-0.15*scrsz(4)]);  
set(gcf,'position',[scrsz(3)-0.9*scrsz(3) scrsz(4)-0.9*scrsz(4) scrsz(3)-0.6*scrsz(3) scrsz(4)-0.15*scrsz(4)]);  
%
%----------
%   532 
%----------
title(['Embrapa Lidar at ' datum],'fontsize',[14]) 
xlabel('BSC / km-1 sr-1','fontsize',[14])  
ylabel('Height agl/ km','fontsize',[14])
axis([-2e-3 5e-3 0 alt(rbins)*1e-3]); 
% axis([min(beta_aerosol(1,100:rbins/2)) max(beta_aerosol(1,1:rbins/2))+0.1*max(beta_aerosol(1,1:rbins/2)) 0 alt(rbins/2)]); 
  box on
  hold on
 plot(beta_aerosol_sm(1,1:rbins-1), alt(1:rbins-1).*1e-3,'b','Linewidth',1); 
 grid on 
 %
 %annotation('textbox', [0.62 0.8 0.28 0.04]);
 %text(0.1*10e-3, alt(1,rb)-0.02*alt(1,rb),...
 %   {[hourx(1,:) ':' minutex(1,:) ':' secondx(1,:) ' - '...
 %   hourx(nmeas,:) ':' minutex(nmeas,:) ':' secondx(nmeas,:) ' UTC ']} ,'FontSize',[10]);
%

 %  end of program
  disp('End of program: Klett_Manaus.m, Vers. 1.0 06/12')
