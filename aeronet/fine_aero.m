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
plot(time,aero.aot_total,'.');
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 3])
title('Manaus-AM/EMBRAPA','fontsize',[14]);
xlabel('Years','fontsize',[12])  
ylabel('Total AOD 500nm - SDA','fontsize',[12])
grid on;
print('sda_time_aod_total.png','-dpng');
!mogrify -trim sda_time_aod_total.png
% ---- fine
figure(2)
plot(time,aero.aot_fine,'.');
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 3])
title('Manaus-AM/EMBRAPA','fontsize',[14]);
xlabel('Years','fontsize',[12])  
ylabel('Fine AOD 500nm - SDA','fontsize',[12])
grid on;
print('sda_time_aod_fine.png','-dpng');
!mogrify -trim sda_time_aod_fine.png
% ---- coarse
figure(3)
plot(time,aero.aot_coarse,'.');
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 3])
title('Manaus-AM/EMBRAPA','fontsize',[14]);
xlabel('Years','fontsize',[12])  
ylabel('Coarse AOD 500nm - SDA','fontsize',[12])
grid on;
print('sda_time_aod_coarse.png','-dpng');
!mogrify -trim sda_time_aod_coarse.png
% ---- finefrac
figure(4)
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 3])
plot(time,aero.aot_finefrac,'.');
title('Manaus-AM/EMBRAPA','fontsize',[14]);
xlabel('Years','fontsize',[12])  
ylabel('Finefrac AOD 500nm - SDA','fontsize',[12])
grid on;
print('sda_time_aod_finefrac.png','-dpng');
!mogrify -trim sda_time_aod_finefrac.png

%% AOD em 500nm

X_tot(1:aero.ntimes,1:nlist)=NaN;
X_fin(1:aero.ntimes,1:nlist)=NaN;
X_coa(1:aero.ntimes,1:nlist)=NaN;
X_fra(1:aero.ntimes,1:nlist)=NaN;
for i=1:nlist
  for j=1:aero.ntimes
    if list(j)==i
      if (aero.aot_total   (j,1) > 3*aero.aot_total   (j,2)) ...
            X_tot(j,i)=aero.aot_total(j,1);   
      end
      if (aero.aot_fine    (j,1) > 3*aero.aot_fine    (j,2)) ...
            X_fin(j,i)=aero.aot_fine(j,1);     
      end
      if (aero.aot_coarse  (j,1) > 3*aero.aot_coarse  (j,2)) ...
            X_coa(j,i)=aero.aot_coarse(j,1);   
      end
      if (aero.aot_finefrac(j,1) > 3*aero.aot_finefrac(j,2)) ...
            X_fra(j,i)=aero.aot_finefrac(j,1); 
      end
    end
  end
end

nn=8;
% ---- total
figure(5)
boxplot(X_tot); 
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 3])
C=get(gca,'xlim');
set(gca,'xtick',[C(1):(C(2)-C(1))/nn:C(2)],'xticklabel',...
	sprintf('%0.1f|',[xlist(1):(xlist(nlist)-xlist(1))/nn:xlist(nlist)]));
title('Manaus-AM/EMBRAPA','fontsize',[14]);
xlabel('Years','fontsize',[12])  
ylabel('Total AOD 500nm - SDA','fontsize',[12])
grid on;
print('sda_timebox_aod_total.png','-dpng');
!mogrify -trim sda_timebox_aod_total.png
% ---- fine
figure(6)
boxplot(X_fin); 
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 3])
C=get(gca,'xlim');
set(gca,'xtick',[C(1):(C(2)-C(1))/nn:C(2)],'xticklabel',...
	sprintf('%0.1f|',[xlist(1):(xlist(nlist)-xlist(1))/nn:xlist(nlist)]));
title('Manaus-AM/EMBRAPA','fontsize',[14]);
xlabel('Years','fontsize',[12])  
ylabel('Fine AOD 500nm - SDA','fontsize',[12])
grid on;
print('sda_timebox_aod_fine.png','-dpng');
!mogrify -trim sda_timebox_aod_fine.png
% ---- coarse
figure(7)
boxplot(X_coa); 
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 3])
C=get(gca,'xlim');
set(gca,'xtick',[C(1):(C(2)-C(1))/nn:C(2)],'xticklabel',...
	sprintf('%0.1f|',[xlist(1):(xlist(nlist)-xlist(1))/nn:xlist(nlist)]));
title('Manaus-AM/EMBRAPA','fontsize',[14]);
xlabel('Years','fontsize',[12])  
ylabel('Coarse AOD 500nm - SDA','fontsize',[12])
grid on;
print('sda_timebox_aod_coarse.png','-dpng');
!mogrify -trim sda_timebox_aod_coarse.png
% ---- finefrac
figure(8)
boxplot(X_fra); 
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 3])
C=get(gca,'xlim');
set(gca,'xtick',[C(1):(C(2)-C(1))/nn:C(2)],'xticklabel',...
	sprintf('%0.1f|',[xlist(1):(xlist(nlist)-xlist(1))/nn:xlist(nlist)]));
title('Manaus-AM/EMBRAPA','fontsize',[14]);
xlabel('Years','fontsize',[12])  
ylabel('Finefrac AOD 500nm - SDA','fontsize',[12])
grid on;
print('sda_timebox_aod_finefrac.png','-dpng');
!mogrify -trim sda_timebox_aod_finefrac.png


