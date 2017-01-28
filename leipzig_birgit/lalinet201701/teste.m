clear all
close all

base='/server/ftproot/private/lalinet/Colombia/raw_ascii/2013/bad_Feb/25.02.13/am/';

ftxt=[base 'Data/txt/a1322506.575982.txt'];
fbin=[base 'Dark/a1322506.415930'];

tic
for i=1:10
    [x y]=profile_read(fbin, 0,0,0,4000);
end
toc

tic
for i=1:10
    [x y]=profile_read_ascii(ftxt, 0,0,0,4000);
end
toc

%