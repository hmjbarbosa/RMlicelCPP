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
clear sonde radiofile
clear temp_snd pres_snd rho_snd alt_snd nlev_snd

% This file cannot be read with constant width because the columns
% shift left/right. This happens because there is only a single space
% between each column, and the number of digits in each column
% varies. Hence, we read as a numeric table with space as column
% separator
radiofile=['../synthetic_signals/Temperature_and_Pressure/txt/PTsim.txt.txt']
disp(['*** read radiosounding data ' radiofile]);
sonde=importdata(radiofile, ' ', 1);

pres_snd=sonde.data(:,3);  % P in hPa!
alt_snd=sonde.data(:,2); % in m 
temp_snd=T0 + sonde.data(:,4); % T in K

% P = rho*R*T, Rair=287.05 J/kg/K
% 100 corrects hPa to Pa, hence rho in kg/m3
rho_snd=100*pres_snd./temp_snd/Rair;

% number of levels in sounding
nlev_snd=max(size(pres_snd));

%------------------------------------------------------------------------
%  Plots
%------------------------------------------------------------------------
return
%
%
% -------------
figure(4)
xx=xx0+5*wdx; yy=yy0+5*wdy;
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
plot(temp_snd,alt_snd*1e-3,'Color','r');
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
line(rho_snd,alt_snd,'Color','b','Parent',ax2);
grid on
hold off
%
%
disp('End of program: read_sonde_synthetic.m, Vers. 1.0 06/2012')
%