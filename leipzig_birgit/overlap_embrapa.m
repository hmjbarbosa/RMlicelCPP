clear all
close all
%
list=dirpath('embrapa_overlap/','embrapa*mat');
nf=numel(list);

for i=1:nf
  load(list{i})
  if i==1
    overlap=save_overlap;
  else
    overlap=[overlap save_overlap];
  end
end

no=size(overlap,2);
grid

overlap(:,130)=nan;
overlap(:,261)=nan;
overlap(:,269:270)=nan;
overlap(:,388:389)=nan;
overlap(:,392:397)=nan;
overlap(:,404)=nan;
overlap(:,458)=nan;
overlap(:,466:467)=nan;
overlap(:,474)=nan;
overlap(:,529)=nan;

clf; !
for i=1:no
  if any(overlap(:,i)>1.2) | overlap(200,i)<0.75  ...
        | overlap(100,i)<0.5 | overlap(60,i)>0.5
    overlap(:,i)=nan;
  else
%    if any(~isnan(overlap(:,i)))
%      i
%      plot(overlap(1:600,i))
%      ginput(1)
%    end
  end
end

alt=(1:600)*7.5;
plot(overlap(1:600,:),alt)
hold on

meanover=nanmean(overlap(1:600,:),2);
stdover=nanstd(overlap(1:600,:),0,2);
plot(meanover,alt,'k','linewidth',2)
plot(meanover+stdover,alt,'--k','linewidth',2)
plot(meanover-stdover,alt,'--k','linewidth',2)
xlabel('overlap')
ylabel('range (m)')
title('EMBRAPA Lidar')
prettify(gca)
grid
xlim([0 1.2])

meanover(601:4000,1)=1;

save('overlap_embrapa.mat','meanover','stdover','overlap');

%
