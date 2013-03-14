clear 
tic

fid=fopen('110101_131231_Manaus_EMBRAPA.lev20','r');
%fid=fopen('teste.txt','r');
for i=1:5
  head{i}=fgetl(fid);
end

i=0;
while ~feof(fid);
  i=i+1;
  aline=fgetl(fid);
  row=textscan(aline,'%s','delimiter',',','endofline','\r');
  M{i}=strrep(row{1},'N/A','NaN');
end
nlines=i;
ncols=size(row{1},1);
fclose(fid);
toc

for i=1:nlines
  % column 1= date
  % column 2= time
  jd(i)=datenum([M{i}{1} ' ' M{i}{2}],'dd:mm:yyyy HH:MM:SS');
  % column 3= day of year
  % column 4-19 AOT
  for j=4:19
    aot(i,j-3)=str2num(M{i}{j});
  end
  % column 20, water(cm)
  water(i,1)=str2num(M{i}{20});
  % column 21-36 triplet
  for j=21:36
    triplet(i,j-20)=str2num(M{i}{j});
  end
  % column 37, water error(cm)
  water(i,2)=str2num(M{i}{37});
  % column 38-43 angstrom
  for j=38:43
    angstrom(i,j-37)=str2num(M{i}{j});
  end
  % column 44 date
  % column 45 zenith angle
  zenith(i)=str2num(M{i}{45});
  % column 46 intrument
  cimelnum(i)=str2num(M{i}{46});
  % column 47-62 triplet
  for j=47:62
    wlen(i,j-46)=str2num(M{i}{j});
  end
  % column 63, water wave length 
  water(i,3)=str2num(M{i}{63});  
end
toc

%