% read raw original
%function read_raw_original(rawdir,letter)
clear all
close all
rawdir='Bolivia';
letter='a';

addpath ../../matlab
addpath ..

tag=strrep(rawdir,'/','_');

disp(['Processing ' tag])

rangebins=1000; % it has 30m bins

% data dir
base=['/server/ftproot/private/lalinet/' rawdir '/raw_ascii'];
disp(['Basedir= ' base])

% list all possible years 
ylist=dirpath([base],'20*');
disp(['number of years with measurements= ' num2str(length(ylist))])

% for each year, search for months
mlist={};
for i=1:length(ylist)
    mlist=[mlist,dirpath(ylist{i},'0*')];
    mlist=[mlist,dirpath(ylist{i},'1*')];
end
disp(['number of months with measurements= ' num2str(length(mlist))])

% for each month, search for files 
filelist={};
for i=1:length(mlist)
    filelist=[filelist,dirpath(mlist{i},'*rawdata.txt')];
end
disp(['number of days= ' num2str(length(filelist))])

disp('Reading data...')
[head, chphy] = profile_read_many_ascii_Bolivia(filelist, 0, 0, 0, rangebins);

disp('Merging data...')
x.(tag).head = head;
x.(tag).chphy = chphy;
x.(tag).dirlist = mlist;
x.(tag).filelist = filelist;
x.(tag).rangebins = rangebins;
x.(tag).base = base;

disp('Save file...')
save([tag '.mat'],'-struct', 'x', '-v7.3')
%