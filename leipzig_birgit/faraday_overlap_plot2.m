clear all
addpath ../matlab
addpath ../sc

%load list_overlap_sel15km_top14km.mat
%load list_overlap_sel14km_top13km.mat
%load list_overlap_sel13km_top12km.mat
load list_overlap_sel12km_top11km.mat
%load list_overlap_sel11km_top10km.mat
%load list_overlap_sel10km_top09km.mat

% separate the periods with small and large field stops
times(1,:) = final.jdi<datenum('1-Aug-12');
tag{1} = 'narrow'; 
times(2,:) = final.jdi>datenum('1-Aug-12');
tag{2} = 'wide'; 

for i=1:2

  % mask to separate the times we will use for the final overlap
  mask=times(i,:) & ...
       ~final.problem & ...
       ~final.hascloud & ...
       final.maxglue>1.5e3 & ...
       final.beta_raman(134,:) > 1e-3 & ...
       final.bg(:,2)'<200;
  disp(['Overlap N=' num2str(sum(mask))]);

  %=======================================================================
  % Figure 1 - all overlap curves and a thick line with the mean
  %=======================================================================
  n=600
  alt=[1:n]'*7.5*1e-3;
  overlap=mysmooth(final.over(1:n,mask),4,4);

  %=======================================================================
  % Figure 2 - Correction to the extinction from the overlap
  % function, and the overlap on the same plot
  %=======================================================================
%  n=400;
%  alt=[1:n]'*7.5*1e-3;
  tmp=final.over(1:n,mask);
  % local linear fit at each point to determine the slope 
  [fval, a, b]=runfit2(log(tmp),alt,6,6);
  % Holger, Phd. correction for Extinction coeff from overlap
  % function, assuming ANGSTRON=1.2
  correction=a/(1+(355./387.)^1.2)*1e3; % in Mm^-1

  figure(2); clf;
  set(gca,'position',[0.15,0.13,0.75,0.75]); % units in pixels!
%  set(gcf, 'PaperPositionMode', 'auto');
  set(gcf,'position',[400,0,500,625]); % units in pixels!
  set(gcf,'PaperUnits','inches','PaperSize',[5,6.25],'PaperPosition',[0 0 5 6.25])
  hold on; grid on;
  % all corrections and their mean in colors
  plot(correction(30:end,:),alt(30:end)); 
  plot(mean(correction(30:end,:),2),alt(30:end),'g','linewidth',2); 
  xlabel('Extinction coeff. increment [Mm^{-1}]'); 
  xlim([-1e3 12e3]);
  ylabel('Range [km]');
  set(gca,'xtick',[0:2e3:12e3]);
  ax1=gca;
  ax2=axes('position',get(ax1,'position'),'xaxislocation','top', ...
	   'color','none','xcolor','k');
  linkaxes([ax1 ax2],'y')
  hold on;

  % overlap function in black
  plot(overlap,alt); 
  plot(nanmean(overlap,2),alt,'k','linewidth',3);
  xlim([-0.1 1.2]);
  text(0.05,4.3,tag{i},'fontsize',16);
  xlabel('Overlap function')
  prettify(ax1); grid on;
  prettify(ax2); grid on;
  print(['overlap_alpha_correction_' tag{i} '2.png'],'-dpng');

end


%