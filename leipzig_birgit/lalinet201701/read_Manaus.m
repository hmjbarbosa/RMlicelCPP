% read raw original
%function read_raw_original(rawdir,letter)
clear all
close all
rawdir='Brasil_Manaus';
letter='RM';

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
for i=1:length(ylist)
    ylist{i}
    
    dlist={};
    for j=1:12
        dlist=[dlist,dirpath([ylist{i} '/' num2str(j)],'0*')]; 
        dlist=[dlist,dirpath([ylist{i} '/' num2str(j)],'1*')]; 
        dlist=[dlist,dirpath([ylist{i} '/' num2str(j)],'2*')]; 
        dlist=[dlist,dirpath([ylist{i} '/' num2str(j)],'3*')]; 
    end
    disp(['number of days with measurements= ' num2str(length(dlist))])
    
    filelist={};
    for j=1:length(dlist)
        filelist=[filelist,dirpath(dlist{j},[letter '*'])];
        %[j length(filelist)]
    end
    disp(['number of files= ' num2str(length(filelist))])

    disp('Reading data...')
    [head, chphy] = profile_read_many(filelist, 0, 0, 0, rangebins);

    disp('Merging data...')
    clear x
    x.(tag).head = head;
    x.(tag).chphy = chphy;
    x.(tag).dirlist = dlist;
    x.(tag).filelist = filelist;
    x.(tag).rangebins = rangebins;
    x.(tag).base = base;
    
    disp('Save file...')
    [a b]=fileparts(ylist{i});
    save([tag '_' num2str(b) '.mat'],'-struct', 'x', '-v7.3')
    
end

