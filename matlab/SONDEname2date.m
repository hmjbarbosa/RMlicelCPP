function [date] = SONDEname2date(path_name)

n=numel(path_name);
name=path_name(n-23:n);

% 123456789012345678901234567890
% 82332_2011_01_01_00Z.dat

date(1)=sscanf(name(7:10),'%d');
% need to add error handling. the routines breaks if the input name
% is not in the format above.
date(2)=sscanf(name(12:13),'%d');
date(3)=sscanf(name(15:16),'%d');
date(4)=sscanf(name(18:19),'%d');
date(5)=0;
date(6)=0;

%