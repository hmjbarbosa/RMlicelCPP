% read_sonde_Manaus.m
%                                  01/07    BHeese 
%   Anpassung an RS80 Sonde        09/07    BHeese
%   Standardsonde justiert         11/07    BHeese
%   only Manaus sounding           06/12    BHeese
%
clear sonde site radiofile sondedata
clear temp pres RH altitude r_bin rbins
clear beta_ray xlidar alpha_ray LidarRatio 
clear beta_mol alpha_mol tau zet2 ray_signal pr2_ray_sig 
%
%which Sonde  (0 = sounding, 1 = standard atmosphere)
sonde = 0; 
%
% ------------------------------------------------------------
% Standard
% ------------------------------------------------------------
if sonde == 1   
  site = 'Standart';
  radiofile = 'c:\Polis\radiosonden\Standarts\AlbertStd.txt'
  disp(['*** Einlesen der Radiosonde ' radiofile]);
  sondedata = csvread(radiofile, 2, 0);
  
  altitude = sondedata(:,1)*1e3;  % in km
  beta_ray(1,:) = sondedata(:,4);
  beta_ray(4,:) = sondedata(:,4)./(4.259e-4).*(2.2686e-3);
  %beta_ray(6,:) = sondedata(:,4)./(4.259e-4).*(2.582e-5);
  %
  nlines=201;
end
% -----------------------------
% Radiosonde Wyoming Amazonas
% -----------------------------
%
if sonde == 0
  site = 'Amazonas';
  % this is cuiaba
  %radiofile=['./Manaus/83362_081028_00.dat']
  % manaus, 2011 sep 01 00z
  radiofile=['./Manaus/82332_110901_00.dat']
  %
  radios(1:6) = num2str(radiofile(16:21)); 
  radios(7:8) = num2str(radiofile(23:24)); 
  
  disp(['*** read radiosounding data ' radiofile]);
  fid=fopen(radiofile,'r'); 
  % read the headers
  for j=1:7
    eval(['headerline_sonde' num2str(j) '=fgetl(fid);']);
  end   
  % read sounding data
  % cannot read as a table because wyoming files have empty space
  % for missing data
  i=0;
  while ~feof(fid);
    sondedata = fgetl(fid);
    if ~isempty(sondedata)
      i=i+1;
      pres(i)=str2num(sondedata(1:7));  % P in hPa!
      altitude(i)=str2num(sondedata(8:14)); % in m 
      temp(i)=273.16 + str2num(sondedata(15:21)); % T in K
      if ~strcmp(sondedata(31:35),'     ')
        RH(i)=str2num(sondedata(31:35)); % RH in percent
      else
        RH(i)=0.;
      end
    else
      break    
    end 
  end 
  % number of altitides in radiosounding
  nlines = i;
  fclose(fid);
end % which sonde 
% 

% bin height in km
r_bin=(alt(2)-alt(1))*1e-3; 

% highest level in souding, in units of lidar levels
rbins = 4000;%hmjb estava 3000
%rbins=floor(altitude(nlines)*1e-3/r_bin);

if sonde ~= 1  

  %*****************************************************
  %        calculate Beta  Rayleigh
  %*****************************************************
%  beta_ray    = zeros(3,nlines); 
%  alpha_ray   = zeros(3,nlines); 
%  beta_mol    = zeros(3,rbins); 
%  alpha_mol   = zeros(3,rbins); 
%  LidarRatio  = zeros(3,rbins);
%  pr2_ray_sig = zeros(3,rbins);

  % --------------------------------------------------------
  %  calculate rayleight backscatter, temp in K, pres in hPa
  % --------------------------------------------------------
  % P = rho*R*T, R=287.05 J/kg/K
  % rho = P/T/R = 3.4837e-3 * P / T  
  % 0.2um < lambda < 0.5um
  A=3.01577e-28; % 
  B=3.55212;
  C=1.35579;
  D=0.11563;
  Ts=288.15; % K
  Ps=1013.25 % hPa
  Ns=2.54743e19; % cm^-3

  lambda=0.355; % microns
  sigmaS=A*(lambda)^(-(B+C*lambda+D/lambda))/(8*pi/3); % cm^2
  betaS=Ns*sigmaS*10^5; % para ter em km^-1 ao inves de cm^-1
  beta_ray(1,:) = betaS.*(pres./temp)*Ts/Ps;  % 355 nm !!! factor is in km!!!

  lambda=0.387; % microns
  sigmaS=A*(lambda)^(-(B+C*lambda+D/lambda))/(8*pi/3); % cm^2
  betaS=Ns*sigmaS*10^5; % para ter em km^-1 ao inves de cm^-1
  beta_ray(2,:) = betaS.*(pres./temp)*Ts/Ps;  % 387 nm

  lambda=0.408; % microns
  sigmaS=A*(lambda)^(-(B+C*lambda+D/lambda))/(8*pi/3); % cm^2
  betaS=Ns*sigmaS*10^5; % para ter em km^-1 ao inves de cm^-1
  beta_ray(3,:) = betaS.*(pres./temp)*Ts/Ps;  % 407 nm
%hmjb  beta_ray(1,:) = (2.265e-3).*pres./temp;  % 355 nm !!! factor is in km!!!
%hmjb  beta_ray(2,:) = (2.265e-3).*pres./temp*(355/387)^4.085;  % 387 nm
%hmjb  beta_ray(3,:) = (4.259e-4).*pres./temp*(355/407)^4.085;  % 407 nm
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
xlidar(2)=8.736; % 387 nm 
xlidar(3)=8.736; % 407 nm
%xlidar(4)=8.712; % 532 nm                   = 1.0400
%xlidar(5)=8.712; % 607 nm     
%xlidar(6)=8.698; % 1064 nm                  = 1.0383
%
% ----------------------
%  Rayleigh Extinction
% ----------------------
alpha_ray(1,:) = beta_ray(1,:).*xlidar(1);
alpha_ray(2,:) = beta_ray(2,:).*xlidar(2);
alpha_ray(3,:) = beta_ray(3,:).*xlidar(3);
% 
% -------------------------------
%  Lidar Ratio for particles
% -------------------------------
LidarRatio(1,1:rbins) = 55;
LidarRatio(2,1:rbins) = 55;
LidarRatio(3,1:rbins) = 55;
%   
% -------------------------------------------
%  Interpolation to Lidar sampling altitudes
% -------------------------------------------
scale(1,:) = interp1(altitude(1:nlines),log(beta_ray(1,1:nlines)),alt,'linear','extrap');
scale(2,:) = interp1(altitude(1:nlines),log(beta_ray(2,1:nlines)),alt,'linear','extrap');
scale(3,:) = interp1(altitude(1:nlines),log(beta_ray(3,1:nlines)),alt,'linear','extrap');
beta_mol(1,:) = exp(scale(1,:));
beta_mol(2,:) = exp(scale(2,:));
beta_mol(3,:) = exp(scale(3,:));
%beta_mol(1,:) = interp1(altitude(1:nlines),beta_ray(1,1:nlines),alt,'linear','extrap');
%beta_mol(2,:) = interp1(altitude(1:nlines),beta_ray(2,1:nlines),alt,'linear','extrap');
%beta_mol(3,:) = interp1(altitude(1:nlines),beta_ray(3,1:nlines),alt,'linear','extrap');
% interpolation can lead to negative values
beta_mol(beta_mol<=0) = NaN;
%  
% -----------------
%  Rayleigh Signal 
% -----------------
alpha_mol(1,:) = beta_mol(1,:).*xlidar(1); 
alpha_mol(2,:) = beta_mol(2,:).*xlidar(2); 
alpha_mol(3,:) = beta_mol(3,:).*xlidar(3); 
% 
for j = 1:3
  for i=1:rbins
    if i==1
      tau(j,i) = alpha_mol(j,i)*r_bin; 
    else
      tau(j,i) = tau(j,i-1)+alpha_mol(j,i)*r_bin; 
    end
  end
end

for j = 1:3
  %hmjb we should zero tau here, right???
  %tau=0;
  for i=1:rbins
    %tau = tau + alpha_mol(j,i)*r_bin; 
    %hmjb zet2(i)= (i*r_bin)*(i*r_bin);
    %hmjb ray_signal(j,i)=(1./zet2(i)).*(beta_mol(j,i)*exp(-2.*tau)); 
    % calculate pr2_ray_sig in km-1 
    %hmjb pr2_ray_sig(j,i)= ray_signal(j,i)*zet2(i); 
    pr2_ray_sig(j,i)=beta_mol(j,i)*exp(-tau(j,i)-tau(1,i));
  end
end
%

%
%  Plot
% -------
figure(4)
set(gcf,'position',[0,100,400,600]); % units in pixels!
plot(beta_mol(1,:),alt(:)*1e-3,'b'); 
hold on
plot(beta_mol(2,:),alt(:)*1e-3,'c');
plot(beta_mol(3,:),alt(:)*1e-3,'r'); 

plot(beta_ray(1,:),altitude(:)*1e-3,'bo'); 
plot(beta_ray(2,:),altitude(:)*1e-3,'co');
plot(beta_ray(3,:),altitude(:)*1e-3,'ro'); 
if sonde ~= 1
  title(['Radiosounding at ' site ' on ' radios(1:6) ' at ' radios(7:8) ' UTC'],'fontsize',[14]) 
end 
legend('355', '387', '408');
ylabel('Height / km')
xlabel('Lidar Beta / m-1')
grid on
hold off

% -------
figure(5)
set(gcf,'position',[200,100,400,600]); % units in pixels!
%hl1=line(temp,altitude*1e-3,'Color','r');
plot(temp,altitude*1e-3,'Color','r');
if sonde ~= 1
  title(['Radiosounding at ' site ' on ' radios(1:6) ' at ' radios(7:8) ' UTC'],'fontsize',[14]) 
end
hold on
ax1 = gca;
set(ax1,'XColor','r','YColor','k','XAxisLocation','bottom')
ylabel(ax1,'Height / km')
xlabel(ax1,'Temperature / K')
xlimits = get(ax1,'XLim')
ylimits = get(ax1,'YLim');
xinc = (xlimits(2)-xlimits(1))/5;
yinc = (ylimits(2)-ylimits(1))/5;

set(ax1,'XTick',[xlimits(1):xinc:xlimits(2)],...
        'YTick',[ylimits(1):yinc:ylimits(2)]);

ax2 = axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
           'YAxisLocation','right','Color','none',...
           'XColor','b','YColor','k');
xlabel(ax2,'rel Humidity / %')

line(RH,altitude,'Color','b','Parent',ax2);
grid on
hold off
%
disp('End of program: read_sonde_Manaus.m, Vers. 1.0 06/2012')
%