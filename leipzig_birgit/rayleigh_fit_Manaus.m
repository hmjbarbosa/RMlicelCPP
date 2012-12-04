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
%  one rangebin 
altbin=7.5*1e-3;
% ----------------------------------------
%  choose altitude range for Rayleigh fit
% ----------------------------------------
% 355 nm elastic channel
xl_scal_1 = round(10/altbin); % km
xu_scal_1 = round(12/altbin); % km
% 387 nm Raman channel
xl_scal_2 = round(10/altbin); % km
xu_scal_2 = round(12/altbin); % km
% 407 nm  H_2_O channel 
xl_scal_3 = round(6/altbin); % km
xu_scal_3 = round(7/altbin); % km
%   
meanRaySig(1) = mean(pr2_ray_sig(1,xl_scal_1:xu_scal_1)); 
meanRaySig(2) = mean(pr2_ray_sig(2,xl_scal_2:xu_scal_2)); 
meanRaySig(3) = mean(pr2_ray_sig(3,xl_scal_3:xu_scal_3)); 
% 
% ----------------
%   mean signals 
% -----------------
meanpr2(1) = mean(pr2(xl_scal_1:xu_scal_1,1)); 
meanpr2(2) = mean(pr2(xl_scal_2:xu_scal_2,2)); 
meanpr2(3) = mean(pr2(xl_scal_3:xu_scal_3,3)); 
%    
SigFak(1) = meanpr2(1)/meanRaySig(1);
SigFak(2) = meanpr2(2)/meanRaySig(2); 
SigFak(3) = meanpr2(3)/meanRaySig(3);   
%
RaySig(1,:) = SigFak(1).*pr2_ray_sig(1,:); 
RaySig(2,:) = SigFak(2).*pr2_ray_sig(2,:); 
RaySig(3,:) = SigFak(3).*pr2_ray_sig(3,:); 
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
abst_1=1e-3; 
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
abst_2=1e-3; 
for j=xl_scal_2:xu_scal_2 
  diff_2(j) = (real(log_pr2(j,2))- Ray_Fit(2,j)).^2;  
  if diff_2(j) < abst_2
    abst_2=diff_2(j);
    RefBin(2)=j; 
    % else RefBin(2)= RefBin(1)
  end
end
% *****************
%    channel 3
% *****************
abst_3=1e-3; 
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
rb = 3000;  % plot height

figure(9)
% set(gcf,'position',[50,100,1200,800]); % units in pixels! *** 19 " ***
 set(gcf,'position',[50,100,1000,600]); % units in pixels! *** Laptop ***
%
  subplot(1,3,1)
  subplot('Position',[0.1 0.08 0.2 0.85]); 
  title('Rayleigh Fit 355 nm Pr^2','fontsize',14)
  ylabel('height / m','fontsize',12)
  box on 
  hold on
  plot(pr2(1:rb,1), alt(1:rb)); 
  plot(RaySig(1,1:rb), alt(1:rb),'g','LineWidth',2); 
  plot(pr2(RefBin(1),1), alt(RefBin(1)),'r*');
  grid on
%  legend('355 nm', 'Rayleigh Fit', 'Reference Bin'); 
%   
 subplot(1,3,2)
  subplot('Position',[0.4 0.08 0.2 0.85]); 
    title('Rayleigh Fit 387 nm Pr^2','fontsize',14)
  box on 
  hold on
  plot(pr2(1:rb,2), alt(1:rb)); 
  plot(RaySig(2,1:rb), alt(1:rb),'g','LineWidth',2); 
  plot(pr2(RefBin(2),2), alt(RefBin(2)),'r*');
 % legend('387 nm', 'Rayleigh Fit', 'Reference Bin'); 
  grid on
 
 subplot(1,3,3)
  subplot('Position',[0.7 0.08 0.2 0.85]); 
 title(['H_20' ' ' datum],'fontsize',14) 
  box on 
  hold on
  plot(pr2(1:rb,3), alt(1:rb)); 
  plot(RaySig(3,1:rb), alt(1:rb),'g','LineWidth',2); 
%  plot(pr2(RefBin(3),3), alt(RefBin(3)),'r*');
%  legend('355a nm', 'Rayleigh Fit', 'Reference Bin'); 
  grid on
%
% -------------
%  log signal
% -------------
figure(10)
% set(gcf,'position',[50,100,1200,800]); % units in pixels! *** 19 " ***
 set(gcf,'position',[50,100,1000,600]); % units in pixels! *** Laptop ***
%
 subplot(1,3,1)
  subplot('Position',[0.1 0.08 0.2 0.85]); 
   title('rayleigh fit 355 ln Pr^2' ,'fontsize',14) 
  box on  
  hold on
  plot(log_pr2(1:rb,1),alt(1:rb),'b');    
  plot(Ray_Fit(1,1:rb),alt(1:rb),'g','LineWidth',2);   
  plot(log_pr2(RefBin(1),1), alt(RefBin(1)),'r*');
  grid on 
 %  legend('355 nm', 'Rayleigh Fit','Reference Bin'); 
 subplot(1,3,2)
  subplot('Position',[0.4 0.08 0.2 0.85]); 
  title('rayleigh fit 387 ln Pr^2' ,'fontsize',14) 
  box on 
  hold on
  plot(log_pr2(1:rb,2),alt(1:rb),'b');  
  plot(Ray_Fit(2,1:rb),alt(1:rb),'g','LineWidth',2);   
  plot(log_pr2(RefBin(2),2), alt(RefBin(2)),'r*');
  grid on
 % legend('387 nm', 'Rayleigh Fit', 'Reference Bin'); 
  
 subplot(1,3,3)
  subplot('Position',[0.7 0.08 0.2 0.85]); 
  title(['H_20' ' ' datum],'fontsize',14) 
  box on 
  hold on
  plot(log_pr2(1:rb,3),alt(1:rb),'b');  
  plot(Ray_Fit(3,1:rb),alt(1:rb),'g','LineWidth',2);   
 % plot(log_pr2(RefBin(3),3), alt(RefBin(3)),'r*');
  grid on
% legend('407 nm', 'Rayleigh Fit', 'Reference Bin'); 
%  
  disp('End of program: rayleigh_fit_Manaus.m, Vers. 1.0 06/12')
  
