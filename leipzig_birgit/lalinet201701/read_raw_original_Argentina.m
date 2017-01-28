% read raw original
function read_raw_original(rawdir,letter)

addpath ../../matlab

tag=strrep(rawdir,'/','_');

disp(['Processing ' tag])

rangebins=4000;

% data dir
base=['/server/ftproot/private/lalinet/' rawdir '/raw_original'];
disp(['Basedir= ' base])

% list all possible directories (days with measurements)
dirlist=dirpath([base],'20*');
disp(['number of days with measurements= ' num2str(length(dirlist))])

% get all files in all days
filelist={};
for i=1:length(dirlist)
    tmpf=dirpath(dirlist{i},[letter '*']); 
    filelist=[filelist,tmpf];
end
disp(['number of files= ' num2str(length(filelist))])

disp('Reading data...')
[head, chphy] = profile_read_many(filelist, 0, 0, 0, rangebins);

disp('Merging data...')
x.(tag).head = head;
x.(tag).chphy = chphy;
x.(tag).dirlist = dirlist;
x.(tag).filelist = filelist;
x.(tag).rangebins = rangebins;
x.(tag).base = base;

disp('Save file...')
save([tag '.mat'],'-struct', 'x', '-v7.3')


%