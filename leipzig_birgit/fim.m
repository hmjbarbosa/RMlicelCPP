h=figure(1)
hold off

plot(mean_bg_corr(3500:4000,1),'r')
hold on
plot(mean_bg_corr(3500:4000,2),'b')

%plot(mean_bg_corr(2500:4000,1)./mean_bg_corr(2500:4000,2)*0.001,'k')
hold off

grid

%