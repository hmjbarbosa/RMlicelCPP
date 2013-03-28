% start counting from
jd1=datenum(2011,1,1,0,0,0);
% create a vector with fractional year from start date
time=2011+(aero.jd-jd1)/365.25;
% for boxplot, group data into 15day intervals
groupday=15;
% create a vector with the corresponding groups
list=floor((aero.jd-jd1)/groupday)+1;
nlist=list(size(list,1));
xlist=2011+((1:nlist)-0.5)*groupday/365.25;

% ---- total
figure(1)
fine_aero_plot(aero.jd, aero.aot_total, 'Total AOD 500nm',...
               [0 .1 .2 .3],' |.1|.2|.3' )
print(['sda_time_aod_total.png'],'-dpng');

figure(5)
fine_aero_box(aero.jd, aero.aot_total(:,1), 'Total AOD 500nm',...
               [0 .1 .2 .3],' |.1|.2|.3' )
print(['sda_timebox_aod_total.png'],'-dpng');

% ---- fine
figure(2)
fine_aero_plot(aero.jd, aero.aot_fine, 'Fine AOD 500nm',...
               [0 .1 .2 .3 .4],' |.1|.2|.3|.4' )
print('sda_time_aod_fine.png','-dpng');

figure(6)
fine_aero_box(aero.jd, aero.aot_fine(:,1), 'Fine AOD 500nm',...
               [0 .1 .2 .3 .4],' |.1|.2|.3|.4' )
print(['sda_timebox_aod_fine.png'],'-dpng');

% ---- coarse
figure(3)
fine_aero_plot(aero.jd, aero.aot_coarse, 'Coarse AOD 500nm',...
               [0 .15 .3 .45 ],' |.15|.30|.45' )
print('sda_time_aod_coarse.png','-dpng');

figure(7)
fine_aero_box(aero.jd, aero.aot_coarse(:,1), 'Coarse AOD 500nm',...
               [0 .15 .3 .45 ],' |.15|.30|.45' )
print(['sda_timebox_aod_coarse.png'],'-dpng');

% ---- finefrac
figure(4)
fine_aero_plot(aero.jd, aero.aot_finefrac, 'Finefrac AOD 500nm',...
               [0 .05 .1 .15],' |.05|.10|.15' )
print('sda_time_aod_finefrac.png','-dpng');

figure(8)
fine_aero_box(aero.jd, aero.aot_finefrac(:,1), 'Finefrac AOD 500nm',...
               [0 .05 .1 .15],' |.05|.10|.15' )
print(['sda_timebox_aod_finefrac.png'],'-dpng');

return
nn=8;
% ---- total
figure(5)
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 3])
boxplot(X_tot); 
ylim([0 1]); 
C=get(gca,'xlim');
set(gca,'xtick',[C(1):(C(2)-C(1))/nn:C(2)],'xticklabel',...
	sprintf('%0.1f|',[xlist(1):(xlist(nlist)-xlist(1))/nn:xlist(nlist)]));
title('Manaus-AM/EMBRAPA','fontsize',[14]);
xlabel('Years','fontsize',[12])  
ylabel('Total AOD 500nm','fontsize',[12])
grid on;
print('sda_timebox_aod_total.png','-dpng');
!mogrify -trim sda_timebox_aod_total.png
return
% ---- fine
figure(6)
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 3])
boxplot(X_fin); 
ylim([0 1]); 
C=get(gca,'xlim');
set(gca,'xtick',[C(1):(C(2)-C(1))/nn:C(2)],'xticklabel',...
	sprintf('%0.1f|',[xlist(1):(xlist(nlist)-xlist(1))/nn:xlist(nlist)]));
title('Manaus-AM/EMBRAPA','fontsize',[14]);
xlabel('Years','fontsize',[12])  
ylabel('Fine AOD 500nm','fontsize',[12])
grid on;
print('sda_timebox_aod_fine.png','-dpng');
!mogrify -trim sda_timebox_aod_fine.png
% ---- coarse
figure(7)
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 3])
boxplot(X_coa); 
ylim([0 1]); 
C=get(gca,'xlim');
set(gca,'xtick',[C(1):(C(2)-C(1))/nn:C(2)],'xticklabel',...
	sprintf('%0.1f|',[xlist(1):(xlist(nlist)-xlist(1))/nn:xlist(nlist)]));
title('Manaus-AM/EMBRAPA','fontsize',[14]);
xlabel('Years','fontsize',[12])  
ylabel('Coarse AOD 500nm','fontsize',[12])
grid on;
print('sda_timebox_aod_coarse.png','-dpng');
!mogrify -trim sda_timebox_aod_coarse.png
% ---- finefrac
figure(8)
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 3])
boxplot(X_fra); 
ylim([0 1]); 
C=get(gca,'xlim');
set(gca,'xtick',[C(1):(C(2)-C(1))/nn:C(2)],'xticklabel',...
	sprintf('%0.1f|',[xlist(1):(xlist(nlist)-xlist(1))/nn:xlist(nlist)]));
title('Manaus-AM/EMBRAPA','fontsize',[14]);
xlabel('Years','fontsize',[12])  
ylabel('Finefrac AOD 500nm','fontsize',[12])
grid on;
print('sda_timebox_aod_finefrac.png','-dpng');
!mogrify -trim sda_timebox_aod_finefrac.png


