%------------------------------------------------------------------------
% M-File:
%    search_sonde.m
%
% Authors:
%    H.M.J. Barbosa (hbarbosa@if.usp.br), IF, USP, Brazil
%
% Description
%
%    Generate a date vector from the name of the radiosonde
%    file. It assumes the file is named as: 
%
%       XXXXX_YYYY_MM_DD_HHZ.dat
%
%    where:
%       XXXXX - station ID
%       YYYY - Year with 4 digits
%       MM - Month with 2 digits
%       DD - Day with 2 digits
%       HH - Hour with 2 digits
%
% Input
%
%
% Ouput
%
%
%------------------------------------------------------------------------
function [radiofile allradiofiles allradiojd] = search_sonde(radiodir,stationid,jd)

allradiofiles=dirpath(radiodir,[stationid '*.dat']);

% Check if any files were found
nfile=numel(allradiofiles);
if (nfile < 1)
  disp(['search_sonde:: no files found!']);
  return
end

% loop through all files and get the julian date of each one
for i=1:nfile
  path_name=allradiofiles{i};
  n=numel(path_name);
  name=path_name(n-23:n);
  
  % 123456789012345678901234567890
  % 82332_2011_01_01_00Z.dat
  
  % need to add error handling. the routine breaks if the input name
  % is not in the proper format
  date(1)=sscanf(name(7:10),'%d');
  date(2)=sscanf(name(12:13),'%d');
  date(3)=sscanf(name(15:16),'%d');
  date(4)=sscanf(name(18:19),'%d');
  date(5)=0;
  date(6)=0;

  allradiojd(i)=datenum(date);
end

% from all files listed, check those closer to jd
[minjd, posjd]=min(abs(allradiojd-jd));

radiofile=allradiofiles{posjd};
disp(['search_sonde:: closest date = ' datestr(datestr(allradiojd(posjd)))]);
disp(['search_sonde:: distance to jd = ' num2str(minjd) ' days']);
%