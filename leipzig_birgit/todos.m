clear all
addpath('../matlab');
addpath('../sc');

% windows' size
wsx=250; wsy=650; 
% displacement for next window
wdx=260; xx0=-wsx;
% start position
wdy=0;   yy0=50;

% read physics constants
constants

%% DRY NO CLOUDS
wjdi(01)=datenum('29-Jul-2011 01:00:00'); 
wjdf(01)=datenum('29-Jul-2011 02:00:00');

wjdi(01)=datenum('29-Jul-2011 23:00:00'); 
wjdf(01)=datenum('29-Jul-2011 24:00:00');

wjdi(01)=datenum('30-Jul-2011 20:00:00'); 
wjdf(01)=datenum('30-Jul-2011 21:00:00');

wjdi(01)=datenum('30-Jul-2011 23:00:00'); 
wjdf(01)=datenum('30-Jul-2011 24:00:00');
%
wjdi(01)=datenum('31-Jul-2011 02:00:00'); 
wjdf(01)=datenum('31-Jul-2011 03:00:00');
%
wjdi(01)=datenum('01-Aug-2011 22:00:00'); 
wjdf(01)=datenum('01-Aug-2011 23:00:00');
%
wjdi(01)=datenum('02-Aug-2011 22:00:00'); 
wjdf(01)=datenum('02-Aug-2011 23:00:00');
%
wjdi(01)=datenum('04-Aug-2011 19:00:00'); 
wjdf(01)=datenum('04-Aug-2011 20:00:00');
wjdi(01)=datenum('04-Aug-2011 20:00:00'); 
wjdf(01)=datenum('04-Aug-2011 21:00:00');
wjdi(01)=datenum('04-Aug-2011 21:00:00'); 
wjdf(01)=datenum('04-Aug-2011 22:00:00');
wjdi(01)=datenum('04-Aug-2011 22:00:00'); 
wjdf(01)=datenum('04-Aug-2011 23:00:00');
%
wjdi(01)=datenum('05-Aug-2011 03:00:00'); 
wjdf(01)=datenum('05-Aug-2011 04:00:00');
wjdi(01)=datenum('07-Aug-2011 19:00:00'); 
wjdf(01)=datenum('07-Aug-2011 20:00:00');
wjdi(01)=datenum('07-Aug-2011 23:00:00'); 
wjdf(01)=datenum('07-Aug-2011 24:00:00');
wjdi(01)=datenum('09-Aug-2011 02:00:00'); 
wjdf(01)=datenum('09-Aug-2011 03:00:00');
wjdi(01)=datenum('11-Aug-2011 19:30:00'); 
wjdf(01)=datenum('11-Aug-2011 20:30:00');
wjdi(01)=datenum('01-Sep-2011 03:30:00'); 
wjdf(01)=datenum('01-Sep-2011 04:30:00');
wjdi(01)=datenum('07-Sep-2011 22:10:00'); 
wjdf(01)=datenum('07-Sep-2011 23:10:00');
wjdi(01)=datenum('21-Sep-2011 20:00:00'); 
wjdf(01)=datenum('21-Sep-2011 21:00:00');
wjdi(01)=datenum('20-Oct-2011 20:00:00'); 
wjdf(01)=datenum('20-Oct-2011 21:00:00');
wjdi(01)=datenum('04-Nov-2011 21:00:00'); 
wjdf(01)=datenum('04-Nov-2011 22:00:00');
wjdi(01)=datenum('20-Nov-2011 03:00:00'); 
wjdf(01)=datenum('20-Nov-2011 04:00:00');
wjdi(01)=datenum('17-Dec-2011 22:30:00'); 
wjdf(01)=datenum('17-Dec-2011 23:30:00');
wjdi(01)=datenum('20-Jan-2012 20:30:00'); 
wjdf(01)=datenum('20-Jan-2012 21:30:00');
wjdi(01)=datenum('16-Mar-2012 00:30:00'); 
wjdf(01)=datenum('16-Mar-2012 01:30:00');
wjdi(01)=datenum('22-Mar-2012 19:30:00'); 
wjdf(01)=datenum('22-Mar-2012 20:30:00');
wjdi(01)=datenum('21-Apr-2012 03:30:00'); 
wjdf(01)=datenum('21-Apr-2012 04:30:00');
wjdi(01)=datenum('25-May-2012 22:00:00'); 
wjdf(01)=datenum('25-May-2012 23:00:00');
wjdi(01)=datenum('17-Jun-2012 00:00:00'); 
wjdf(01)=datenum('17-Jun-2012 01:00:00');
wjdi(01)=datenum('25-Aug-2012 02:00:00'); 
wjdf(01)=datenum('25-Aug-2012 04:00:00');
wjdi(01)=datenum('03-Sep-2012 02:00:00'); 
wjdf(01)=datenum('03-Sep-2012 04:00:00');
%wjdi(01)=datenum('04-Sep-2012 23:00:00'); 
%wjdf(01)=datenum('04-Sep-2012 24:00:00');
%wjdi(01)=datenum('05-Sep-2012 22:00:00'); 
%wjdf(01)=datenum('05-Sep-2012 23:00:00');
%wjdi(01)=datenum('08-Sep-2012 00:00:00'); 
%wjdf(01)=datenum('08-Sep-2012 01:00:00');
%wjdi(01)=datenum('13-Sep-2012 00:00:00'); 
%wjdf(01)=datenum('13-Sep-2012 01:00:00');
%wjdi(01)=datenum('19-Sep-2012 22:30:00'); 
%wjdf(01)=datenum('19-Sep-2012 23:30:00');
%wjdi(01)=datenum('27-Sep-2012 22:00:00'); 
%wjdf(01)=datenum('27-Sep-2012 23:00:00');
%wjdi(01)=datenum('07-Oct-2012 00:00:00'); 
%wjdf(01)=datenum('07-Oct-2012 01:00:00');


nw=1;
for w=1:nw
  jdi=wjdi(w);
  jdf=wjdf(w);

  radiofile=['../../sondagens/dat/82332_2011_07_29_00Z.dat']
  read_sonde_Manaus3
  molecular
  read_ascii_Manaus3

  P(:,1)=nanmean(glue355(:,:),2);
  P(:,2)=nanmean(glue387(:,:),2);
  % range bg-corrected signal Pr2(z, lambda)
  for j = 1:2
    Pr2(:,j) = P(:,j).*altsq(:);
  end

  rayleigh_fit_Manaus3
  Klett_Manaus
  Raman_Manaus
  Raman_beta_Manaus
end

%Raman_Manaus
%Raman_beta_Manaus
%