% Argentina - Bariloche
disp('Processing Argentina - Bariloche')

clear all
addpath ../../matlab

rangebins=4000;

% data dir
base='/server/ftproot/private/lalinet/Argentina/Bariloche/raw_original';
disp(['Basedir= ' base])

% list all possible directories (days with measurements)
dirlist=dirpath([base],'20*');
disp(['number of days with measurements= ' num2str(length(dirlist))])

% get all files in all days
ff={};
for i=1:length(dirlist)
    tmpf=dirpath(dirlist{i},'b*'); 
    ff=[ff,tmpf];
end
disp(['number of files= ' num2str(length(ff))])

disp('Reading data...')
[head, chphy] = profile_read_many(ff, 0, 0, 0, rangebins);

% data from 2012 sep 11 has wrong dates in the files
for i=1:length(head)
  tmp=datevec(head(i).jdi);
  if (tmp(1)==2002 & tmp(2)==9 & tmp(3)==13)
      tmp(1)=2012; tmp(2)=9; tmp(3)=11;
      head(i).jdi=datenum(tmp);
  
      tmp=datevec(head(i).jdf);
      tmp(1)=2012; tmp(2)=9; tmp(3)=11;
      head(i).jdf=datenum(tmp);
  end
end

bariloche.head = head;
bariloche.chphy = chphy;
bariloche.dirlist = dirlist;
bariloche.ff = ff;
bariloche.rangebins = rangebins;
bariloche.base = base;

clear head chphy dirlist ff rangebins base tmpf tmp i

save('bariloche.mat','-v7.3')


%