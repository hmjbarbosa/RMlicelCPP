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
addpath('../matlab')

% cannot read as a table because wyoming files have empty space for
% missing data. usually happens at higher altitudes. the reading
% mechanism, in this case, must rely on the constant width of the
% fields. 

% input dir
%dir='/Users/hbarbosa/Skydrive/sondagens/82332/dat';
%dir='/Users/hbarbosa/Dropbox/00_ANALYSIS/sondagens/82332/dat';
dir='/Users/hbarbosa/Dropbox/00_ANALYSIS/sondagens/81729/dat';
disp(['*** read radiosounding data from dir:' dir]);

% create file list

ff=dirpath(dir,'*dat');
nfile=numel(ff);

% loop over all files
for i=1:nfile
  disp([num2str(i) ' ' ff{i}])
  tmp=read_sonde_Wyoming(ff{i});

  sonde.fname{i}=tmp.fname;
  sonde.code(i)=tmp.code;
  sonde.station{i}=tmp.station;
  sonde.jd(i)=tmp.jd;
  sonde.date(:,i)=tmp.date(1,:);

  if (i>1)
    nlev=max(sonde.nlev);
    if (tmp.nlev > nlev)
      sonde.pres(nlev+1:tmp.nlev,:)=NaN;
      sonde.alt (nlev+1:tmp.nlev,:)=NaN;
      sonde.temp(nlev+1:tmp.nlev,:)=NaN;
      sonde.rho (nlev+1:tmp.nlev,:)=NaN;
      sonde.dwpt(nlev+1:tmp.nlev,:)=NaN;
      sonde.relh(nlev+1:tmp.nlev,:)=NaN;
      sonde.wdir(nlev+1:tmp.nlev,:)=NaN;
      sonde.wvel(nlev+1:tmp.nlev,:)=NaN;
    end
  end
  
  sonde.nlev(i)=tmp.nlev;

  sonde.pres(1:tmp.nlev,i)=tmp.pres(1:tmp.nlev,1);   
  sonde.alt (1:tmp.nlev,i)=tmp.alt (1:tmp.nlev,1);   
  sonde.temp(1:tmp.nlev,i)=tmp.temp(1:tmp.nlev,1);   
  sonde.rho (1:tmp.nlev,i)=tmp.rho (1:tmp.nlev,1);   
  sonde.dwpt(1:tmp.nlev,i)=tmp.dwpt(1:tmp.nlev,1);   
  sonde.relh(1:tmp.nlev,i)=tmp.relh(1:tmp.nlev,1);   
  sonde.wdir(1:tmp.nlev,i)=tmp.wdir(1:tmp.nlev,1);   
  sonde.wvel(1:tmp.nlev,i)=tmp.wvel(1:tmp.nlev,1);   
     
  sonde.id{i}=tmp.id;
  sonde.number(i)=tmp.number;
  sonde.time{i}=tmp.time;
  sonde.lat(i)=tmp.lat;
  sonde.lon(i)=tmp.lon;
  sonde.elev(i)=tmp.elev;
  sonde.showalter(i)=tmp.showalter;
  sonde.lift(i)=tmp.lift;
  sonde.liftv(i)=tmp.liftv;
  sonde.sweat(i)=tmp.sweat;
  sonde.kidx(i)=tmp.kidx;
  sonde.crosidx(i)=tmp.crosidx;
  sonde.vertidx(i)=tmp.vertidx;
  sonde.totlidx(i)=tmp.totlidx;
  sonde.cape(i)=tmp.cape;
  sonde.cine(i)=tmp.cine;
  sonde.cinev(i)=tmp.cinev;
  sonde.eqlb(i)=tmp.eqlb;
  sonde.eqlbv(i)=tmp.eqlbv;
  sonde.lfc(i)=tmp.lfc;
  sonde.lfcv(i)=tmp.lfcv;
  sonde.brich(i)=tmp.brich;
  sonde.brichcap(i)=tmp.brichcap;
  sonde.lcltemp(i)=tmp.lcltemp;
  sonde.lclpres(i)=tmp.lclpres;
  sonde.mixedpot(i)=tmp.mixedpot;
  sonde.mixedratio(i)=tmp.mixedratio;
  sonde.thick500(i)=tmp.thick500;
  sonde.pwat(i)=tmp.pwat;

end

%