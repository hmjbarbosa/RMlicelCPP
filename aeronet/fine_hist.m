figure(1); clf;
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 4])
edges = 10.^(-3:0.1:0)'; 
h=histc([aero.aot_fine(:,1), aero.aot_coarse(:,1)],edges);
b=bar(edges,h,'histc');
delete(findobj('marker','*'));
xlim([edges(1), edges(end)])
set(gca,'xscale','log')                                           
legend('fine mode','coarse mode')
xlabel('AOD')
title('Manaus-AM/EMBRAPA','fontsize',[14]);
grid
print('sda_fine_hist.png','-dpng');
%!mogrify -trim sda_fine_hist.png


figure(2); clf
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 4])
hist(aero.aot_finefrac(:,1),30);
title('Manaus-AM/EMBRAPA','fontsize',[14]);
xlabel('AOD Fine fraction')
print('sda_fine_fraction.png','-dpng');
%!mogrify -trim sda_fine_fraction.png



xd=aero.aot_fine(:,1);
yd=aero.aot_finefrac(:,1);

n=50;
xi = linspace(min(xd(:)),max(xd(:)),n);
yi = linspace(min(yd(:)),max(yd(:)),n);

xr = interp1(xi,1:numel(xi),xd,'nearest')';
yr = interp1(yi,1:numel(yi),yd,'nearest')';

z = accumarray([xr' yr'], 1, [n, n])';

figure(3)
contourf(xi,yi,z)
ylabel('Fine fraction')
xlabel('AOD Fine mode')
colorbar
