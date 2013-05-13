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

wjdi(01)=datenum('11-Jul-2011 21:00:00'); wjdf(01)=datenum('29-Jul-2011 22:00:00');
wjdi(01)=datenum('11-Jul-2011 22:00:00'); wjdf(01)=datenum('29-Jul-2011 23:00:00');
wjdi(01)=datenum('11-Jul-2011 23:00:00'); wjdf(01)=datenum('29-Jul-2011 24:00:00');
wjdi(01)=datenum('12-Jul-2011 00:00:00'); wjdf(01)=datenum('29-Jul-2011 01:00:00');
wjdi(01)=datenum('12-Jul-2011 01:00:00'); wjdf(01)=datenum('29-Jul-2011 02:00:00');
wjdi(01)=datenum('12-Jul-2011 02:00:00'); wjdf(01)=datenum('29-Jul-2011 03:00:00');
wjdi(01)=datenum('12-Jul-2011 03:00:00'); wjdf(01)=datenum('29-Jul-2011 04:00:00');
wjdi(01)=datenum('12-Jul-2011 04:00:00'); wjdf(01)=datenum('29-Jul-2011 05:00:00');
wjdi(01)=datenum('12-Jul-2011 05:00:00'); wjdf(01)=datenum('29-Jul-2011 06:00:00');


wjdi(01)=datenum('29-Jul-2011 01:00:00'); wjdf(01)=datenum('29-Jul-2011 02:00:00');
wjdi(02)=datenum('29-Jul-2011 23:00:00'); wjdf(02)=datenum('29-Jul-2011 24:00:00');
wjdi(03)=datenum('30-Jul-2011 20:00:00'); wjdf(03)=datenum('30-Jul-2011 21:00:00');
wjdi(04)=datenum('30-Jul-2011 23:00:00'); wjdf(04)=datenum('30-Jul-2011 24:00:00');
wjdi(05)=datenum('31-Jul-2011 02:00:00'); wjdf(05)=datenum('31-Jul-2011 03:00:00');
wjdi(06)=datenum('01-Aug-2011 22:00:00'); wjdf(06)=datenum('01-Aug-2011 23:00:00');
wjdi(07)=datenum('02-Aug-2011 22:00:00'); wjdf(07)=datenum('02-Aug-2011 23:00:00');
wjdi(08)=datenum('04-Aug-2011 19:00:00'); wjdf(08)=datenum('04-Aug-2011 20:00:00');
wjdi(09)=datenum('04-Aug-2011 20:00:00'); wjdf(09)=datenum('04-Aug-2011 21:00:00');
wjdi(10)=datenum('04-Aug-2011 21:00:00'); wjdf(10)=datenum('04-Aug-2011 22:00:00');
wjdi(11)=datenum('04-Aug-2011 22:00:00'); wjdf(11)=datenum('04-Aug-2011 23:00:00');
wjdi(12)=datenum('05-Aug-2011 03:00:00'); wjdf(12)=datenum('05-Aug-2011 04:00:00');
wjdi(13)=datenum('07-Aug-2011 19:00:00'); wjdf(13)=datenum('07-Aug-2011 20:00:00');
wjdi(14)=datenum('07-Aug-2011 23:00:00'); wjdf(14)=datenum('07-Aug-2011 24:00:00');
wjdi(15)=datenum('09-Aug-2011 02:00:00'); wjdf(15)=datenum('09-Aug-2011 03:00:00');
wjdi(16)=datenum('11-Aug-2011 19:30:00'); wjdf(16)=datenum('11-Aug-2011 20:30:00');
wjdi(17)=datenum('01-Sep-2011 03:30:00'); wjdf(17)=datenum('01-Sep-2011 04:30:00');
wjdi(18)=datenum('07-Sep-2011 22:10:00'); wjdf(18)=datenum('07-Sep-2011 23:10:00');
wjdi(19)=datenum('21-Sep-2011 20:00:00'); wjdf(19)=datenum('21-Sep-2011 21:00:00');
%wjdi(20)=datenum('20-Oct-2011 24:00:00'); wjdf(20)=datenum('20-Oct-2011 30:00:00');%%
wjdi(21)=datenum('04-Nov-2011 21:00:00'); wjdf(21)=datenum('04-Nov-2011 22:00:00');
wjdi(22)=datenum('20-Nov-2011 03:00:00'); wjdf(22)=datenum('20-Nov-2011 04:00:00');
wjdi(23)=datenum('17-Dec-2011 22:30:00'); wjdf(23)=datenum('17-Dec-2011 23:30:00');
wjdi(24)=datenum('20-Jan-2012 20:30:00'); wjdf(24)=datenum('20-Jan-2012 21:30:00');
wjdi(25)=datenum('16-Mar-2012 00:30:00'); wjdf(25)=datenum('16-Mar-2012 01:30:00');
wjdi(26)=datenum('22-Mar-2012 19:30:00'); wjdf(26)=datenum('22-Mar-2012 20:30:00');%%
%wjdi(27)=datenum('21-Apr-2012 04:15:00'); wjdf(27)=datenum('21-Apr-2012 05:15:00');%%
%wjdi(28)=datenum('25-May-2012 22:00:00'); wjdf(28)=datenum('25-May-2012 23:00:00');%%
wjdi(29)=datenum('17-Jun-2012 00:00:00'); wjdf(29)=datenum('17-Jun-2012 01:00:00');
wjdi(30)=datenum('25-Aug-2012 02:00:00'); wjdf(30)=datenum('25-Aug-2012 04:00:00');
wjdi(31)=datenum('03-Sep-2012 02:00:00'); wjdf(31)=datenum('03-Sep-2012 04:00:00');
wjdi(32)=datenum('04-Sep-2012 23:00:00'); wjdf(32)=datenum('04-Sep-2012 24:00:00');
wjdi(33)=datenum('05-Sep-2012 22:00:00'); wjdf(33)=datenum('05-Sep-2012 23:00:00');
wjdi(34)=datenum('08-Sep-2012 00:00:00'); wjdf(34)=datenum('08-Sep-2012 01:00:00');
wjdi(35)=datenum('13-Sep-2012 00:00:00'); wjdf(35)=datenum('13-Sep-2012 01:00:00');
wjdi(36)=datenum('19-Sep-2012 22:30:00'); wjdf(36)=datenum('19-Sep-2012 23:30:00');
wjdi(37)=datenum('27-Sep-2012 22:00:00'); wjdf(37)=datenum('27-Sep-2012 23:00:00');
wjdi(38)=datenum('07-Oct-2012 00:00:00'); wjdf(38)=datenum('07-Oct-2012 01:00:00');

nw=38;
%for w=1:nw
for w=6:6
  jdi=wjdi(w);
  jdf=wjdf(w);

  radiodir=['../../sondagens/dat/'];
  search_sonde_Manaus
%  radiofile=['../../sondagens/dat/82332_2011_07_29_00Z.dat']
  read_sonde_Manaus3
  molecular
  read_ascii_Manaus3
  if (nfile==0)
    break
  end

  tryagain=1;
  bottomlayer=8;
  problem=0;
  while (tryagain)
    
    P(:,1)=nansum(glue355(:,:),2);
    P(:,2)=nansum(glue387(:,:),2);
    for j = 1:2
      Pr2(:,j) = P(:,j).*altsq(:);
    end

    rayleigh_fit_Manaus3
    Klett_Manaus
    Raman_Manaus
    Raman_beta_Manaus

    for i=RefBin(1):-1:100
      if all(beta_raman(i-20:i) < 0)
        tryagain=1;
        disp(['WARN WARN WARN ---- WARN WARN WARN'])
        disp(['bottom layer at: ' num2str(bottomlayer) 'km too high!!'])
        bottomlayer=bottomlayer-0.5;
        break
      else
        tryagain=0;
      end
    end
    
    if (bottomlayer<4)
      problem=1;
      break
    end
  end
  
%  if (problem)
%    finalover(1:3000,w)=NaN;
%    continue;
%  end

  n=RefBin(1);
  for i=1:RefBin(1)
    if (beta_raman(i)<beta_klett(i))
      break;
    end
  end
  n=i+133; % add 1km
  Ulla_Overlap
  
  finalover(1:3000,w)=1;
  finalover(1:n,w)=overlap(1:n);
end

%