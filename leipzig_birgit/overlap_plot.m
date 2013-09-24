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
  n=800; % 6km
  alt=[1:n]*7.5*1e-3;
  overlap=mysmooth(final.over(1:n,mask),4,4);

  figure(1); clf;
  set(gca,'position',[0.1,0.075,0.8,0.9]); % units in pixels!
  set(gcf,'position',[0,0,400,700]); % units in pixels!
  set(gcf,'PaperUnits','inches','PaperSize',[4,7],'PaperPosition',[0 0 4 7])
  hold on; grid on;
  plot(overlap,alt); 
  plot(nanmean(overlap,2),alt,'g'  ,'linewidth',3);
  xlabel('Overlap function'); 
  xlim([0 1.2]);
  ylabel('Range (km)');
  text(0.05,5.8,tag{i},'fontsize',16);
  print(['overlap_' tag{i} '.png'],'-dpng');

  %=======================================================================
  % Figure 2 - Correction to the extinction from the overlap
  % function, and the overlap on the same plot
  %=======================================================================
  n=400;
  alt=[1:n]'*7.5*1e-3;
  tmp=final.over(1:n,mask);
  % local linear fit at each point to determine the slope 
  [fval, a, b]=runfit2(log(tmp),alt,6,6);
  % Holger, Phd. correction for Extinction coeff from overlap
  % function, assuming ANGSTRON=1.2
  correction=a/(1+(355./387.)^1.2)*1e3; % in Mm^-1

  figure(2); clf;
  set(gca,'position',[0.1,0.1,0.8,0.8]); % units in pixels!
  set(gcf,'position',[400,0,400,500]); % units in pixels!
  set(gcf,'PaperUnits','inches','PaperSize',[4,5],'PaperPosition',[0 0 4 5])
  hold on; grid on;
  % all corrections and their mean in colors
  plot(correction(30:end,:),alt(30:end)); 
  plot(mean(correction(30:end,:),2),alt(30:end),'g','linewidth',2); 
  xlabel('Extinction coeff. increment [Mm-1]'); 
  xlim([-1e3 15e3]);
  ylabel('Range (km)');
  set(gca,'xtick',[0:3e3:15e3]);
  ax1=gca;
  ax2=axes('position',get(ax1,'position'),'xaxislocation','top', ...
	   'color','none','xcolor','k');
  linkaxes([ax1 ax2],'y')
  hold on;
  % overlap function in black
  plot(nanmean(tmp,2),alt,'k','linewidth',2,'parent',ax2);
  plot(nanmean(tmp,2)+1*nanstd(tmp,0,2),alt,'k--','parent',ax2);
  plot(nanmean(tmp,2)-1*nanstd(tmp,0,2),alt,'k--','parent',ax2);
  xlim([-1/15 1]);
  text(0.05,2.8,tag{i},'fontsize',16);
  xlabel('Overlap function')
  print(['overlap_alpha_correction_' tag{i} '.png'],'-dpng');

  %=======================================================================
  % Figure 3 - standard deviation of the correction to the extinction
  % from the overlap function, i.e., the unkown error in the
  % extinction coefficient, and the overlap on the same plot
  % In this case, narrow and wide times are shown in the same plot.
  %=======================================================================
  figure(3); 
  if (i==1) 
    clf;
    set(gca,'position',[0.1,0.1,0.8,0.8]); % units in pixels!
    set(gcf,'position',[800,0,400,500]); % units in pixels!
    set(gcf,'PaperUnits','inches','PaperSize',[4,5],'PaperPosition',[0 0 4 5])
    corerror=std(correction,0,2);
    plot(corerror(55:end),alt(55:end),'b','linewidth',2); 
    hold on; grid on;
    xlabel('Extinction coeff. error [Mm-1]');
    ylabel('Range (km)');
    xlim([-50 800]);
    set(gca,'xtick',[0:160:800]);
    ax3=gca;
    ax4=axes('position',get(ax3,'position'),...
	     'xaxislocation','top',...
	     'color','none','xcolor','k');
    linkaxes([ax3 ax4],'y')
    hold on;
    plot(nanmean(tmp,2),alt,'b','linewidth',1,'parent',ax4);
    plot(nanmean(tmp,2)+1*nanstd(tmp,0,2),alt,'b--','parent',ax4);
    plot(nanmean(tmp,2)-1*nanstd(tmp,0,2),alt,'b--','parent',ax4);
    xlim([-1/16 1]);
    xlabel('Overlap function')
  else
    plot(std(correction(42:end,:),0,2),alt(42:end),'r','parent',ax3,'linewidth',2); 
    plot(nanmean(tmp,2),alt,'r','linewidth',1,'parent',ax4);
    plot(nanmean(tmp,2)+1*nanstd(tmp,0,2),alt,'r--','parent',ax4);
    plot(nanmean(tmp,2)-1*nanstd(tmp,0,2),alt,'r--','parent',ax4);
    xlim([-1/16 1]);
    print(['overlap_alpha_error.png'],'-dpng');
  end

  %=======================================================================
  % save a MAT file with the correction information
  %=======================================================================
  overlap(801:2000,:)=1.0;
  overmean=mean(overlap,2);
  overerror=std(overlap,0,2);
  correction(401:2000,:)=0.0;
  cormean=mean(correction,2);
  corerror(401:2000)=mean(corerror(300:400));
  
  save(['overlap_' tag{i} '.mat'],'overlap','overmean', ...
       'overerror','correction', 'cormean', 'corerror' );

end


%