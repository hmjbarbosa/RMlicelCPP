%------------------------------------------------------------------------
% M-File:
%    read_sonde_Wyoming.m
%
% Authors:
%    H.M.J. Barbosa (hbarbosa@if.usp.br), IF, USP, Brazil
%    B. Hesse (heese@tropos.de), IFT, Leipzig, Germany
%
% Description
%
%    Reads temperature and pressure profiles from Wyoming soundings
%    as used by Manaus/Embrapa Lidar. This version is based on
%    original code written by Birgit Hesse, from iFT,
%    Leipzig. Cleaning, debugging, commenting and modification in
%    variable's names done by hbarbosa.
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
clear radiofile sondedata
clear temp_snd pres_snd rho_snd alt_snd nlev_snd

% cannot read as a table because wyoming files have empty space for
% missing data. usually happens at higher altitudes. the reading
% mechanism, in this case, must rely on the constant width of the
% fields. 

jdi=datenum(2012, 1, 20, 23,  0, 0);
jdf=datenum(2012, 1, 20, 23, 60, 0);

% input dir
dir='/home/hbarbosa/Programs/sondagens/dat';
disp(['*** read radiosounding data from dir:' dir]);

% create file list
addpath('../matlab')
ff=dirpath(dir,'82332*dat');
nfile=numel(ff);

% loop over all files
for nf=1:nfile
  nf
  ff{nf}
  
  sonde(nf)=read_sonde_Wyoming(ff{nf});

end
return  

%------------------------------------------------------------------------
%  Plots
%------------------------------------------------------------------------
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
line(rho_snd,alt_snd,'Color','b','Parent',ax2);
grid on
hold off
%
%
disp('End of program: read_sonde_Manaus.m, Vers. 1.0 06/2012')
%