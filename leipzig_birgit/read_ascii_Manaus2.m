%------------------------------------------------------------------------
% M-File:
%    read_ascii_Manaus.m
%
% Authors:
%    H.M.J. Barbosa (hbarbosa@if.usp.br), IF, USP, Brazil
%    B. Hesse (heese@tropos.de), IFT, Leipzig, Germany
%
% Description
%
%    Reads data from Manaus/Embrapa Lidar in ascii format. This
%    version is based on original code written by Birgit Hesse, from
%    iFT, Leipzig. Cleaning, debugging, commenting and modification in
%    variable's names done by hbarbosa.
%
%    File format is shown below. Here only the glued elastic (355nm
%    column #4) and glued raman (387nm column #7) channels are used.
%
%    alt  355 An  355 PC  355 GL 387 An  387 PC  387 GL  407 PC
%     7.5  7.542  285.38  474.00  1.265   97.24   96.25  1.9387
%    15.0  7.343  282.61  461.47  1.241   94.71   94.45  1.8420
%    22.5  7.184  279.49  451.47  1.216   92.16   92.52  1.7977
%    30.0  7.018  276.89  441.07  1.185   89.55   90.21  1.7141
%    37.5  6.640  270.42  417.35  1.162   83.20   88.43  1.5305
%
% Input
%
%    filelist{1} - path and filename to list of embrapa files
%
% Ouput
%
%    rangebins - number of bins in lidar signal
%    r_bin     - vertical resolution in [km]
%    alt  (rangebins, 1) - altitude in [m]
%    altsq(rangebins, 1) - altitude squared in [m2]
%
%    P  (rangebins, 2) - signal to be processed (avg, bg, glue, etc...)
%    Pr2(rangebins, 2) - range corrected signal to be processed 
%
% Usage
%
%    Just execute this script.
%
%------------------------------------------------------------------------

clear jdi jdf datain
clear nfile heads chphy
clear altsq alt rangebins r_bin
clear glue355 glue387 P Pr2

%%------------------------------------------------------------------------
%%  READ DATA
%%------------------------------------------------------------------------

addpath('../matlab');
datain='../../Raymetrics_data';
jdi=datenum(2011, 8, 31, 20, 0, 0);
jdf=datenum(2011, 8, 31, 20, 15, 0);

[nfile, heads, chphy]=profile_read_dates(datain, jdi, jdf, 10, 0.004);

%% RANGE IN METERS
rangebins=heads(1).ch(1).ndata;
for i=1:rangebins
  alt(i,1)=(7.5*i);
end

%%------------------------------------------------------------------------
%% RANGE CORRECTION AND OTHER SIGNAL PROCESSING
%%------------------------------------------------------------------------

% calculate the range^2 [m^2]
altsq = alt.*alt;

% bin height in km
r_bin=(alt(2)-alt(1))*1e-3; 

% matrix to hold lidar received power P(z, lambda)
% anything user needs: time average, bg correction, glueing, etc..

%% GLUE ANALOG+PC
glue355=glue(chphy(1).data, heads(1).ch(1), chphy(2).data, heads(1).ch(2));
glue387=glue(chphy(3).data, heads(1).ch(3), chphy(4).data, heads(1).ch(4));

P(:,1)=squeeze(nanmean(glue355,2));
P(:,2)=squeeze(nanmean(glue387,2));
%P(:,1)=squeeze(nanmean(chphy(1).data,2));
%P(:,2)=squeeze(nanmean(chphy(4).data,2));

% range corrected signal Pz2(z, lambda)
for j = 1:2
  Pr2(:,j) = P(:,j).*altsq(:);
end

%------------------------------------------------------------------------
%  Plots
%------------------------------------------------------------------------
%
%
figure(1)
xx=xx0+1*wdx; yy=yy0+1*wdy;
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
plot(P(:,1),alt*1.e-3,'b')
xlabel('smooth bg-corr signal','fontsize',[10])  
ylabel('altitude (km)','fontsize',[10])
grid on
hold on
plot(P(:,2),alt*1.e-3,'c')
hold off
%
figure(2)
xx=xx0+2*wdx; yy=yy0+2*wdy;
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
plot(Pr2(:,1),alt*1.e-3,'b')
xlabel('range corrected smooth bg-corr signal','fontsize',[10])  
ylabel('altitude (km)','fontsize',[10])
grid on
hold on 
plot(Pr2(:,2),alt*1.e-3,'c')
hold off
% 
figure(3)
xx=xx0+3*wdx; yy=yy0+3*wdy;
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
plot(log(P(:,1)),alt*1.e-3,'b')
xlabel('log of smooth bg-corr signal','fontsize',[10])  
ylabel('altitude (km)','fontsize',[10])
grid on
hold on
plot(log(P(:,2)),alt*1.e-3,'c')
hold off
% 
% end of program read_ascii_Manaus.m ***    
