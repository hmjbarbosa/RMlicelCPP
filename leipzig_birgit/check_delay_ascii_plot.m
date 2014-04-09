clear all;
addpath('../matlab');
addpath('../sc');

datain='/Users/hbarbosa/lidar_data/data';
%datain='/Volumes/work/DATA/EMBRAPA/lidar/data';

jdi=datenum(2011,7,30,9,0,0);
jdf=datenum(2011,7,30,10,0,0);
[nfile, heads, chphy]=profile_read_dates(datain, jdi, jdf, 0, 0.004);

zh=[1:4000]*7.5e-3;

figure(1)
clf; hold on; grid on; box on;
plot(chphy(1).data(600:700,:),'b');
plot(chphy(2).data(600:700,:),'r');

figure(2)
gplot2(chphy(1).data(1:1000,:))

for i=1:nfile
  [rsq(:,i), tim(:,i)]=check_delay_ascii(...
      chphy(1).data(:,i),chphy(2).data(:,i),heads(1).ch(1).discr,...
      heads(1).ch(1).bits, i==nfile);
end;

figure(3)
prettify(gca); grid on;
a=findall(gca,'type','line');
set(a(1),'linewidth',2)
print('delay_examplefit.png','-dpng');

figure(4); clf; hold on;
plot(tim,rsq); grid on;
title('Correlation between analog and PC');
xlabel('Delay(bins)');
ylabel('R^2 from linear fit of PC x AN');
xlim([-10 30]);
prettify(gca); grid on;

print('delay_correlation.png','-dpng');
%
