%------------------------------------------------------------------------
% M-File:
%    read_sonde_synthetic.m
%
% Authors:
%    H.M.J. Barbosa (hbarbosa@if.usp.br), IF, USP, Brazil
%
% Description
%
%    Reads temperature and pressure profiles distributed with
%    EARLINET's synthetic lidar signals.
%
% Input
%
%    radiofile - path and filename to data file
%
% Ouput
%
%    pres_snd(nlev_snd, 1) - column with pressure in hPa
%    temp_snd(nlev_snd, 1) - column with temperature in K
%    rho_snd(nlev_snd, 1) - column with density in kg/m3
%    alt_snd(nlev_snd, 1) - column with altitude in m
%
% Usage
%
%    First run: 
%
%        constants.m
%
%    Then execute this script.
%
%------------------------------------------------------------------------
function [snd] = read_sonde_synthetic(radiofile, debug)

T0=273.15; % K
Rair=287.0417; % J/K/kg, for 400 ppmv CO2

% open input file
snd.fname=radiofile;
if ~exist('radiofile','var')
  error('File name not given. Try: help read_sonde');
else
  % This file cannot be read with constant width because the columns
  % shift left/right. This happens because there is only a single space
  % between each column, and the number of digits in each column
  % varies. Hence, we read as a numeric table with space as column
  % separator

  sonde=importdata(snd.fname, ' ', 1);
end

% set default debug level
if ~exist('debug','var')
  debug=0;
end

if (debug>0)
  disp(['read_sonde:: input file = ' radiofile]);
end

snd.code='99999';
snd.station='fake';
snd.jd=datenum('0:00 1 jan 1980');
snd.date=datevec(snd.jd);

snd.pres(:,1)=sonde.data(:,3)*100.;  % P in Pa!
snd.alt(:,1)=sonde.data(:,2); % in m 
snd.temp(:,1)=T0 + sonde.data(:,4); % T in K

% compute air density
% P = rho*R*T, R=287.05 J/kg/K
% rho in kg/m3
snd.rho(:,1)=snd.pres./snd.temp/Rair;

% number of levels in sounding
snd.nlev=max(size(snd.pres));

if (debug>0)
  disp(['read_sonde:: nlev_snd = ' num2str(snd.nlev)]);
  disp(['read_sonde:: highest = ' ...
	num2str(snd.pres(snd.nlev)) ' Pa / ' ... 
	num2str(snd.alt(snd.nlev)) ' m ']);
end

%------------------------------------------------------------------------
%  Plots
%------------------------------------------------------------------------
%
if (debug>1)
  figure
  temp=get(gcf,'position'); temp(3)=260; temp(4)=650;
  set(gcf,'position',temp); % units in pixels!
  plot(snd.temp,snd.alt*1e-3,'Color','r','linewidth',1.5);
  hold on
  ax1 = gca;
  set(ax1,'XColor','r','YColor','k','XAxisLocation','bottom')
  ylabel(ax1,'Height / km')
  xlabel(ax1,'Temperature / K')
  xlimits = get(ax1,'XLim');
  ylimits = get(ax1,'YLim');
  xinc = (xlimits(2)-xlimits(1))/5;
  yinc = (ylimits(2)-ylimits(1))/5;
  
  set(ax1,'XTick',[xlimits(1):xinc:xlimits(2)],...
	  'YTick',[ylimits(1):yinc:ylimits(2)]);
  
  ax2 = axes('Position',get(ax1,'Position'),'XAxisLocation','top',...
	     'YAxisLocation','right','Color','none',...
	     'XColor','b','YColor','k');
  
  xlabel(ax2,'density / kg/m3')
  line(snd.rho,snd.alt*1e-3,'Color','b','Parent',ax2,'linewidth',1.5);
  xlimits = get(ax2,'XLim');
  xinc = (xlimits(2)-xlimits(1))/5;
  set(ax2,'XTick',[xlimits(1):xinc:xlimits(2)],...
	  'YTick',[ylimits(1):yinc:ylimits(2)]);
  
  grid on
  hold off
end
set(gcf,'PaperUnits','inches','PaperSize',[3,9],'PaperPosition',[0 0 3 7.8]);
%prettify(gca); grid on;
print('earlinet_PT.png','-dpng');
%
%
disp('End of program: read_sonde_synthetic.m, Vers. 1.0 06/2012')
%