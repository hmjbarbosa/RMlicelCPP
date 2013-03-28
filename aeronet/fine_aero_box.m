function []=fine_aero_box(jd, aot, title, xtic, xticl)
set(gcf,'position',[300,300,800,300]); % units in pixels!
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 3])
sub=subplot('position',[0.08 0.05 0.73 0.85]);
XX(1:size(aot,1),1:12)=NaN;
for i=1:size(aot,1)
  data=datevec(jd(i));
  XX(i,data(2))=aot(i,1);
end
boxplot(XX);
pos=get(gca,'position');
stats=['mean: ' sprintf('%4.2f',nanmean(aot)) char(10) ...
       'median: ' sprintf('%4.2f',nanmedian(aot)) char(10) ...
       'stdev: ' sprintf('%4.2f',nanstd(aot))];
annotation('textbox', [pos(1), pos(2)+pos(4)-0.18, 0.12, 0.18], ...
           'string', stats, 'backgroundcolor','w')
ylim([0 1]); 
%xlabel('Months','fontsize',12)  
ylabel(title,'fontsize',12)
grid on;
sub=subplot('position',[0.83 pos(2)+0.005 0.15 pos(4)-0.005]);
bins=[0:0.025:1];
counts=histc(aot(:,1),bins);
b=barh(bins+bins(2)/2,counts/sum(counts),1,'w'); 
set(b,'facecolor',[0.7 0.7 0.7]);
ylim([0 1]); %xlabel('freq');
xlim([min(xtic) max(xtic)]);
set(gca,'XTick',xtic);
set(gca,'xticklabel',xticl);
set(gca,'yticklabel','');
grid on;
%