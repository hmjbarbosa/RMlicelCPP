% read_sonde_Manaus.m
%                                  01/07    BHeese 
%   Anpassung an RS80 Sonde        09/07    BHeese
%   Standardsonde justiert         11/07    BHeese
%   only Manaus sounding           06/12    BHeese
%
clear altitude alti
clear beta_ray beta_par beta_mol pr2_ray_sig
clear temp pres RH 
%
%which Sonde  (0 = sounding, 1 = standard atmosphere)
sonde = 0; 
%
% ------------------------------------------------------------
% Standard
% ------------------------------------------------------------
rbins = 3000;
if sonde == 1   
  site = 'Standart';
  radiofile = 'c:\Polis\radiosonden\Standarts\AlbertStd.txt'
  disp(['*** Einlesen der Radiosonde ' radiofile]);
  sondedata = csvread(radiofile, 2, 0);

  altitude = sondedata(:,1)*1e3;  % in km
  beta_ray(1,:) = sondedata(:,4);
  beta_ray(4,:) = sondedata(:,4)./(4.259e-4).*(2.2686e-3);
%  beta_ray(6,:) = sondedata(:,4)./(4.259e-4).*(2.582e-5);
%
  nlines=201;
end
% -----------------------------
% Radiosonde Wyoming Amazonas
% -----------------------------
%
if sonde == 0
  site = 'Amazonas';
  %radiofile=['d:\Radiosonden\Manaus\82965_080131_00.dat']
  %radiofile=['d:\Radiosonden\Manaus\83362_081028_00.dat']
  % this is cuiaba
  radiofile=['/media/work/data/EMBRAPA/lidar/Manaus/83362_081028_00.dat']
  %
  radios(1:6) = num2str(radiofile(29:34)); 
  radios(7:8) = num2str(radiofile(36:37)); 
  
  disp(['*** read radiosounding data ' radiofile]);
  fid=fopen(radiofile,'r'); 
  %
  for j=1:7
    eval(['headerline_sonde' num2str(j) '=fgetl(fid);']);
  end   
  %
  i=0;
  while ~feof(fid);
    sondedata = fgetl(fid);
    if ~isempty(sondedata)
      i=i+1;
      pres(i)=str2num(sondedata(1:7));  % P in hPa!
      altitude(i)=str2num(sondedata(8:14)); % in m 
      temp(i)=273.16 + str2num(sondedata(15:21)); % T in K
      %   RH(i)=str2num(sondedata(33:35)); % RH in percent
      % 
    else
      break    
    end 
  end % while
  %
end % wiche sonde 
% 
if sonde ~= 1  
  % number of altitides in radiosounding
  nlines = i;

  %*****************************************************
  %        calculate Beta  Rayleigh
  %*****************************************************
    beta_ray = zeros(3,nlines); 
   alpha_ray = zeros(3,nlines); 
    beta_mol = zeros(3,rbins); 
   alpha_mol = zeros(3,rbins); 
  LidarRatio = zeros(3,rbins);
 pr2_ray_sig = zeros(3,rbins);
%  
% ---------------------------------------------
%  calculate rayleight backscatter  , temp in K 
% ---------------------------------------------
  beta_ray(1,:) = (2.265e-3).*pres./temp;  % 355 nm !!! factor is in km!!!
  beta_ray(2,:) = (2.265e-3).*pres./temp*(355/387)^4.085;  % ? 387 nm
  beta_ray(3,:) = (4.259e-4).*pres./temp*(355/407)^4.085;  % ? 407 nm
%  beta_ray(4,:) = (4.259e-4).*pres./temp;  % 532 nm
%  beta_ray(5,:) = (4.259e-4).*pres./temp*(532/607)^4.085;  % 607 nm
%  beta_ray(6,:) = (2.582e-5).*pres./temp;  % 1064 nm
end
% 
% ------------------------------------------------------
%  Lidar Ratio for Rayleigh-scattering (8/3)pi = 8.377 sr
%  with Depol correction for the Cabannes line
% -------------------------------------------------------
%    
xlidar(1)=8.736; % 355 nm      S_c/(8/3)*pi = 1.0426
xlidar(2)=8.736; % ? 387 nm 
xlidar(3)=8.736; % ? 407 nm
%  xlidar(4)=8.712; % 532 nm                   = 1.0400
%  xlidar(5)=8.712; % ? 607 nm     
%  xlidar(6)=8.698; % 1064 nm                  = 1.0383

% ----------------------
%  Rayleigh Extinction
% ----------------------
   alpha_ray (1,:) = beta_ray(1,:).*xlidar(1);
   alpha_ray (2,:) = beta_ray(2,:).*xlidar(2);
   alpha_ray (3,:) = beta_ray(3,:).*xlidar(3);
% 
% -------------------------------
%  Lidar Ratio for particles
% -------------------------------
   LidarRatio(1,:) = 55;
   LidarRatio(2,:) = 55;
   LidarRatio(3,:) = 55;
%   
% -------------------------------------------
%  Interpolation to Lidar sampling altitudes
% -------------------------------------------
  beta_mol(1,:) = interp1(altitude(1:nlines),beta_ray(1,1:nlines),alt(1:rbins),'linear','extrap');
  beta_mol(2,:) = interp1(altitude(1:nlines),beta_ray(2,1:nlines),alt(1:rbins),'linear','extrap');
  beta_mol(3,:) = interp1(altitude(1:nlines),beta_ray(3,1:nlines),alt(1:rbins),'linear','extrap');
%  
% -----------------
%  Rayleigh Signal 
% -----------------
  alpha_mol(1,:) = beta_mol(1,:).*xlidar(1); 
  alpha_mol(2,:) = beta_mol(2,:).*xlidar(2); 
  alpha_mol(3,:) = beta_mol(3,:).*xlidar(3); 
% 
tau=0;
r_bin = (alt(2)-alt(1))*1e-3; % calculate pr2_ray_sig in km-1 
for j = 1:3
  %hmjb should we zero tau here, right???
%  tau=0;
  for i=1:rbins
    tau = tau + alpha_mol(j,i)*r_bin; 
    zet2(i)= (i*r_bin)*(i*r_bin);
    ray_signal(j,i)=(1./zet2(i)).*(beta_mol(j,i)*exp(-2.*tau)); 
    pr2_ray_sig(j,i)= ray_signal(j,i)*zet2(i); 
  end
end
%

figure(10)
%  set(gcf,'position',[50,100,600,800]); % units in pixels! *** 19 " ***
  set(gcf,'position',[50,100,400,600]); % units in pixels! *** Laptop ***
% 
if sonde ~= 1
title(['Radiosounding at ' site ' on ' radios(1:6) ' at ' radios(7:8) ' UTC'],'fontsize',[14]) 
end 
%
%  Plot
% -------
hl1=line(beta_mol(1,:),alt(1:rbins)*1e-3,'Color','b');
hl2=line(beta_mol(2,:),alt(1:rbins)*1e-3,'Color','c');
hl3=line(beta_mol(3,:),alt(1:rbins)*1e-3,'Color','r');
hold on
ax1 = gca;

xlimits = get(ax1,'XLim');
ylimits = get(ax1,'YLim');
xinc = (xlimits(2)-xlimits(1))/8;
yinc = (ylimits(2)-ylimits(1))/5;

set(ax1,'XTick',[xlimits(1):xinc:xlimits(2)],...
        'YTick',[ylimits(1):yinc:ylimits(2)]);
    
ylabel(ax1,'Height / km')
xlabel(ax1,'Lidar Beta / m-1')
grid on
    
legend('355')%, '387', '532', '607', '1064');


if sonde ~= 1
figure(11)
%  set(gcf,'position',[50,100,600,800]); % units in pixels! *** 19 " ***
  set(gcf,'position',[500,100,400,600]); % units in pixels! *** Laptop ***

title(['Radiosounding at ' site ' on ' radios(1:6) ' at' radios(7:8) ' UTC'],'fontsize',[14]) 
hl1=line(temp,altitude*1e-3,'Color','r');
hold on
ax1 = gca;
set(ax1,'XColor','r','YColor','k')

ax2 = axes('Position',get(ax1,'Position'),...
           'XAxisLocation','top',...
           'YAxisLocation','right',...
           'Color','none',...
           'XColor','b','YColor','k');
       
%hl2 = line(RH,altitude,'Color','b','Parent',ax2);

xlimits = get(ax1,'XLim');
ylimits = get(ax1,'YLim');
xinc = (xlimits(2)-xlimits(1))/5;
yinc = (ylimits(2)-ylimits(1))/5;

set(ax1,'XTick',[xlimits(1):xinc:xlimits(2)],...
        'YTick',[ylimits(1):yinc:ylimits(2)]);
    
ylabel(ax1,'Height / km')
xlabel(ax1,'Temperature / K')
xlabel(ax2,'rel Humidity / %')

grid on

% legend('Temperature', 'RH');
%
end 
%
disp('End of program: read_sonde_Manaus.m, Vers. 1.0 06/2012')