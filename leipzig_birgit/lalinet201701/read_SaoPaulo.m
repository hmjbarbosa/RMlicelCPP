% read raw original
%function read_raw_original(rawdir,letter)
clear all
close all
rawdir='Brasil_SP';
letter='s';

addpath ../../matlab

tag=strrep(rawdir,'/','_');

disp(['Processing ' tag])

rangebins=4000;

% data dir
base=['/server/ftproot/private/lalinet/' rawdir '/raw_original'];
disp(['Basedir= ' base])

% list all possible years 
ylist=dirpath([base],'20*');
disp(['number of years with measurements= ' num2str(length(ylist))])
% for each year, search for months
mlist={};
for i=1:length(ylist)
    mlist=[mlist,dirpath(ylist{i},'0*')]; % months 01 .. 09
    mlist=[mlist,dirpath(ylist{i},'1*')]; % months 10 .. 12
end
disp(['number of months with measurements= ' num2str(length(mlist))])

% for each month, search for files inside each day
dlist={};
for i=1:length(mlist)
    dlist=[dlist,dirpath(mlist{i},'0*')]; % days 01 .. 09 
    dlist=[dlist,dirpath(mlist{i},'1*')]; % days 10 .. 19
    dlist=[dlist,dirpath(mlist{i},'2*')]; % days 20 .. 29
    dlist=[dlist,dirpath(mlist{i},'3*')]; % days 30 .. 31
end
disp(['number of days= ' num2str(length(dlist))])

filelist={};
for i=1:length(dlist)
    filelist=[filelist,...
              dirpath([dlist{i} '/measurement_day'],[letter '*'])];

    filelist=[filelist,...
              dirpath([dlist{i} '/measurement_night'],[letter '*'])];
end
disp(['number of files= ' num2str(length(filelist))])

disp('Reading data...')
[head, chphy] = profile_read_many(filelist, 0, 0, 0, rangebins);

disp('Merging data...')
x.(tag).head = head;
x.(tag).chphy = chphy;
x.(tag).dirlist = mlist;
x.(tag).filelist = filelist;
x.(tag).rangebins = rangebins;
x.(tag).base = base;

disp('Save file...')
save([tag '.mat'],'-struct', 'x', '-v7.3')
