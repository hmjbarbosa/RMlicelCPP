% read_sonde_Manaus.m
%                                  01/07    BHeese 
%   Anpassung an RS80 Sonde        09/07    BHeese
%   Standardsonde justiert         11/07    BHeese
%   only Manaus sounding           06/12    BHeese
%   cleaning and commeting         01/13    HBarbosa
%
clear sonde site radiofile sondedata scale
clear temp pres RH altitude rbins
clear beta_ray xlidar alpha_ray LidarRatio 
clear beta_mol alpha_mol tau zet2 ray_signal pr2_ray_sig 
% -----------------------------
% Radiosonde Wyoming Amazonas
% -----------------------------
%
site = 'Amazonas';
radiofile=['./Manaus/82332_110901_00.dat']

disp(['*** read radiosounding data ' radiofile]);
% cannot read as a table because wyoming files have empty space for
% missing data. usually happens at higher altitudes. the reading
% mechanism, in this case, must rely on the constant width of the
% fields. 
%sonde=importdata(radiofile, ' ', 1);
%---
fid=fopen(radiofile,'r'); 
% read the headers
for j=1:7
  eval(['headerline_sonde' num2str(j) '=fgetl(fid);']);
end   
% read sounding data
i=0;
while ~feof(fid);
  sondedata = fgetl(fid);
  if ~isempty(sondedata)
    i=i+1;
    pres(i)=str2num(sondedata(1:7));  % P in hPa!
    altitude(i)=str2num(sondedata(8:14)); % in m 
    temp(i)=273.16 + str2num(sondedata(15:21)); % T in K
% P = rho*R*T, R=287.05 J/kg/K
% 100 corrects hPa to Pa, hence rho in kg/m3
    rho(i)=100*pres(i)./temp(i)/287.05;
    % number density of air [#/m3]
    Nair(i)=100*pres(i)./temp(i)/1.3806503e-23;
    % number density of nitrogen [#/m3]
    Nn2(i)=0.7808*Nair(i);
    if ~strcmp(sondedata(31:35),'     ')
      RH(i)=str2num(sondedata(31:35)); % RH in percent
    else
      RH(i)=0.;
    end
  else
    break    
  end 
end 
fclose(fid);
%---
% number of levels in sounding
nlines=max(size(pres));

% highest level in souding, in units of lidar levels
rbins=floor(altitude(nlines)*1e-3/r_bin);
% or if you want to extrapolate the sounding data, just set to the
% number of bins in the lidar data
%rbins = size(channel,1);

%*****************************************************
%        calculate Beta  Rayleigh
%*****************************************************

% --------------------------------------------------------
%  calculate rayleight backscatter, temp in K, pres in hPa
% --------------------------------------------------------
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
betaS=Ns*sigmaS*1e5; % for km^-1 intead of cm^-1
beta_ray(1,:) = betaS.*(pres./temp)*Ts/Ps;  % 355 nm !!! factor is in km!!!

lambda=0.387; % microns
sigmaS=A*(lambda)^(-(B+C*lambda+D/lambda))/(8*pi/3); % cm^2
betaS=Ns*sigmaS*1e5; % for km^-1 intead of cm^-1
beta_ray(2,:) = betaS.*(pres./temp)*Ts/Ps;  % 387 nm

lambda=0.408; % microns
sigmaS=A*(lambda)^(-(B+C*lambda+D/lambda))/(8*pi/3); % cm^2
betaS=Ns*sigmaS*1e5; % for km^-1 intead of cm^-1
beta_ray(3,:) = betaS.*(pres./temp)*Ts/Ps;  % 407 nm

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

% -------------------------------
%  Lidar Ratio for particles
% -------------------------------
LidarRatio(1,1:rbins) = 55;
LidarRatio(2,1:rbins) = 55;
LidarRatio(3,1:rbins) = 55;

% -------------------------------------------
%  Interpolation to Lidar sampling altitudes
% -------------------------------------------
% hmjb - beta_ray decays exponentially towards zero with increasing
% height. Extrapolating it above the highest level in the sounding can
% lead to negative (unphysical) values. Hence interpolation is done in
% log() and then take the exp() of the result.
scale(1,:) = interp1(altitude(1:nlines),log(beta_ray(1,1:nlines)),alt(1:rbins),'linear','extrap');
scale(2,:) = interp1(altitude(1:nlines),log(beta_ray(2,1:nlines)),alt(1:rbins),'linear','extrap');
scale(3,:) = interp1(altitude(1:nlines),log(beta_ray(3,1:nlines)),alt(1:rbins),'linear','extrap');
beta_mol(1,:) = exp(scale(1,:));
beta_mol(2,:) = exp(scale(2,:));
beta_mol(3,:) = exp(scale(3,:));

% with the trick above, this shouldn't be necessary, but it won't hurt
% either. let's make sure the interpolation did not lead to negative
% values
beta_mol(beta_mol<=0) = NaN;

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
  for i=1:rbins
    % calculate pr2_ray_sig in km-1 
    pr2_ray_sig(j,i)=beta_mol(j,i)*exp(-tau(j,i)-tau(1,i));
  end
end
%

%
%  Plot
% -------
figure(4)
xx=xx0+4*wdx; yy=yy0+4*wdy;
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
plot(beta_mol(1,:),alt(1:rbins)*1e-3,'b'); 
hold on
% at lidar levels
plot(beta_mol(2,:),alt(1:rbins)*1e-3,'c');
plot(beta_mol(3,:),alt(1:rbins)*1e-3,'r'); 
% at sounding levels
plot(beta_ray(1,:),altitude(:)*1e-3,'bo'); 
plot(beta_ray(2,:),altitude(:)*1e-3,'co');
plot(beta_ray(3,:),altitude(:)*1e-3,'ro'); 
title(['Radiosounding from ' site],'fontsize',[14]) 
legend('355', '387', '408', '355 sonde', '387 sonde', '408 sonde');
ylabel('Height / km')
xlabel('Lidar Beta / m-1')
grid on
hold off

% -------
figure(5)
xx=xx0+5*wdx; yy=yy0+5*wdy;
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
plot(temp,altitude*1e-3,'Color','r');
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
xlabel(ax2,'density / kg/m3')

line(rho,altitude,'Color','b','Parent',ax2);
grid on
hold off
%
disp('End of program: read_sonde_Manaus.m, Vers. 1.0 06/2012')
%