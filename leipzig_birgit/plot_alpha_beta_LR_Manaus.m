% Plot_alpha_beta_LR_Manaus.m 
% 
% BHeese 06/12
% 
lower1 = 10;
lower2 = 20;
upper = rbbr(1);
%
% alt = alt/1e3; 
figure(15)
% set(gcf,'position',[50,100,1000,800]); % units in pixels! *** 19 " ***
 set(gcf,'position',[50,100,1000,600]); % units in pixels! *** Laptop ***
% 
%-----------------
% Beta Aerosol 
% ----------------
subplot(1,3,1) 
%subplot('Position',[0.1 0.1 0.25 0.8]); 
 xlabel('BSC, km^{-1} sr^{-1}','fontsize',[22])  
 ylabel('Height asl / m','fontsize',[22])  
%  axis([-0.01 0.1 0 alt(upper)]); 
% set(gca,'XTick',[0 0.002 0.004 0.006 0.008 0.01],'fontsize',[22])
% set(gca,'XTickLabel',{'0';'2';'4';'6';'8';'10'},'fontsize',[22])
% set(gca,'XTick',[0 0.005 0.01 0.015 0.02],'fontsize',[22])
% set(gca,'XTickLabel',{'0';'0.005';'0.01';'0.015';'0.02'},'fontsize',[22])
  box on
  hold on 
  plot(beta_raman_sm(lower1:upper), alt(lower1:upper),'b','LineWidth',2);   
 % text(0.2*6e-3, 0.88*alt(upper), ['Beta-Ref.(ana)=' betaref_1 ' at ' refheight],'fontsize',10,'HorizontalAlignment','left','Rotation',[0])
  set(gca,'fontsize',[14])
%  legend('355', '532','1064'); 
 grid on 

subplot(1,3,2)
%subplot('Position',[0.4 0.1 0.25 0.80]);  
title([' Embrapa Lidar on ' datum , ' UTC ' ],'fontsize',[22]) 
 xlabel('EXT, km^{-1}','fontsize',[22])  
 axis([-0.01 0.5 0 alt(upper)]); 
%  set(gca,'XTick',[0 0.05 0.1 ]);
%  set(gca,'XTickLabel',{'0';'0.05';'0.1'},'fontsize',[22])
%  set(gca,'YTickLabel',{''})
%  axis([-0.05 2 height*1e-3 alt(upper2)]); 
%  set(gca,'XTick',[0 0.1 0.2 0.3]);
%  set(gca,'XTickLabel',{'0';'0.1';'0.2';'0.3'},'fontsize',[22])
%  axis([-0.05 0.5 0 alt(upper)]); 
%  set(gca,'YTickLabel',{''})
%  set(gca,'XTick',[0 0.1 0.2 0.3 0.4 0.5]);
%  set(gca,'XTickLabel',{'0';'0.1';'0.2';'0.3';'0.4';'0.5'},'fontsize',[22] );

  box on
  hold on
 plot(aero_ext_raman(lower2:upper), alt(lower2:upper),'b','LineWidth',2)  
% plot(aero_ext_raman(zet_0+60:rbb_a),alt(zet_0+60:rbb_a),'b','LineWidth',2)
 grid on
 % text(0.6* 0.5, alt(upper)-0.08*alt(upper),...
 %  {[timex2(1,1:5) ' - ' timex2(nfiles,1:5) ' UTC ']} ,'FontSize',[10]);
 set(gca,'fontsize',[14])
 legend('355'); 
 
 %------------------
 %  Lidar Ratio
 % -----------------
subplot(1,3,3)
%subplot('Position',[0.7 0.1 0.25 0.8]); 
% title(['Lidar Ratio '],'fontsize',[14]) 
  xlabel('Lidar Ratio / sr','fontsize',[22])  
%  set(gca,'YTickLabel',{''})
  axis([0 100 0 alt(upper)]); 
  set(gca,'XTick',[0 20 40 60 80 100])
%  set(gca,'XTickLabel',{'0';'20';'40';'60';'80';'100'},'fontsize',[22])
  box on
  hold on
  plot(Lidar_Ratio(lower2:upper),alt(lower2:upper),'b','LineWidth',2)
  grid on
  set(gca,'fontsize',[14])
 % legend('355', '532'); 
