%
clear all
close all

load COD_JL.mat

% o dado do diego esta em UTC mas esta errado...
% ele fez UTC = LT - 4 quando o certo seria
%  UTC=LT+4

tt=jd_COD_UTC+8/24;

hour=(datenum(tt)-datenum('0:0:0 3-Jun-2014'))*24.;
x=[datevec(tt') hour' COD];

csvwrite('manaus_tojuan.csv',x)

%