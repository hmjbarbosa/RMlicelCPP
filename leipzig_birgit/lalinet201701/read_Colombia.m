% read raw original
%function read_raw_original(rawdir,letter)
clear all
close all
rawdir='Colombia';
letter='a';

addpath ../../matlab

tag=strrep(rawdir,'/','_');

disp(['Processing ' tag])

rangebins=4000;

% data dir
base=['/server/ftproot/private/lalinet/' rawdir '/raw_ascii'];
disp(['Basedir= ' base])

% list all possible years 
ylist=dirpath([base],'20*');
disp(['number of years with measurements= ' num2str(length(ylist))])
% for each year, search for months
mlist={};
for i=1:length(ylist)
    mlist=[mlist,dirpath(ylist{i},'Jan*')];
    mlist=[mlist,dirpath(ylist{i},'Feb*')];
    mlist=[mlist,dirpath(ylist{i},'Mar*')];
    mlist=[mlist,dirpath(ylist{i},'Apr*')];
    mlist=[mlist,dirpath(ylist{i},'May*')];
    mlist=[mlist,dirpath(ylist{i},'Jun*')];
    mlist=[mlist,dirpath(ylist{i},'Jul*')];
    mlist=[mlist,dirpath(ylist{i},'Aug*')];
    mlist=[mlist,dirpath(ylist{i},'Sep*')];
    mlist=[mlist,dirpath(ylist{i},'Oct*')];
    mlist=[mlist,dirpath(ylist{i},'Nov*')];
    mlist=[mlist,dirpath(ylist{i},'Dec*')];
end
disp(['number of months with measurements= ' num2str(length(mlist))])
% for each month, search for files inside each day
dlist={};
for i=1:length(mlist)
    tmpf=dirpath(mlist{i},'*.*.*');
    % eliminate .. and telecover directories
    for j=length(tmpf):-1:1
        if ~isempty(strfind(tmpf{j},'..')) | ~isempty(strfind(tmpf{j},'cover'))
            tmpf(j)=[];
        end
    end
    dlist=[dlist,tmpf];
end
disp(['number of days= ' num2str(length(dlist))])

filelist={};
for i=1:length(dlist)
    filelist=[filelist,...
              dirpath([dlist{i} '/am/Data/txt'],[letter '*.txt'])];

    filelist=[filelist,...
              dirpath([dlist{i} '/pm/Data/txt'],[letter '*.txt'])];
end
disp(['number of files= ' num2str(length(filelist))])

disp('Reading data...')
[head, chphy] = profile_read_many_ascii_Colombia(filelist, 0, 0, 0, rangebins);

disp('Merging data...')
x.(tag).head = head;
x.(tag).chphy = chphy;
x.(tag).dirlist = mlist;
x.(tag).filelist = filelist;
x.(tag).rangebins = rangebins;
x.(tag).base = base;

disp('Save file...')
save([tag '.mat'],'-struct', 'x', '-v7.3')
