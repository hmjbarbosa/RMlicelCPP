%% This routine opens the klett and raman output and compare the
% AOD from both. this is to prove that the LR used for the lidar
% paper #1 is ok and makes sense.

clear all
addpath('../matlab');
addpath('../sc');
load beta_klett_dry_overlapfinal_set2011_night.mat
%%%%%%%%%%%%
jdi=datenum(2011, 8, 30, 0, 0, 0);
jdf=jdi+7;

maxbin=floor(5000./7.5);
minh=1250.;
minbin=floor(minh/7.5);
nfile=length(totheads);
j=0;
for i=1:nfile
  if (jdi <= totheads(i).jdi & totheads(i).jdi <= jdf)
    j=j+1;
    time(j)=totheads(i).jdi;
    aodklett1(j)=trapz(klett_alpha_aero(minbin:maxbin,i))*7.5e-3; 
    aodraman1(j)=trapz(raman_alpha_aero(minbin:maxbin,i))*7.5e-3; 

    aodklett2(j)=trapz(klett_alpha_aero(minbin:maxbin,i))*7.5e-3...
        + minh*1e-3*klett_alpha_aero(minbin,i); 
    aodraman2(j)=trapz(raman_alpha_aero(minbin:maxbin,i))*7.5e-3...
        + minh*1e-3*klett_alpha_aero(minbin,i); 
  end
end
ngood=j;
%%%%%%%%%%%%%%
figure(1); clf
hold on; grid on;
scatter(aodklett2,aodraman2,[],time,'.');
set(gca,'fontsize',12)
X=(-0.1:0.05:0.7);
xlim([min(X) max(X)]);
ylim([min(X) max(X)]);

clev=[jdi:(jdf-jdi)/100.:jdf];
[cmap, clim]=cmapclim(clev);
colormap(cmap);
caxis(clim);
bar = colorbar;
datetick(bar,'y',7);
set(get(bar,'ylabel'),'String','day','fontsize',14);

[obj, gof, out] = fit(aodklett2',aodraman2','poly1');
pf=plot(obj,'r'); 
set(pf,'LineWidth',2);
plot(X,X,'--k','LineWidth',2);
legend('Data','y=p1*x+p2','y=x','Location','SouthEast');
M=confint(obj);

line{1}=['Linear model:'];
line{2}=['Raman = A * Elastic + B'];
line{3}=['Coefficients (95% conf. levels):'];
line{4}=[sprintf('A = %6.4f (%6.4f, %6.4f)',obj.p1,M(1,1),M(2,1))];
line{5}=[sprintf('B = %6.4f (%6.4f, %6.4f)',obj.p2,M(1,2),M(2,2))];

annotation('textbox',[0.15 0.7 0.34 0.19],'string',line,...
           'background','white','fontsize',12);

set(gca, ...
    'FontName'    , 'Helvetica', ...
    'FontSize'    , 12        , ...
    'Box'         , 'on'      , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'LineWidth'   , 1         );

xlabel('Elastic AOD','fontsize',14)
ylabel('Raman AOD','fontsize',14)

print -r300 -dpng aod_faraday.png

%