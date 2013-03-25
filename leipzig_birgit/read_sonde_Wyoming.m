%------------------------------------------------------------------------
% M-File:
%    read_sonde_Manaus.m
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
function [sonde] = read_sonde_Wyoming(radiofile)

constants;

sonde.fname=radiofile;

fid=fopen(sonde.fname,'r'); 

% read lines until finding "Observations"
j=0; 
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
  j=j+1;
end
% From first line, read station name, code and time of observation
%<H2>82332 SBMN Manaus (Aeroporto) Observations at 00Z 01 Sep 2011</H2>
i=findstr('<H2>',aline);
if isempty(i); i=1; else i=i+4; end
sonde.code=sscanf(aline(i:end),'%d');
i=i+numel(num2str(sonde.code))+1;
sonde.station=aline(i:ipos-2);
sonde.jd=datenum([aline(ipos+16:ipos+17) ':00 ' aline(ipos+20:ipos+30)]);
sonde.date=datevec(sonde.jd);

% read sounding data, skipping non-numeric lines
i=0;
while ~feof(fid)
  % cannot read as a table because wyoming files have empty space for
  % missing data. usually happens at higher altitudes. the reading
  % mechanism, in this case, must rely on the constant width of the
  % fields.
  aline = fgetl(fid);

  % test if first word is a number
  word=sscanf(aline,'%s',1);
  tmp=str2num(word);
  if isempty(tmp)
    % test if it is the mark of the last data line
    if ~isempty(findstr(aline,'Station information'))
      break
    end
    continue
  end

  if ~isempty(aline)
    i=i+1;
    num=str2num(aline(1:7));
    if ~isempty(num)
      sonde.pres(i,1)=num;  % P in hPa!
    else
      sonde.pres(i,1)=NaN;
    end
    num=str2num(aline(8:14));
    if ~isempty(num)
      sonde.alt(i,1)=num; % in m 
    else
      sonde.alt(i,1)=NaN;
    end
    num=str2num(aline(15:21));
    if ~isempty(num)
      sonde.temp(i,1)=T0 + num; % T in K
    else
      sonde.temp(i,1)=NaN;
    end
    sonde.rho(i,1)=100*sonde.pres(i,1)./sonde.temp(i,1)/Rair;
  end 
end 

% number of levels in sounding
sonde.nlev=max(size(sonde.pres));

% read rest of lines with important data
sonde.id=NaN;
sonde.number=NaN;
sonde.time=NaN;
sonde.lat=NaN;
sonde.lon=NaN;
sonde.elev=NaN;
sonde.showalter=NaN;
sonde.lift=NaN;
sonde.liftv=NaN;
sonde.sweat=NaN;
sonde.kidx=NaN;
sonde.crosidx=NaN;
sonde.vertidx=NaN;
sonde.totlidx=NaN;
sonde.cape=NaN;
sonde.cine=NaN;
sonde.cinev=NaN;
sonde.eqlb=NaN;
sonde.eqlbv=NaN;
sonde.lfc=NaN;
sonde.lfcv=NaN;
sonde.brich=NaN;
sonde.brichcap=NaN;
sonde.lcltemp=NaN;
sonde.lclpres=NaN;
sonde.mixedpot=NaN;
sonde.mixedratio=NaN;
sonde.thick500=NaN;
sonde.pwat=NaN;
j=0; 
while ~feof(fid)
  aline=fgetl(fid);
  ipos=findstr('Observations',aline); if ~isempty(ipos) break; end; 
  if ~isempty(findstr('Station identifier',aline)) 
    sonde.id=sscanf(aline(findstr(':',aline)+1:end),'%s');
  end
  if ~isempty(findstr('Station number',aline)) 
    sonde.number=sscanf(aline(findstr(':',aline)+1:end),'%d');
  end
  if ~isempty(findstr('Observation time',aline)) 
    sonde.time=sscanf(aline(findstr(':',aline)+1:end),'%s');
  end
  if ~isempty(findstr('Station latitude',aline)) 
    sonde.lat=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Station longitude',aline)) 
    sonde.lon=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Station elevation',aline)) 
    sonde.elev=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Showalter index',aline)) 
    sonde.showalter=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Lifted index:',aline)) 
    sonde.lift=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('LIFT computed using virtual temperature',aline)) 
    sonde.liftv=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('SWEAT index',aline)) 
    sonde.sweat=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('K index',aline)) 
    sonde.kidx=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Cross totals index',aline)) 
    sonde.crosidx=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Vertical totals index',aline)) 
    sonde.vertidx=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Convective Available Potential Energy',aline)) 
    sonde.totlidx=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('CAPE using virtual temperature',aline)) 
    sonde.cape=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Convective Inhibition',aline)) 
    sonde.cine=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('CINS using virtual temperature',aline)) 
    sonde.cinev=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Equilibrum Level',aline)) 
    sonde.eqlb=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Equilibrum Level using virtual temperature',aline)) 
    sonde.eqlbv=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Level of Free Convection',aline)) 
    sonde.lfc=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('LFCT using virtual temperature',aline)) 
    sonde.lfcv=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Bulk Richardson Number',aline)) 
    sonde.brich=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Bulk Richardson Number using CAPV',aline)) 
    sonde.brichcap=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Temp [K] of the Lifted Condensation Level',aline)) 
    sonde.lcltemp=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Pres [hPa] of the Lifted Condensation Level',aline)) 
    sonde.lclpres=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Mean mixed layer potential temperature',aline)) 
    sonde.mixedpot=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Mean mixed layer mixing ratio',aline)) 
    sonde.mixedratio=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('1000 hPa to 500 hPa thickness',aline)) 
    sonde.thick500=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  if ~isempty(findstr('Precipitable water [mm] for entire sounding',aline)) 
    sonde.pwat=sscanf(aline(findstr(':',aline)+1:end),'%f');
  end
  
  j=j+1;
end

fclose(fid);

return
%