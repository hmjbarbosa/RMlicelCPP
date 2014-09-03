%
% M-File:
%    read_sonde_Wyoming.m
%
% Authors:
%    H.M.J. Barbosa (hbarbosa@if.usp.br), IF, USP, Brazil
%    B. Hesse (heese@tropos.de), IFT, Leipzig, Germany
%
% Description
%
%    Reads temperature and pressure profiles from Wyoming soundings as
%    used by Manaus/Embrapa Lidar. This version is based on original
%    code written by Birgit Hesse, from iFT, Leipzig. Cleaning,
%    debugging, commenting and modification in variable's names done
%    by hbarbosa.
%
% Input
%
%    radiofile - path and filename to data file
%    debug     - level of message output
%
% Ouput
%
%    snd.pres(snd.nlev, 1) - column with pressure in Pa
%    snd.temp(snd.nlev, 1) - column with temperature in K
%    snd.rho (snd.nlev, 1) - column with density in kg/m3
%    snd.alt (snd.nlev, 1) - column with altitude in m
%
function [snd] = read_sonde_Wyoming(radiofile, debug)

T0=273.15; % K
Rair=287.0417; % J/K/kg, for 400 ppmv CO2

% open input file
snd.fname=radiofile;
if ~exist('radiofile','var')
  error('File name not given. Try: help read_sonde');
else
  fid=fopen(snd.fname,'r'); 
  % check if properly open
  if fid<0
    error('read_sonde:Error:OpenFileFailure ');
    return;
  end
end

% set default debug level
if ~exist('debug','var')
  debug=0;
end

if (debug>0)
  disp(['read_sonde:: input file = ' radiofile]);
end

% read lines until finding "Observations"
while ~feof(fid)
  aline=fgetl(fid);
  [mess, err]=ferror(fid);
  if (err==0)
    ipos=findstr('Observations',aline);
    if ~isempty(ipos)
      break
    end
  else
    disp(mess);
    return;
  end
end
% From first line, read station name, code and time of observation
%<H2>82332 SBMN Manaus (Aeroporto) Observations at 00Z 01 Sep 2011</H2>
i=findstr('<H2>',aline);
if isempty(i); i=1; else i=i+4; end
snd.code=sscanf(aline(i:end),'%d');
i=i+numel(num2str(snd.code))+1;
snd.station=aline(i:ipos-2);
snd.jd=datenum([aline(ipos+20:ipos+30) ' ' aline(ipos+16:ipos+17) ':00 UTC ']);
snd.date=datevec(snd.jd);

% start line counter
i=0;

% read sounding data, skipping non-numeric lines
while ~feof(fid)
  % cannot read as a table because wyoming files have empty space for
  % missing data. usually happens at higher altitudes. the reading
  % mechanism, in this case, must rely on the constant width of the
  % fields.
  aline = fgetl(fid);
  
  % jump empty lines
  if isempty(aline)
    continue
  end

  % test if first word is a number
  word=sscanf(aline,'%s',1);
  tmp=str2num(word);
  if isempty(tmp)
    % test if it is the mark of the last data line
    if ~isempty(findstr(aline,'Station'))
      break
    end
    % if it is anothoer word, just skip the junk line
    continue
  end

  % skip lines where pres or alt or temp are missing
  if all(aline(1:7)==' ') | all(aline(8:14)==' ') | ...
	all(aline(15:21)==' ') 
    continue
  end

  % advance line counter
  i=i+1;
  
  % get pressure, altitude and temperature
  snd.pres(i,1)=str2num(aline(1:7))*100;  % P in Pa!
  snd.alt(i,1)=str2num(aline(8:14)); % in m 
  snd.temp(i,1)=T0 + str2num(aline(15:21)); % T in K

  % skip repeated lines
  if (i>1 & snd.alt(i,1)==snd.alt(i-1,1))
    i=i-1;
    continue;
  end

  % compute air density
  % P = rho*R*T, R=287.05 J/kg/K
  % rho in kg/m3
  snd.rho(i,1)=snd.pres(i,1)./snd.temp(i,1)/Rair;

  % try to read dew point temperature
  if all(aline(23:28)==' ') 
    snd.dwpt(i,1)=NaN;
  else
    snd.dwpt(i,1)=T0 + str2num(aline(23:28)); % Td in K
  end
  % try to read relative humidity
  if all(aline(30:35)==' ') 
    snd.relh(i,1)=NaN;
  else
    snd.relh(i,1)=str2num(aline(30:35)); % RH in pct
  end
  % try to read wind direction
  if (all(aline(44:49)==' '))
    snd.wdir(i,1)=NaN;
  else
    snd.wdir(i,1)=str2num(aline(44:49)); % direction in deg
  end
  % try to read wind speed
  if (all(aline(51:56)==' '))
    snd.wvel(i,1)=NaN;
  else
    snd.wvel(i,1)=str2num(aline(51:56))/0.514; % speed in m/s
  end
    
end 

% number of levels in sounding
snd.nlev(1,1)=max(size(snd.pres));

if (debug>0)
  disp(['read_sonde:: nlev_snd = ' num2str(snd.nlev)]);
  disp(['read_sonde:: highest = ' ...
	num2str(snd.pres(snd.nlev)) ' hPa / ' ... 
	num2str(snd.alt(snd.nlev)) ' m ']);
end

% read rest of lines with important data
snd.id=NaN;
snd.number=NaN;
snd.time=NaN;
snd.lat=NaN;
snd.lon=NaN;
snd.elev=NaN;
snd.showalter=NaN;
snd.lift=NaN;
snd.liftv=NaN;
snd.sweat=NaN;
snd.kidx=NaN;
snd.crosidx=NaN;
snd.vertidx=NaN;
snd.totlidx=NaN;
snd.cape=NaN;
snd.cine=NaN;
snd.cinev=NaN;
snd.eqlb=NaN;
snd.eqlbv=NaN;
snd.lfc=NaN;
snd.lfcv=NaN;
snd.brich=NaN;
snd.brichcap=NaN;
snd.lcltemp=NaN;
snd.lclpres=NaN;
snd.mixedpot=NaN;
snd.mixedratio=NaN;
snd.thick500=NaN;
snd.pwat=NaN;

while ~feof(fid)
  aline=fgetl(fid);
  ipos=findstr('Observations',aline); if ~isempty(ipos) break; end; 
  if ~isempty(findstr('Station identifier',aline)) 
    snd.id=sscanf(aline(findstr(':',aline)+1:end),'%s');
  end
  if ~isempty(findstr('Station number',aline)) 
    snd.number=sscanf(aline(findstr(':',aline)+1:end),'%d');
  end
  if ~isempty(findstr('Observation time',aline)) 
    snd.time=sscanf(aline(findstr(':',aline)+1:end),'%s');
  end
  if ~isempty(findstr('Station latitude',aline)) 
    snd.lat=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Station longitude',aline)) 
    snd.lon=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Station elevation',aline)) 
    snd.elev=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Showalter index',aline)) 
    snd.showalter=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Lifted index:',aline)) 
    snd.lift=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('LIFT computed using virtual temperature',aline)) 
    snd.liftv=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('SWEAT index',aline)) 
    snd.sweat=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('K index',aline)) 
    snd.kidx=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Cross totals index',aline)) 
    snd.crosidx=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Vertical totals index',aline)) 
    snd.vertidx=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Convective Available Potential Energy',aline)) 
    snd.totlidx=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('CAPE using virtual temperature',aline)) 
    snd.cape=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Convective Inhibition',aline)) 
    snd.cine=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('CINS using virtual temperature',aline)) 
    snd.cinev=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Equilibrum Level',aline)) 
    snd.eqlb=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Equilibrum Level using virtual temperature',aline)) 
    snd.eqlbv=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Level of Free Convection',aline)) 
    snd.lfc=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('LFCT using virtual temperature',aline)) 
    snd.lfcv=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Bulk Richardson Number',aline)) 
    snd.brich=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Bulk Richardson Number using CAPV',aline)) 
    snd.brichcap=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Temp [K] of the Lifted Condensation Level',aline)) 
    snd.lcltemp=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Pres [hPa] of the Lifted Condensation Level',aline)) 
    snd.lclpres=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Mean mixed layer potential temperature',aline)) 
    snd.mixedpot=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Mean mixed layer mixing ratio',aline)) 
    snd.mixedratio=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('1000 hPa to 500 hPa thickness',aline)) 
    snd.thick500=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Precipitable water [mm] for entire sounding',aline)) 
    snd.pwat=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
end

fclose(fid);

%------------------------------------------------------------------------
%  Plots
%------------------------------------------------------------------------
%
if (debug>1)
  figure
  temp=get(gcf,'position'); temp(3)=260; temp(4)=650;
  set(gcf,'position',temp); % units in pixels!
  plot(snd.temp,snd.alt*1e-3,'Color','r');
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
  line(snd.rho,snd.alt*1e-3,'Color','b','Parent',ax2);
  xlimits = get(ax2,'XLim');
  xinc = (xlimits(2)-xlimits(1))/5;
  set(ax2,'XTick',[xlimits(1):xinc:xlimits(2)],...
	  'YTick',[ylimits(1):yinc:ylimits(2)]);
  
  grid on
  hold off
end
%