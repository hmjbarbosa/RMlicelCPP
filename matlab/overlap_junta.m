%% ERASE MEMORY
clear all; 
addpath('../sc')

temp_xyzw2
temp_wjdi=wjdi;
temp_wjdf=wjdf;
t=numel(wjdi);

clear wjdi wjdf
temp_xyzw
n=numel(wjdi);

wjdi(n+1:n+t)=temp_wjdi;
wjdf(n+1:n+t)=temp_wjdf;


fid=fopen('temp_xyzw3.m','w');
for i=1:numel(wjdi)
  fprintf(fid,'wjdi(%02d)=datenum(''%s''); wjdf(%02d)=datenum(''%s'');\n', ...
	  i,datestr(wjdi(i)),i, datestr(wjdf(i)));
end
fclose(fid);

%