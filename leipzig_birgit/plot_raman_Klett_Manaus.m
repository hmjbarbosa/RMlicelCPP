
%---------------
% calculate AOD 
%---------------
low = 135;  
upp = 750; 
%
alti = alt*1e-3
AOD_Klett_355 = sum(alpha_aerosol(1,low:upp),2)*deltar + ...
           alpha_aerosol(1,low-1)*(alti(low))
%
AOD_Raman = sum(real(aero_ext_raman(low:upp)))*deltar + ...
           real(aero_ext_raman(low-1))*(alti(low)) 
% 
AOD_G =  num2str(AOD_Klett_355, '%6.2f')
AOD_R =  num2str(AOD_Raman, '%6.2f')
% --------
%   Plot
% --------
rb_plot = 1600; 
%
figure(12) 
%  set(gcf,'position',[50,100,600,800]); % units in pixels! *** 19 " ***
 set(gcf,'position',[50,100,500,600]); % units in pixels! *** Laptop ***
 title(['Embrapa Raman Lidar on ' datum ', ' timestring ' LT '],'fontsize',[10]) 
  xlabel('Extinction / km^-1','fontsize',[10])  
  ylabel('Height / km','fontsize',[10])
  axis([-0.2 1.5 alti(zet_0) alti(rb_plot)]); 
  box on 
  hold on 
 % Raman 
 plot(aero_ext_raman(zet_0:rbb_a),alti(zet_0:rbb_a),'b')
 % Klett
 plot(alpha_aerosol(1,zet_0:rb-1),alti(zet_0:rb-1),'b--')
 %
 line([-2 2],[alti(upp) alti(upp)],'LineStyle','--','Color','k');
 line([-2 2],[alti(low) alti(low)],'LineStyle','--','Color','k');
 %
 legend('Raman 355')
  grid on
 % 
 % Text 
 %
 pos = 1.4;
 text(pos, 9, ['AOD Raman = ' AOD_R],'fontsize',12,'HorizontalAlignment','right','Color','r')
 text(pos, 8.5, ['AOD Klett 355 = ' AOD_G],'fontsize',12,'HorizontalAlignment','right','Color','b')
 text(pos, 8, ['AOD sun photometer = ' ],'fontsize',12,'HorizontalAlignment','right','Color','k')
