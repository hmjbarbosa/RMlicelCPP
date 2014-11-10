h=figure(1);
temp=get(gcf,'position'); temp(3)=1280; temp(4)=720;
set(gcf,'position',temp); % units in pixels!
set(gcf,'PaperUnits','points','PaperSize',[1280 720],...
            'PaperPosition',[0 0 1280 720])
set(h,'visible','off')

set(gcf,'defaultAxesFontSize',13);
set(gcf,'defaultAxesFontName','Helvetica');
set(gcf,'defaultAxesLineWidth',1.2);
set(gcf,'defaultAxesXColor',[.2 .2 .2]);
set(gcf,'defaultAxesYColor',[.2 .2 .2]);
set(gcf,'defaultAxesBox','on');
set(gcf,'defaultAxesXGrid','on')
set(gcf,'defaultAxesYGrid','on')
%

hmax=600;
alt=(1:hmax)*7.5e-3;
set(gcf,'defaultAxesYLim',[0. alt(hmax)])

for idx=6000:6:ntimes%6000
  tic; idx 
  
  % em cima (embrapa)
  subplot('position',[0.05 0.55 0.65 0.4])
  gplot2(sort_beta(1:hmax,idx:idx+287)*1e6, [0:0.05:6],times(idx:idx+287),alt)
  datetick('x',15,'keeplimits'); 
  title('Embrapa (T0)');
  ylabel('Altitude (km)'); 
  
  subplot('position',[0.75 0.55 0.20 0.4])
  plot(sort_beta(1:hmax,idx+287)*1e6,alt)
  title(datestr(times(idx+287),26));
  xlim([-1 6]); %ylim([0 7]);
  
  % em baixo (tiwa)
  subplot('position',[0.05 0.05 0.65 0.4])
  gplot2(sort_beta2(1:hmax,idx:idx+287)*1e6, [0:0.05:6],times(idx:idx+287),alt);
  title('Tiwa (T2)');
  datetick('x',15,'keeplimits'); 
  ylabel('Altitude (km)');
  
  subplot('position',[0.75 0.05 0.20 0.4])
  plot(sort_beta2(1:hmax,idx+287)*1e6,alt)
  title(datestr(times(idx+287),15));
  xlim([-1 6]); %ylim([0 7]);

  print([datestr(times(idx),30) '.jpg'],'-djpeg'); 

  toc
end
%fim


%fim