clear all
%alt=(1:600)*15.+7.5;
tmp(1:600,1:6)=NaN;

load('step0.mat');
tmp2(:,4)=beta_klett;
tmp3(:,4)=beta_raman;
tmp4(:,4)=alpha_raman;

load('step1.mat');
tmp(1:numel(overlap),1)=overlap;
tmp2(:,1)=beta_klett;
tmp3(:,1)=beta_raman;
tmp4(:,1)=alpha_raman;

load('step2.mat');
tmp(1:numel(overlap),2)=overlap;
tmp2(:,2)=beta_klett;
tmp3(:,2)=beta_raman;
tmp4(:,2)=alpha_raman;

load('step3.mat');
tmp(1:numel(overlap),3)=overlap;
tmp2(:,3)=beta_klett;
tmp3(:,3)=beta_raman;
tmp4(:,3)=alpha_raman;
%
n=600;
%
figure(200); clf
plot(tmp(1:n,1),alt(1:n)*1e-3,'-b','linewidth',2); hold on; grid
plot(tmp(1:n,2),alt(1:n)*1e-3,'-r','linewidth',2)
plot(tmp(1:n,3),alt(1:n)*1e-3,'-g','linewidth',2)
%plot(tmp(1:n,4),alt(1:n)*1e-3,'-c','linewidth',2)
%plot(tmp(1:n,5),alt(1:n)*1e-3,'-m','linewidth',2)
%legend('9km','4.5km','2.3km','1.5km','0.75km','location','northwest')
%
figure(201); clf
plot(tmp2(1:n,4),alt(1:n)*1e-3,'-k','linewidth',2); hold on; grid
plot(tmp2(1:n,1),alt(1:n)*1e-3,'-b','linewidth',1)
plot(tmp2(1:n,2),alt(1:n)*1e-3,'-r','linewidth',1)
plot(tmp2(1:n,3),alt(1:n)*1e-3,'-g','linewidth',1)
%plot(tmp2(1:n,4),alt(1:n)*1e-3,'-c','linewidth',1)
%plot(tmp2(1:n,5),alt(1:n)*1e-3,'-m','linewidth',1)
xlim([0 15e-3]); xlabel('KLETT Backscatter [km^{-1} sr^{-1}]');
%legend('ref','9km','4.5km','2.3km','1.5km','0.75km','location','northeast')

figure(202); clf
plot(tmp3(1:n,4),alt(1:n)*1e-3,'-k','linewidth',2); hold on; grid
plot(tmp3(1:n,1),alt(1:n)*1e-3,'-b','linewidth',1)
plot(tmp3(1:n,2),alt(1:n)*1e-3,'-r','linewidth',1)
plot(tmp3(1:n,3),alt(1:n)*1e-3,'-g','linewidth',1)
%plot(tmp3(1:n,4),alt(1:n)*1e-3,'-c','linewidth',1)
%plot(tmp3(1:n,5),alt(1:n)*1e-3,'-m','linewidth',1)
xlim([0 15e-3]); xlabel('RAMAN Backscatter [km^{-1} sr^{-1}]');
%legend('ref','9km','4.5km','2.3km','1.5km','0.75km','location','northeast')
%
figure(203); clf
plot(mysmooth(tmp4(1:n,4),0,25),alt(1:n)*1e-3,'-k','linewidth',2); hold on; grid
plot(mysmooth(tmp4(1:n,1),0,25),alt(1:n)*1e-3,'-b','linewidth',1)
plot(mysmooth(tmp4(1:n,2),0,25),alt(1:n)*1e-3,'-r','linewidth',1)
plot(mysmooth(tmp4(1:n,3),0,25),alt(1:n)*1e-3,'-g','linewidth',1)
%plot(mysmooth(tmp4(1:n,4),0,25),alt(1:n)*1e-3,'-c','linewidth',1)
%plot(mysmooth(tmp4(1:n,5),0,25),alt(1:n)*1e-3,'-m','linewidth',1)
title('alpha Raman')
xlim([-0.05 0.4]); xlabel('RAMAN Extinction [km^{-1}]');
%legend('ref','9km','4.5km','2.3km','1.5km','0.75km','location','northeast')

%
