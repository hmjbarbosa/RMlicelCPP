
minday=datenum([2012 09 12 9 0 0]);
maxday=datenum([2012 09 12 21 0 0]);

[times, P_ar] = bins(minday,maxday,5,head_ar,chphy_ar(1).data);
[times, P_ma] = bins(minday,maxday,5,head_ma,chphy_ma(1).data);
[times, P_sp] = bins(minday,maxday,5,head_sp,chphy_sp(1).data);
[times, P_ch] = bins(minday,maxday,5,head_ch,chphy_ch(1:rangebins,:));

[Pbg_ar, bg_ar]=remove_bg(P_ar,500,3);
[Pbg_ma, bg_ma]=remove_bg(P_ma,500,3);
[Pbg_sp, bg_sp]=remove_bg(P_sp,500,3);
[Pbg_ch, bg_ch]=remove_bg(P_ch,500,3);

clear z z2
z(:,1)=[1:head_ar(1).ch(1).ndata]'*head_ar(1).ch(1).binw/1e3;
z2(:,1)=z.*z;
for i=2:length(times)
  z2(:,i)=z2(:,1);
end

Pbgr2_ar=Pbg_ar.*z2;
Pbgr2_ma=Pbg_ma.*z2;
Pbgr2_sp=Pbg_sp.*z2;
Pbgr2_ch=Pbg_ch.*z2;

zmax=1867;

figure(1); clf;
temp=get(gcf,'position'); temp(3)=900; temp(4)=300;
set(gcf,'position',temp); % units in pixels!
set(gca,'position',[0.07 0.12 0.84 0.75])  
[h,bar]=gplot2(log10(Pbgr2_ar(1:zmax,:)),[], times, z(1:zmax));
datetick('x',15, 'keeplimits')
grid on;box on;
ylabel('Range (km)');ylim([0.5 12])
ylabel(bar,'Log(P r^2) [a.u.]'); 
title('ba-BA-AR'); 
prettify(gca,bar); grid on; 
screen2png('lalinet_argentina_day12b.png');

figure(2); clf;
temp=get(gcf,'position'); temp(3)=900; temp(4)=300;
set(gcf,'position',temp); % units in pixels!
set(gca,'position',[0.07 0.12 0.84 0.75])  
[h,bar]=gplot2(log10(Pbgr2_ma(1:zmax,:)),[], times, z(1:zmax));
datetick('x',15, 'keeplimits')
grid on;box on;
ylabel('Range (km)');ylim([0.5 12])
ylabel(bar,'Log(P r^2) [a.u.]'); 
title('ma-MA');
prettify(gca,bar); grid on; 
screen2png('lalinet_manaus_day12b.png');

figure(3); clf;
temp=get(gcf,'position'); temp(3)=900; temp(4)=300;
set(gcf,'position',temp); % units in pixels!
set(gca,'position',[0.07 0.12 0.84 0.75])  
[h,bar]=gplot2(log10(Pbgr2_sp(1:zmax,:)),[], times, z(1:zmax));
datetick('x',15, 'keeplimits')
grid on;box on;
ylabel('Range (km)');ylim([0.5 12])
ylabel(bar,'Log(P r^2) [a.u.]'); 
title('sp-CLA-IPEN-MSP-LIDAR-I');
prettify(gca,bar); grid on; 
screen2png('lalinet_saopaulo_day12b.png');

figure(4); clf;
temp=get(gcf,'position'); temp(3)=900; temp(4)=300;
set(gcf,'position',temp); % units in pixels!
set(gca,'position',[0.07 0.12 0.84 0.75])  
[h,bar]=gplot2(log10(Pbgr2_ch(1:zmax,:)),[], times, z(1:zmax));
datetick('x',15, 'keeplimits')
grid on; box on;
lab=ylabel('Range (km)');ylim([0.5 12])
ylabel(bar,'Log(P r^2) [a.u.]'); 
title('co-CEFOP-UDEC');
prettify(gca,bar,lab)
prettify(gca,bar); grid on; 
screen2png('lalinet_chile_day12b.png');
%