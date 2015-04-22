file=[datadir 'Solutions/txt/aerowv1.000.txt'];
  
solution=importdata(file, ' ', 1);

res_pres=solution.data(:,3);  % P in hPa!
res_alti=solution.data(:,2); % in m 
res_alfa=solution.data(:,5); % in m-1
res_lrt=solution.data(:,6); % in ??
res_beta=1e3*res_alfa./res_lrt; % in km-1 ??

figure(8)
hold on
plot(res_beta*1e3, res_alti*1e-3,'k','LineWidth',2);
hold off

figure(9)
hold on
plot(res_alfa*1e6, res_alti*1e-3,'k','LineWidth',2);
hold off

figure(10)
hold on
plot(res_beta*1e3, res_alti*1e-3,'k','LineWidth',2);
hold off

figure(11)
%hold on
plot(res_lrt, res_alti*1e-3,'k','LineWidth',2);
hold off

%