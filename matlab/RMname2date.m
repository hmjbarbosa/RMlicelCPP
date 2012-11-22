function [date] = RMname2date(path_name)

n=numel(path_name);
name=path_name(n-10:n);

%   12345678901
% RMYYMDDHH.MMS

date(1)=sscanf(name(1:2),'%d');
date(1)=date(1)+2000;
% need to add error handling. the routines breaks if the input name
% is not in the format above.
date(3:6)=sscanf(name(4:11),'%02d%02d.%02d%1d');

if (name(3)=='A')
  date(2)=10;
elseif (name(3)=='B')
  date(2)=11;
elseif (name(3)=='C')
  date(2)=12;
else
  date(2)=sscanf(name(3),'%d');
end

%