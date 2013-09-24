clear all;
%close all;
datain='/home/lidar_data/black/22h28_ZeroH2';
%datain='/home/lidar_data/black/22h12_ZeroH';
%[nfile, heads, chphy]=profile_read_dir(datain, 0, 0); 

[nfile, heads, chphy]=profile_read_dir(datain, 0, 0.004);

zh=[1:4000]*7.5e-3;

figure(1)
clf; hold on; grid on; box on;
plot(chphy(1).data(1:20,:),'b');
plot(chphy(2).data(1:20,:),'r');

figure(2)
gplot2(chphy(1).data(1:1000,:))


return
for i=1:5
  if (i<3)
    pmt=1;
  else
    if (i<5)
      pmt=2;
    else
      pmt=3;
    end
  end
  figure(i); clf; hold on; grid on; box on;
  if i==5
    set(gcf,'position',[0,0,900,275]); % units in pixels!
    set(gcf,'PaperUnits','points','PaperSize',[900 275],...
            'PaperPosition',[0 0 900 275])
    set(gca,'position',[0.05 0.1727 0.9 0.7273])
    xlabel('Range (km)');
  else
    set(gcf,'position',[0,0,900,250]); % units in pixels!
    set(gcf,'PaperUnits','points','PaperSize',[900 250],...
            'PaperPosition',[0 0 900 250])
    set(gca,'position',[0.05 0.1 0.9 0.8])
    set(gca,'xticklabel',[]);
  end
  if (heads(1).ch(i).photons)
    plot(zh,chphy(i).data(1:4000,:)/20.*heads(1).ch(i).nshoots);
    ylabel('Counts');
    title(['PMT #' num2str(pmt) ' PC mode']);
    ylim([0 1.1]);
  else
    plot(zh,chphy(i).data(1:4000,:));
    ylabel('mV');
    title(['PMT #' num2str(pmt) ' Analog mode, Range= ' ...
           num2str(heads(1).ch(i).discr*1e3) ' mV']);
  end
  
%  print(['zeroh_black_pmt_' num2str(i) '.png'],'-dpng')
end
