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
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 3])
sub=subplot('position',[0.08 0.13 0.65 0.78]);
plot(aero.jd,aero.aot_total,'.');
datetick('x','yy/mm');
ylim([0 1]); 
title('Manaus-AM/EMBRAPA','fontsize',[14]);
xlabel('Years','fontsize',[12])  
ylabel('Total AOD 500nm','fontsize',[12])
grid on;
sub=subplot('position',[0.8 0.13 0.15 0.78]);
bins=[0:0.025:1];
counts=histc(aero.aot_total(:,1),bins);
b=barh(bins+bins(2)/2,counts/sum(counts),1,'w'); 
set(b,'facecolor',[0.7 0.7 0.7]);
ylim([0 1]); xlim([0, 0.5]); xlabel('freq');
set(gca,'XTick',[0 .1 .2 .3 .4 .5]);
set(gca,'xticklabel',' |.1|.2|.3|.4|.5');
set(gca,'yticklabel','');
grid on;
print('sda_time_aod_total.png','-dpng');
%!mogrify -trim sda_time_aod_total.png

return
% ---- fine
figure(2)
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 3])
plot(time,aero.aot_fine,'.');
ylim([0 1]); 
title('Manaus-AM/EMBRAPA','fontsize',[14]);
xlabel('Years','fontsize',[12])  
ylabel('Fine AOD 500nm','fontsize',[12])
grid on;
print('sda_time_aod_fine.png','-dpng');
!mogrify -trim sda_time_aod_fine.png
% ---- coarse
figure(3)
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 3])
plot(time,aero.aot_coarse,'.');
ylim([0 1]); 
title('Manaus-AM/EMBRAPA','fontsize',[14]);
xlabel('Years','fontsize',[12])  
ylabel('Coarse AOD 500nm','fontsize',[12])
grid on;
print('sda_time_aod_coarse.png','-dpng');
!mogrify -trim sda_time_aod_coarse.png
% ---- finefrac
figure(4)
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 3])
plot(time,aero.aot_finefrac,'.');
ylim([0 1]); 
title('Manaus-AM/EMBRAPA','fontsize',[14]);
xlabel('Years','fontsize',[12])  
ylabel('Finefrac AOD 500nm','fontsize',[12])
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
      % column 1 is value
      % column 2 is error
      X_tot(j,i)=aero.aot_total(j,1);   
      X_fin(j,i)=aero.aot_fine(j,1);     
      X_coa(j,i)=aero.aot_coarse(j,1);   
      X_fra(j,i)=aero.aot_finefrac(j,1); 
    end
  end
end

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


