% rayleigh_fit_Manus.m 
%
%  scales the molecular signal onto the lidar signal 
% ---------------------------------------------------
%  adaption to Manaus Raman Lidar    BHeese 06/12
%---------------------------------------------------
%  first run the following programs:   
%
%       read_ascii_Manaus.m 
%       read_sonde_Manaus.m
% ---------------------------------------------------
clear altbin xl_scal_1 xu_scal_1 xl_scal_2 xu_scal_2 xl_scal_3 xu_scal_3
clear meanRaySig meanpr2 SigFak RaySig log_pr2 Ray_Fit
clear RefBin diff_1 abst_1 diff_2 abst_2 diff_3 abst_3
% ---------------------------------------------------

%%------------------------------------------------------------------------
%%  INTERPOLATION TO LIDAR SAMPLING ALTITUDES
%%------------------------------------------------------------------------

% highest altitude of sounding in units of lidar bins
maxbin=floor(alt_snd(nlev_snd)*1e-3/r_bin);
% or if you want to extrapolate the sounding data, just set to the
% number of bins in the lidar data
%maxbin = size(channel,1);

% hmjb - beta_ray decays exponentially towards zero with increasing
% height. Extrapolating it above the highest level in the sounding can
% lead to negative (unphysical) values. Hence interpolation is done in
% log() and then the exp() of the result is taken.
beta_mol(:,1) = exp(interp1(alt_snd, log(beta_mol_snd(:,1)), alt(1:maxbin),'linear','extrap'));
beta_mol(:,2) = exp(interp1(alt_snd, log(beta_mol_snd(:,2)), alt(1:maxbin),'linear','extrap'));
%beta_mol(1,:) = exp(interp1(alt_snd, log(beta_mol_snd(:,1)), alt(1:maxbin),'linear','extrap'));
%beta_mol(2,:) = exp(interp1(alt_snd, log(beta_mol_snd(:,2)), alt(1:maxbin),'linear','extrap'));

% -----------------
%  Rayleigh Signal 
% -----------------
alpha_mol(:,1) = beta_mol(:,1).*LR_mol(1); 
alpha_mol(:,2) = beta_mol(:,2).*LR_mol(2); 
% 
for j = 1:2
  for i=1:maxbin
    if i==1
      tau(j,i) = alpha_mol(i,j)*r_bin; 
    else
      tau(j,i) = tau(j,i-1)+alpha_mol(i,j)*r_bin; 
    end
  end
end

for j = 1:2
  for i=1:maxbin
    % calculate pr2_ray_sig in km-1 
    if (j==1 || j==2)
      pr2_ray_sig(j,i)=beta_mol(i,j)*exp(-tau(j,i)-tau(1,i));
    elseif (j==3 || j==4)
      pr2_ray_sig(j,i)=beta_mol(i,j)*exp(-tau(j,i)-tau(3,i));
    else
      pr2_ray_sig(j,i)=beta_mol(i,j)*exp(-tau(j,i)-tau(5,i));
    end
  end
end


% ----------------------------------------
%  choose altitude range for Rayleigh fit
% ----------------------------------------
% 355 nm elastic channel
xl_scal_1 = round(15/r_bin); % km
xu_scal_1 = round(17/r_bin); % km
% 387 nm Raman channel
xl_scal_2 = round(15/r_bin); % km
xu_scal_2 = round(17/r_bin); % km
% simulado molecular
meanRaySig(1) = mean(pr2_ray_sig(1,xl_scal_1:xu_scal_1)); 
meanRaySig(2) = mean(pr2_ray_sig(2,xl_scal_2:xu_scal_2)); 
% 
% ----------------
%   mean signals 
% -----------------
% medido lidar
meanpr2(1) = mean(pr2(xl_scal_1:xu_scal_1,1)); 
meanpr2(2) = mean(pr2(xl_scal_2:xu_scal_2,2)); 
%    
% Scales the molecular-sounding to the "values" of the lidar data
RaySig(1,:) = pr2_ray_sig(1,:)*meanpr2(1)/meanRaySig(1); 
RaySig(2,:) = pr2_ray_sig(2,:)*meanpr2(2)/meanRaySig(2); 
% ------------
%  logarithm
% ------------
Ray_Fit(1,:) = log(RaySig(1,:));  
Ray_Fit(2,:) = log(RaySig(2,:)); 
            
log_pr2 = real(log(pr2));    
%        
% ----------------------
%   find reference bins
% ----------------------
% *****************
%    channel 1
% *****************
%hmjb abst_1=1e-3;
abst_1=(real(log_pr2(xl_scal_1,1)) - Ray_Fit(1,xl_scal_1)).^2;
RefBin(1)=xl_scal_1;
for j=xl_scal_1:xu_scal_1
  diff_1(j) = (real(log_pr2(j,1)) - Ray_Fit(1,j)).^2; 
  if diff_1(j) < abst_1
    abst_1 = diff_1(j);
    RefBin(1)=j;  
  end
end

% *****************
%    channel 2
% *****************
%hmjb abst_2=1e-3; 
abst_2=(real(log_pr2(xl_scal_2,2)) - Ray_Fit(2,xl_scal_2)).^2;
RefBin(2)=xl_scal_2;
for j=xl_scal_2:xu_scal_2 
  diff_2(j) = (real(log_pr2(j,2))- Ray_Fit(2,j)).^2;  
  if diff_2(j) < abst_2
    abst_2=diff_2(j);
    RefBin(2)=j; 
  end
end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%
% --------      
%  plots
% --------

figure(6)
xx=xx0+1*wdx; yy=yy0+1*wdy;
set(gcf,'position',[xx,yy,2*wsx,wsy]); % units in pixels!
subplot(1,2,1)
plot(pr2(1:maxbin,1), alt(1:maxbin)*1e-3); 
xlabel('range smooth bg-corr signal','fontsize',[10])  
ylabel('height / km','fontsize',12)
title('Rayleigh Fit 355','fontsize',14)
grid on
hold on
plot(RaySig(1,1:maxbin), alt(1:maxbin)*1e-3,'g','LineWidth',2); 
plot(pr2(RefBin(1),1), alt(RefBin(1))*1e-3,'r*');
hold off
legend('Lidar', 'Rayleigh Fit', 'Reference Bin'); 
%   
subplot(1,2,2)
plot(pr2(1:maxbin,2), alt(1:maxbin)*1e-3); 
xlabel('range smooth bg-corr signal','fontsize',[10])  
title('Rayleigh Fit 387','fontsize',14)
grid on
hold on
plot(RaySig(2,1:maxbin), alt(1:maxbin)*1e-3,'g','LineWidth',2); 
plot(pr2(RefBin(2),2), alt(RefBin(2))*1e-3,'r*');
legend('Lidar', 'Rayleigh Fit', 'Reference Bin'); 

%
% -------------
%  log signal
% -------------
figure(7)
xx=xx0+3*wdx; yy=yy0+3*wdy;
set(gcf,'position',[xx,yy,2*wsx,wsy]); % units in pixels!
subplot(1,2,1)
plot(log_pr2(1:maxbin,1),alt(1:maxbin)*1e-3,'b');    
xlabel('ln range smooth bg-corr signal','fontsize',[10])  
ylabel('height / km','fontsize',12)
title('Rayleigh fit Ln 355' ,'fontsize',14) 
grid on 
hold on
plot(Ray_Fit(1,1:maxbin),alt(1:maxbin)*1e-3,'g','LineWidth',2);   
plot(log_pr2(RefBin(1),1), alt(RefBin(1))*1e-3,'r*');
hold off
%
subplot(1,2,2)
plot(log_pr2(1:maxbin,2),alt(1:maxbin)*1e-3,'b');  
xlabel('ln range smooth bg-corr signal','fontsize',[10])  
title('Rayleigh fit Ln 387' ,'fontsize',14) 
grid on
hold on
plot(Ray_Fit(2,1:maxbin),alt(1:maxbin)*1e-3,'g','LineWidth',2);   
plot(log_pr2(RefBin(2),2), alt(RefBin(2))*1e-3,'r*');
hold off
%
disp('End of program: rayleigh_fit_Manaus.m, Vers. 1.0 06/12')

