clear all
close all
%
list=dirpath('tiwa_overlap/','tiwa*mat');
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

overlap(:,344)=nan;
overlap(:,345)=nan;
overlap(:,351)=nan;
overlap(:,448)=nan;
overlap(:,524)=nan;
overlap(:,621)=nan;
overlap(:,718)=nan;
overlap(:,1016)=nan;
overlap(:,1119)=nan;

clf; !
for i=1:no
  if any(overlap(:,i)>2) | overlap(200,i)<0.4 | overlap(100,i)>0.94 ...
        | overlap(100,i)<0.5 | overlap(71,i)<0.3
    overlap(:,i)=nan;
  else
    %if any(~isnan(overlap(:,i)))
    %  i
    %  plot(overlap(1:600,i))
    %  ginput(1)
    %end
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
title('IPEN Mobile Lidar')
prettify(gca)
grid
xlim([0 1.2])

meanover(601:4000,1)=1;

save('overlap_tiwa.mat','meanover','stdover','overlap');

%
