% write_ascii_Raman_Klett_AOD_Manaus.m
% ------------------------------------------------------------
% writes backscatter and extinction values to ASCII files
% and calculates the AOD
% ------------------------------------------------------------
% for Embrapa Lidar  BHeese, IfT, 06/2012
% ----------------------------------------
%
lower1 = 1; %
lower2 = 1; %
%
%upper = RefBin(1);
upper1 = 1500;
upper2 = 1500;

%fac = 1.5 % 3.12. 
fac = 1.75;
%
upper = 600
timestring = ['_' timex1(1,1:2) timex1(1,4:5) '_' timex1(nfiles,1:2) timex1(nfiles,4:5)]

clear N P 
%
%
N = [alt(lower1:upper1,1), alpha_aerosol_sm(1,lower1:upper1)'];
dlmwrite([datum '_alpha_Klett_Manus' timestring '.dat'],N, 'delimiter', '\t', 'precision', 6); 
%
P = [alt(lower2:upper2,1), beta_aerosol_sm(1,lower2:upper2)'];
dlmwrite([datum '_beta_Klett_Manus' timestring '.dat'],P, 'delimiter', '\t', 'precision', 6); 

% -------------------------------------------------------------------------
% calcuate AOD from 'lower' to 'upper' 
% plus extrapolation of mean value (lower + 50) to ground 
%--------------------------------------------------------------------------
%
AOD_Klett_Manaus_355 = sum(alpha_aerosol_sm(1,lower2:upper))*deltar + ...
fac*alpha_aerosol_sm(1,lower2-1)*(alt(lower2,1));

AOD_Raman_Manaus_355 = sum(aero_ext_raman_sm(1,lower2:upper))*deltar + ...
fac*aero_ext_raman_sm(1,lower2-1)*(alt(lower2,1));

figure(14)
%set(gcf,'position',[scrsz(3)-0.95*scrsz(3) scrsz(4)-0.95*scrsz(4) scrsz(3)-0.4*scrsz(3) scrsz(4)-0.15*scrsz(4)]);  
set(gcf,'position',[scrsz(3)-0.95*scrsz(3) scrsz(4)-0.95*scrsz(4) scrsz(3)-0.5*scrsz(3) scrsz(4)-0.15*scrsz(4)]);  

%
  title(['Embrapa Lidar at ' datum, '; ' timex1(1,1:5) ' - ' timex1(nfiles,1:5) ' LT'],'fontsize',[14]) 
  xlabel('BSC / 1 km-1 sr-1','fontsize',[14])  
  ylabel('Height / km','fontsize',[14])
  axis([-2e-3 2e-2 0 alt(rbins/4)*1e-3]); 
  box on
  hold on
 plot(beta_aerosol_sm(1,lower1:upper1), alt(lower1:upper1),'b--','LineWidth',2); 
   plot(beta_raman_sm(1,lower2:upper2), alt(lower2:upper2),'b','LineWidth',2); 
  legend('355 nm'); 
 grid on 
plot(aero_ext_raman_sm(1,1:upper1), alt(1:upper1),'g','LineStyle','--','Linewidth',0.5);
 plot(beta_aerosol_sm(1,1:upper2), alt(1:upper2),'b','LineStyle','--','Linewidth',0.5);

 line([-2 2],[alt(upper,1) alt(upper,1)],'LineStyle','--','Color','k');
 line([-2 2],[alt(lower1,1) alt(lower1,1)],'LineStyle','--','Color','g');
 line([-2 2],[alt(lower2,1) alt(lower2,1)],'LineStyle','--','Color','b');
 
 line([fac*beta_aerosol_sm(1,lower1) beta_aerosol_sm(1,lower1)],[0 alt(lower1,1)],'LineStyle','--','Color','g','Linewidth',2);
 
 AOD_H_355 =  num2str(AOD_Klett_Manaus_355, '%6.3f')
 %grid on 
 set(gca,'XGrid','on')
 
 AOD_S_532 = '0.83'; %091203 11-13 lt
 AOD_S_355 = '1.42'; %091203 11-13 lt
 %AOD_S_532 = '0.97'; %091204  13 - lt
 %AOD_S_355 = '1.42'; %091204   13 - lt
 
 pos = 12e-3;
 text(pos, 5.4, ['AOD 355 nm '],'fontsize',14,'HorizontalAlignment','right','Color','b') 
 text(pos, 5.1, ['Embrapa Lidar = ' AOD_H_355],'fontsize',14,'HorizontalAlignment','right','Color','b')

 text(pos, 4.4, ['Lidar Ratio = ' num2str(LidarRatio(1))],'fontsize',14,'HorizontalAlignment','right','Color','r')
