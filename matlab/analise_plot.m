
%% PLOTS
alt1=dias.data(idx,6)*1e3; n1=floor(alt1/7.5);
alt2=dias.data(idx,7)*1e3; n2=floor(alt2/7.5)+1;

c1=dias.data(idx,8);
c2=dias.data(idx,9);
e1=dias.data(idx,10);
e2=dias.data(idx,11);

%c1(1)=50; c2(1)= 75; e1(1)=15; e2(1)=40;%1
%c1(2)= 5; c2(2)= 18; e1(2)=24; e2(2)=37;%2 fraco
%c1(3)=69; c2(3)= 85; e1(3)=39; e2(3)=59;%3
%c1(4)=99; c2(4)=140; e1(4)=35; e2(4)=75;%4
%c1(5)=68; c2(5)= 99; e1(5)=30; e2(5)=60;%5
%c1(6)=15; c2(6)= 42; e1(6)=50; e2(6)=75;%6%%%
%c1(7)=155; c2(7)=215; e1(7)=67; e2(7)=126;%7

figure(2)
clear tmp;
%tmp(n1:n2,jd1)=mixr(n1:n2,:);
tmp(n1:n2,:)=mixr(n1:n2,:);
tmp(tmp==0)=NaN;
lim=jd(size(jd));
dv=(lim(2)-lim(1))/(size(tmp,2)-1);
[C2, h2]=gplot(tmp(n1:n2,:), [0:0.25:15],[lim(1):dv:lim(2)],zh(n1:n2));
title(['H2O ' datestr(jd(1)) ],'fontsize',14);
datetick('x','keeplimits','keepticks');
grid on;
alt=[zh(n1) zh(n2)];
line([jd(c1) jd(c1)],alt,'linewidth',2,'color','black','linestyle','-');
line([jd(c2) jd(c2)],alt,'linewidth',2,'color','black','linestyle','-');
line([jd(e1) jd(e1)],alt,'linewidth',2,'color','black','linestyle','--');
line([jd(e2) jd(e2)],alt,'linewidth',2,'color','black','linestyle','--');
alt=ones(2)*(alt1+alt2)/2;
line(lim,alt,'linewidth',2,'color','black','linestyle','-.');
set(gca,'fontsize',12);
print('-dpng',['pic2_idx' num2str(idx) '.png'])

figure(1)
clear tmp;
%tmp(n1:n2,jd1)=chphy(1).rcs(n1:n2,:);
tmp(n1:n2,:)=chphy(1).rcs(n1:n2,:);
tmp(tmp==0)=NaN;
[C1, h1]=gplot2(tmp(n1:n2,:),[],[lim(1):dv:lim(2)],zh(n1:n2));
title(['RCS ' datestr(jd(1))], 'fontsize',14);
datetick('x','keeplimits','keepticks');
grid on;
alt=[zh(n1) zh(n2)];
line([jd(c1) jd(c1)],alt,'linewidth',2,'color','black','linestyle','-');
line([jd(c2) jd(c2)],alt,'linewidth',2,'color','black','linestyle','-');
line([jd(e1) jd(e1)],alt,'linewidth',2,'color','black','linestyle','--');
line([jd(e2) jd(e2)],alt,'linewidth',2,'color','black','linestyle','--');
alt=ones(2)*(alt1+alt2)/2;
line(lim,alt,'linewidth',2,'color','black','linestyle','-.');
set(gca,'fontsize',12);
print('-dpng',['pic1_idx' num2str(idx) '.png'])

figure(3)
clear cloud env;
cloud(n1:n2)=nanmean(mixr(n1:n2,c1:c2),2);
env(n1:n2)=nanmean(mixr(n1:n2,e1:e2),2);
plot(cloud(n1:n2),zh(n1:n2),'b-o',env(n1:n2),zh(n1:n2),'r-v');
title(['H2O ' datestr(jd(1))], 'fontsize',14);
grid on;
lim=xlim;
alt=ones(2)*(alt1+alt2)/2;
line(lim,alt,'linewidth',2,'color','black','linestyle','-.');
set(gca,'fontsize',12);
print('-dpng',['pic3_idx' num2str(idx) '.png'])

figure(4)
clear cloud env;
cloud(n1:n2)=nanmean(mixr(n1:n2,c1:c2),2);
env(n1:n2)=nanmean(mixr(n1:n2,e1:e2),2);
plot(cloud(n1:n2)-env(n1:n2),zh(n1:n2));
ylim([zh(n1) zh(n2)]);
xlim([-3 3]);
title(['H2O Cloud-Env' datestr(jd(1)) ], 'fontsize',14);
grid on;
lim=xlim;
alt=ones(2)*(alt1+alt2)/2;
line(lim,alt,'linewidth',2,'color','black','linestyle','-.');
set(gca,'fontsize',12);
print('-dpng',['pic4_idx' num2str(idx) '.png'])

%
%