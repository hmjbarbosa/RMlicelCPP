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
read_sonde_Manaus
molecular

%WET - CEU LIMPO
%nw=7;
%jdi=datenum('09-Jan-2012 06:37:14'); jdf=datenum('09-Jan-2012 08:24:10')
%jdi=datenum('09-Jan-2012 02:03:21'); jdf=datenum('09-Jan-2012 03:07:56')
%jdi=datenum('08-Jan-2012 19:01:14'); jdf=datenum('08-Jan-2012 19:19:35')
%jdi=datenum('08-Jan-2012 18:12:10'); jdf=datenum('08-Jan-2012 18:41:07')
%jdi=datenum('08-Jan-2012 14:22:45'); jdf=datenum('08-Jan-2012 14:29:28')
%jdi=datenum('08-Jan-2012 14:05:28'); jdf=datenum('08-Jan-2012 14:11:07')
%wjdi( 1)=datenum('20-Jan-2012 17:15:21'); wjdf( 1)=datenum('20-Jan-2012 22:32:17');
%wjdi( 2)=datenum('21-Jan-2012 08:42:52'); wjdf( 2)=datenum('21-Jan-2012 09:09:21');
%wjdi( 3)=datenum('23-Jan-2012 08:13:56'); wjdf( 3)=datenum('23-Jan-2012 09:36:52');
%wjdi( 4)=datenum('24-Jan-2012 19:36:10'); wjdf( 4)=datenum('24-Jan-2012 20:58:45');
%wjdi( 5)=datenum('24-Jan-2012 20:59:49'); wjdf( 5)=datenum('25-Jan-2012 00:03:00');
%wjdi( 6)=datenum('28-Jan-2012 16:34:45'); wjdf( 6)=datenum('28-Jan-2012 17:49:35')
%
%%WET - NUVENS, SEM CHUVA, ACIMA DE 4KM
%nw=19
%wjdi( 1)=datenum('20-Jan-2012 04:35:49'); wjdf( 1)=datenum('20-Jan-2012 05:58:03');
%wjdi( 2)=datenum('20-Jan-2012 05:58:45'); wjdf( 2)=datenum('20-Jan-2012 07:17:28');
%wjdi( 3)=datenum('20-Jan-2012 22:39:00'); wjdf( 3)=datenum('20-Jan-2012 23:00:31');
%wjdi( 4)=datenum('21-Jan-2012 02:32:38'); wjdf( 4)=datenum('21-Jan-2012 05:59:07');
%wjdi( 5)=datenum('21-Jan-2012 05:57:21'); wjdf( 5)=datenum('21-Jan-2012 09:03:21');
%wjdi( 6)=datenum('21-Jan-2012 17:58:24'); wjdf( 6)=datenum('21-Jan-2012 18:24:10');
%wjdi( 7)=datenum('22-Jan-2012 18:20:38'); wjdf( 7)=datenum('22-Jan-2012 18:35:49');
%wjdi( 8)=datenum('22-Jan-2012 22:24:10'); wjdf( 8)=datenum('22-Jan-2012 22:59:49');
%wjdi( 9)=datenum('23-Jan-2012 05:35:07'); wjdf( 9)=datenum('23-Jan-2012 06:00:52');
%wjdi(10)=datenum('23-Jan-2012 05:58:24'); wjdf(10)=datenum('23-Jan-2012 09:29:07');
%wjdi(11)=datenum('23-Jan-2012 16:53:07'); wjdf(11)=datenum('23-Jan-2012 18:00:10');
%wjdi(12)=datenum('23-Jan-2012 21:52:03'); wjdf(12)=datenum('23-Jan-2012 23:38:17');
%wjdi(13)=datenum('24-Jan-2012 06:05:07'); wjdf(13)=datenum('24-Jan-2012 08:58:45');
%wjdi(14)=datenum('24-Jan-2012 18:13:56'); wjdf(14)=datenum('24-Jan-2012 19:25:56');
%wjdi(15)=datenum('25-Jan-2012 00:03:42'); wjdf(15)=datenum('25-Jan-2012 02:45:42');
%wjdi(16)=datenum('25-Jan-2012 19:09:42'); wjdf(16)=datenum('25-Jan-2012 21:14:38');
%wjdi(17)=datenum('26-Jan-2012 00:10:45'); wjdf(17)=datenum('26-Jan-2012 01:41:07');
%wjdi(18)=datenum('26-Jan-2012 02:33:21'); wjdf(18)=datenum('26-Jan-2012 02:58:24');
%wjdi(19)=datenum('26-Jan-2012 16:03:42'); wjdf(19)=datenum('26-Jan-2012 16:51:21');
%
%% DRY NO CLOUDS
nw=21;
wjdi( 1)=datenum('29-Jul-2011 06:31:30'); wjdf( 1)=datenum('29-Jul-2011 07:19:47');
wjdi( 2)=datenum('29-Jul-2011 07:19:48'); wjdf( 2)=datenum('29-Jul-2011 08:19:47');
wjdi( 3)=datenum('29-Jul-2011 17:30:26'); wjdf( 3)=datenum('29-Jul-2011 18:00:05');
wjdi( 4)=datenum('29-Jul-2011 18:00:37'); wjdf( 4)=datenum('29-Jul-2011 22:06:01');
wjdi( 5)=datenum('30-Jul-2011 06:36:51'); wjdf( 5)=datenum('30-Jul-2011 08:05:22');
wjdi( 6)=datenum('30-Jul-2011 09:23:12'); wjdf( 6)=datenum('30-Jul-2011 11:03:40');
wjdi( 7)=datenum('30-Jul-2011 14:15:40'); wjdf( 7)=datenum('30-Jul-2011 14:39:33');
wjdi( 8)=datenum('30-Jul-2011 15:34:44'); wjdf( 8)=datenum('30-Jul-2011 17:25:30');
wjdi( 9)=datenum('30-Jul-2011 21:57:47'); wjdf( 9)=datenum('30-Jul-2011 23:59:15');
wjdi(10)=datenum('30-Jul-2011 23:50:44'); wjdf(10)=datenum('31-Jul-2011 05:15:37');
wjdi(11)=datenum('31-Jul-2011 06:48:47'); wjdf(11)=datenum('31-Jul-2011 11:01:12');
wjdi(12)=datenum('31-Jul-2011 21:21:58'); wjdf(12)=datenum('01-Aug-2011 00:03:47');
wjdi(13)=datenum('31-Jul-2011 23:59:22'); wjdf(13)=datenum('01-Aug-2011 04:44:44');
wjdi(14)=datenum('01-Aug-2011 17:21:22'); wjdf(14)=datenum('01-Aug-2011 17:46:05');
wjdi(15)=datenum('01-Aug-2011 21:04:40'); wjdf(15)=datenum('01-Aug-2011 23:20:08');
wjdi(16)=datenum('02-Aug-2011 00:24:54'); wjdf(16)=datenum('02-Aug-2011 01:16:22');
wjdi(17)=datenum('02-Aug-2011 07:17:37'); wjdf(17)=datenum('02-Aug-2011 09:51:12');
wjdi(18)=datenum('02-Aug-2011 22:06:26'); wjdf(18)=datenum('03-Aug-2011 00:00:05');
wjdi(19)=datenum('02-Aug-2011 23:59:22'); wjdf(19)=datenum('03-Aug-2011 06:01:44');
wjdi(20)=datenum('03-Aug-2011 05:59:22'); wjdf(20)=datenum('03-Aug-2011 09:04:15');
wjdi(21)=datenum('03-Aug-2011 23:09:01'); wjdf(21)=datenum('04-Aug-2011 00:00:54');
%wjdi(22)=datenum('05-Aug-2011 07:28:19'); wjdf(22)=datenum('05-Aug-2011 08:33:22');
%
%% DRY, NO RAIN, CLOUDS ABOVE 4KM
%nw=10;
%wjdi( 1)=datenum('30-Jul-2011 01:26:17'); wjdf( 1)=datenum('30-Jul-2011 06:00:31')
%wjdi( 2)=datenum('01-Aug-2011 04:55:56'); wjdf( 2)=datenum('01-Aug-2011 06:02:17')
%wjdi( 3)=datenum('01-Aug-2011 05:59:07'); wjdf( 3)=datenum('01-Aug-2011 11:02:17')
%wjdi( 4)=datenum('01-Aug-2011 17:59:49'); wjdf( 4)=datenum('01-Aug-2011 20:49:14')
%wjdi( 5)=datenum('02-Aug-2011 01:24:10'); wjdf( 5)=datenum('02-Aug-2011 06:02:17')
%wjdi( 6)=datenum('02-Aug-2011 06:06:10'); wjdf( 6)=datenum('02-Aug-2011 06:59:28')
%wjdi( 7)=datenum('04-Aug-2011 17:20:17'); wjdf( 7)=datenum('04-Aug-2011 18:02:38')
%wjdi( 8)=datenum('04-Aug-2011 17:57:00'); wjdf( 8)=datenum('04-Aug-2011 23:28:45')
%wjdi( 9)=datenum('05-Aug-2011 02:32:38'); wjdf( 9)=datenum('05-Aug-2011 05:43:35')
%wjdi(10)=datenum('05-Aug-2011 05:58:45'); wjdf(10)=datenum('05-Aug-2011 07:27:00')

totfile=0;
for w=1:nw
  jdi=wjdi(w);
  jdf=wjdf(w);

  read_ascii_Manaus3

  for q=1:nfile
    P(:,1)=glue355(:,q);
    Pr2(:,1) = P(:,1).*altsq(:);

    rayleigh_fit_Manaus3
    Klett_Manaus
    disp([num2str(q+totfile)])
    klett_beta_aero(:,q+totfile)=beta_aerosol(1,:);
    klett_alpha_aero(:,q+totfile)=alpha_aerosol(1,:);
    totheads(q+totfile)=heads(q);
  end
    
  save('beta_klett.mat','klett_beta_aero','klett_alpha_aero','totheads')
  totfile=totfile+nfile;
end
%
