allsyn
%todos
n=RefBin(1);

figure(8); set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8])
print(sprintf('klett%d.png', 0),'-dpng');
figure(9); set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8])
print(sprintf('ramana%d.png',0),'-dpng');
figure(10); set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8])
print(sprintf('ramanb%d.png',0),'-dpng');
save(sprintf('step%d.mat',0),'alt','beta_klett','beta_raman', ...
     'alpha_klett','alpha_raman');

Ulla_Overlap
ncorr(:,1)=overlap;
Raman_Manaus
Raman_beta_Manaus

figure(8);  set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8])
print(sprintf('klett%d.png', 1),'-dpng');
figure(9);  set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8])
print(sprintf('ramana%d.png',1),'-dpng');
figure(10); set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8])
print(sprintf('ramanb%d.png',1),'-dpng');
figure(91); set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8])
print(sprintf('overlap%d.png',1),'-dpng');
save(sprintf('step%d.mat',1),'alt','beta_klett','beta_raman', ...
     'alpha_klett','alpha_raman','overlap');

Ulla_Overlap
ncorr(:,2)=overlap;
Raman_Manaus
Raman_beta_Manaus

figure(8);  set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8])
print(sprintf('klett%d.png', 2),'-dpng');
figure(9);  set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8])
print(sprintf('ramana%d.png',2),'-dpng');
figure(10); set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8])
print(sprintf('ramanb%d.png',2),'-dpng');
figure(91); set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8])
print(sprintf('overlap%d.png',2),'-dpng');
save(sprintf('step%d.mat',2),'alt','beta_klett','beta_raman', ...
     'alpha_klett','alpha_raman','overlap');

Ulla_Overlap
ncorr(:,3)=overlap;
Raman_Manaus
Raman_beta_Manaus

figure(8);  set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8])
print(sprintf('klett%d.png', 3),'-dpng');
figure(9);  set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8])
print(sprintf('ramana%d.png',3),'-dpng');
figure(10); set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8])
print(sprintf('ramanb%d.png',3),'-dpng');
figure(91); set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8])
print(sprintf('overlap%d.png',3),'-dpng');
save(sprintf('step%d.mat',3),'alt','beta_klett','beta_raman', ...
     'alpha_klett','alpha_raman','overlap');

clf;
plot(ncorr(:,1),alt(1:n)*1e-3,'b'); hold on; grid;
plot(ncorr(:,1).*ncorr(:,2),alt(1:n)*1e-3,'r');
plot(ncorr(:,1).*ncorr(:,2).*ncorr(:,3),alt(1:n)*1e-3,'g');
