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

% ----------------------------------------
%  choose altitude range for Rayleigh fit
% ----------------------------------------
% 355 nm elastic channel
xl_scal_1 = round(15/r_bin); % km
xu_scal_1 = round(17/r_bin); % km
% 387 nm Raman channel
xl_scal_2 = round(15/r_bin); % km
xu_scal_2 = round(17/r_bin); % km
% 407 nm  H_2_O channel 
xl_scal_3 = round(15/r_bin); % km
xu_scal_3 = round(17/r_bin); % km
% simulado molecular
meanRaySig(1) = mean(pr2_ray_sig(1,xl_scal_1:xu_scal_1)); 
meanRaySig(2) = mean(pr2_ray_sig(2,xl_scal_2:xu_scal_2)); 
meanRaySig(3) = mean(pr2_ray_sig(3,xl_scal_3:xu_scal_3)); 
% 
% ----------------
%   mean signals 
% -----------------
% medido lidar
meanpr2(1) = mean(pr2(xl_scal_1:xu_scal_1,1)); 
meanpr2(2) = mean(pr2(xl_scal_2:xu_scal_2,2)); 
meanpr2(3) = mean(pr2(xl_scal_3:xu_scal_3,3)); 
%    
% Scales the molecular-sounding to the "values" of the lidar data
RaySig(1,:) = pr2_ray_sig(1,:)*meanpr2(1)/meanRaySig(1); 
RaySig(2,:) = pr2_ray_sig(2,:)*meanpr2(2)/meanRaySig(2); 
RaySig(3,:) = pr2_ray_sig(3,:)*meanpr2(3)/meanRaySig(3); 
% ------------
%  logarithm
% ------------
Ray_Fit(1,:) = log(RaySig(1,:));  
Ray_Fit(2,:) = log(RaySig(2,:)); 
Ray_Fit(3,:) = log(RaySig(3,:));  
            
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
% *****************
%    channel 3
% *****************
%hmjb abst_3=1e-3; 
abst_3=(real(log_pr2(xl_scal_3,3)) - Ray_Fit(3,xl_scal_3)).^2;
RefBin(3)=xl_scal_3;
for j=xl_scal_3:xu_scal_3 
  diff_3(j) = (real(log_pr2(j,3))- Ray_Fit(3,j)).^2;  
  if diff_3(j) < abst_3
    abst_3=diff_3(j); 
    RefBin(3)=j; 
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
plot(pr2(1:rbins,1), alt(1:rbins)*1e-3); 
xlabel('range smooth bg-corr signal','fontsize',[10])  
ylabel('height / km','fontsize',12)
title('Rayleigh Fit 355','fontsize',14)
grid on
hold on
plot(RaySig(1,1:rbins), alt(1:rbins)*1e-3,'g','LineWidth',2); 
plot(pr2(RefBin(1),1), alt(RefBin(1))*1e-3,'r*');
hold off
legend('Lidar', 'Rayleigh Fit', 'Reference Bin'); 
%   
subplot(1,2,2)
plot(pr2(1:rbins,2), alt(1:rbins)*1e-3); 
xlabel('range smooth bg-corr signal','fontsize',[10])  
title('Rayleigh Fit 387','fontsize',14)
grid on
hold on
plot(RaySig(2,1:rbins), alt(1:rbins)*1e-3,'g','LineWidth',2); 
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
plot(log_pr2(1:rbins,1),alt(1:rbins)*1e-3,'b');    
xlabel('ln range smooth bg-corr signal','fontsize',[10])  
ylabel('height / km','fontsize',12)
title('Rayleigh fit Ln 355' ,'fontsize',14) 
grid on 
hold on
plot(Ray_Fit(1,1:rbins),alt(1:rbins)*1e-3,'g','LineWidth',2);   
plot(log_pr2(RefBin(1),1), alt(RefBin(1))*1e-3,'r*');
hold off
%
subplot(1,2,2)
plot(log_pr2(1:rbins,2),alt(1:rbins)*1e-3,'b');  
xlabel('ln range smooth bg-corr signal','fontsize',[10])  
title('Rayleigh fit Ln 387' ,'fontsize',14) 
grid on
hold on
plot(Ray_Fit(2,1:rbins),alt(1:rbins)*1e-3,'g','LineWidth',2);   
plot(log_pr2(RefBin(2),2), alt(RefBin(2))*1e-3,'r*');
hold off
%
disp('End of program: rayleigh_fit_Manaus.m, Vers. 1.0 06/12')

