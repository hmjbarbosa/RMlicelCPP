clear all

%load list_overlap_sel15km_top14km.mat
%load list_overlap_sel14km_top13km.mat
%load list_overlap_sel13km_top12km.mat
%load list_overlap_sel12km_top11km.mat
load list_overlap_sel11km_top10km.mat
%load list_overlap_sel10km_top09km.mat

figure(1); clf;
mask=final.jdi<datenum('1-Aug-12') & ~final.problem & ~final.hascloud & ...
     final.maxglue>1.5e3 & final.beta_raman(134,:) > 1e-3;

n=750;
alt=[1:n];%*7.5*1e-3;
tmp=final.over(1:n,mask);
%plot(alt,tmp,'color',[0.71 0.71 0.71]); hold on; grid on;
plot(alt,tmp); hold on; grid on;
plot(alt,mean(tmp,2),               'b'  ,'linewidth',3);
plot(alt,mean(tmp,2)+2*std(tmp,0,2),'b--','linewidth',3);
plot(alt,mean(tmp,2)-2*std(tmp,0,2),'b--','linewidth',3);

%plot(alt,quantile(tmp,0.50,2),'b'  ,'linewidth',3);
%plot(alt,quantile(tmp,0.05,2),'b--','linewidth',3);
%plot(alt,quantile(tmp,0.95,2),'b--','linewidth',3);

xlabel('Altitude (km)');
title(['Overlap N=' num2str(sum(mask))]);
ylim([0 1.05]);

%