clear all
close all

addpath ../../matlab

%fname='/server/ftproot/private/lalinet/Bolivia/raw_ascii/2015/10/2015_10_19_rawdata.txt'
fname='/LFANAS/hbarbosa/2015_10_19_rawdata.txt';

[head, phy] = profile_read_ascii_Bolivia(fname);

%