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

radio{1}='./Manaus/82332_110901_00.dat'; tag{1}='dry';
radio{2}='./Manaus/82332_120119_00.dat'; tag{2}='wet';

for z=1:1
  radiofile=radio{z};
  read_sonde_Manaus3
  molecular

  if (z==1)
    %% DRY NO CLOUDS
    nw=36;
    wjdi( 1)=datenum('29-Jul-2011 06:31:30'); wjdf( 1)=datenum('29-Jul-2011 08:19:47');
    wjdi( 2)=datenum('29-Jul-2011 17:30:26'); wjdf( 2)=datenum('29-Jul-2011 22:06:01');
    wjdi( 3)=datenum('30-Jul-2011 06:36:51'); wjdf( 3)=datenum('30-Jul-2011 08:05:22');
    wjdi( 4)=datenum('30-Jul-2011 09:23:12'); wjdf( 4)=datenum('30-Jul-2011 11:03:40');
    wjdi( 5)=datenum('30-Jul-2011 14:15:40'); wjdf( 5)=datenum('30-Jul-2011 14:39:33');
    wjdi( 6)=datenum('30-Jul-2011 15:34:44'); wjdf( 6)=datenum('30-Jul-2011 17:25:30');
    wjdi( 7)=datenum('30-Jul-2011 21:57:47'); wjdf( 7)=datenum('31-Jul-2011 05:15:37');
    wjdi( 8)=datenum('31-Jul-2011 06:48:47'); wjdf( 8)=datenum('31-Jul-2011 11:01:12');
    wjdi( 9)=datenum('31-Jul-2011 21:21:58'); wjdf( 9)=datenum('01-Aug-2011 04:44:44');
    wjdi(10)=datenum('01-Aug-2011 17:21:22'); wjdf(10)=datenum('01-Aug-2011 17:46:05');
    wjdi(11)=datenum('01-Aug-2011 21:04:40'); wjdf(11)=datenum('01-Aug-2011 23:20:08');
    wjdi(12)=datenum('02-Aug-2011 00:24:54'); wjdf(12)=datenum('02-Aug-2011 01:16:22');
    wjdi(13)=datenum('02-Aug-2011 07:17:37'); wjdf(13)=datenum('02-Aug-2011 09:51:12');
    wjdi(14)=datenum('02-Aug-2011 22:06:26'); wjdf(14)=datenum('03-Aug-2011 09:04:15');
    wjdi(15)=datenum('03-Aug-2011 23:09:01'); wjdf(15)=datenum('04-Aug-2011 00:00:54');
  
    wjdi(01)=datenum('28-Jul-2011 23:59:28'); wjdf(01)=datenum('29-Jul-2011 03:52:24');
    wjdi(02)=datenum('29-Jul-2011 04:06:10'); wjdf(02)=datenum('29-Jul-2011 04:20:17');
    wjdi(03)=datenum('29-Jul-2011 04:40:24'); wjdf(03)=datenum('29-Jul-2011 05:21:42');
    wjdi(04)=datenum('29-Jul-2011 06:28:45'); wjdf(04)=datenum('29-Jul-2011 08:28:03');
    wjdi(05)=datenum('29-Jul-2011 10:53:49'); wjdf(05)=datenum('29-Jul-2011 11:03:21');
    wjdi(06)=datenum('29-Jul-2011 17:26:38'); wjdf(06)=datenum('29-Jul-2011 18:03:00');
    wjdi(07)=datenum('29-Jul-2011 17:59:07'); wjdf(07)=datenum('30-Jul-2011 01:19:14');
    wjdi(08)=datenum('30-Jul-2011 06:32:17'); wjdf(08)=datenum('30-Jul-2011 11:30:52');
    wjdi(09)=datenum('30-Jul-2011 14:10:24'); wjdf(09)=datenum('30-Jul-2011 14:41:07');
    wjdi(10)=datenum('30-Jul-2011 14:52:45'); wjdf(10)=datenum('30-Jul-2011 15:16:24');
    wjdi(11)=datenum('30-Jul-2011 15:30:52'); wjdf(11)=datenum('30-Jul-2011 17:36:31');
    wjdi(12)=datenum('30-Jul-2011 17:57:21'); wjdf(12)=datenum('31-Jul-2011 06:04:03');
    wjdi(13)=datenum('31-Jul-2011 05:53:49'); wjdf(13)=datenum('31-Jul-2011 06:20:17');
    wjdi(14)=datenum('31-Jul-2011 06:43:35'); wjdf(14)=datenum('31-Jul-2011 12:03:42');
    wjdi(15)=datenum('31-Jul-2011 21:21:42'); wjdf(15)=datenum('01-Aug-2011 04:47:49');
    wjdi(16)=datenum('01-Aug-2011 17:04:45'); wjdf(16)=datenum('01-Aug-2011 17:13:14');
    wjdi(17)=datenum('01-Aug-2011 17:21:21'); wjdf(17)=datenum('01-Aug-2011 17:48:10');
    wjdi(18)=datenum('01-Aug-2011 18:07:56'); wjdf(18)=datenum('01-Aug-2011 18:15:42');
    wjdi(19)=datenum('01-Aug-2011 19:14:38'); wjdf(19)=datenum('01-Aug-2011 19:20:38');
    wjdi(20)=datenum('01-Aug-2011 19:35:28'); wjdf(20)=datenum('01-Aug-2011 19:52:24');
    wjdi(21)=datenum('01-Aug-2011 20:01:35'); wjdf(21)=datenum('01-Aug-2011 20:28:45');
    wjdi(22)=datenum('01-Aug-2011 20:41:07'); wjdf(22)=datenum('01-Aug-2011 23:26:38');
    wjdi(23)=datenum('01-Aug-2011 23:58:24'); wjdf(23)=datenum('02-Aug-2011 00:11:07');
    wjdi(24)=datenum('02-Aug-2011 00:21:00'); wjdf(24)=datenum('02-Aug-2011 01:21:21');
    wjdi(25)=datenum('02-Aug-2011 07:03:42'); wjdf(25)=datenum('02-Aug-2011 09:58:03');
    wjdi(26)=datenum('02-Aug-2011 10:03:42'); wjdf(26)=datenum('02-Aug-2011 11:07:14');
    wjdi(27)=datenum('02-Aug-2011 22:06:31'); wjdf(27)=datenum('03-Aug-2011 10:13:56');
    wjdi(28)=datenum('03-Aug-2011 23:08:38'); wjdf(28)=datenum('04-Aug-2011 00:03:00');
    wjdi(29)=datenum('04-Aug-2011 02:02:17'); wjdf(29)=datenum('04-Aug-2011 02:21:21');
    wjdi(30)=datenum('04-Aug-2011 02:33:00'); wjdf(30)=datenum('04-Aug-2011 09:35:28');
    wjdi(31)=datenum('04-Aug-2011 16:36:31'); wjdf(31)=datenum('04-Aug-2011 16:45:42');
    wjdi(32)=datenum('04-Aug-2011 16:48:31'); wjdf(32)=datenum('04-Aug-2011 16:55:56');
    wjdi(33)=datenum('04-Aug-2011 17:14:38'); wjdf(33)=datenum('04-Aug-2011 17:40:45');
    wjdi(34)=datenum('04-Aug-2011 17:43:35'); wjdf(34)=datenum('04-Aug-2011 23:31:56');
    wjdi(35)=datenum('05-Aug-2011 00:13:14'); wjdf(35)=datenum('05-Aug-2011 02:05:49');
    wjdi(36)=datenum('05-Aug-2011 02:23:49'); wjdf(36)=datenum('05-Aug-2011 06:02:38');

  else
    %% WET - CEU LIMPO
    nw=21;
    wjdi( 1)=datenum('20-Jan-2012 17:15:21'); wjdf( 1)=datenum('20-Jan-2012 22:32:17');
    wjdi( 2)=datenum('21-Jan-2012 08:42:52'); wjdf( 2)=datenum('21-Jan-2012 09:09:21');
    wjdi( 3)=datenum('23-Jan-2012 08:13:56'); wjdf( 3)=datenum('23-Jan-2012 09:36:52');
    wjdi( 4)=datenum('24-Jan-2012 19:36:10'); wjdf( 4)=datenum('24-Jan-2012 20:58:45');
    wjdi( 5)=datenum('24-Jan-2012 20:59:49'); wjdf( 5)=datenum('25-Jan-2012 00:03:00');
  
    wjdi(01)=datenum('20-Jan-2012 14:06:31'); wjdf(01)=datenum('20-Jan-2012 14:08:17');
    wjdi(02)=datenum('20-Jan-2012 14:36:10'); wjdf(02)=datenum('20-Jan-2012 14:43:14');
    wjdi(03)=datenum('20-Jan-2012 14:57:00'); wjdf(03)=datenum('20-Jan-2012 15:05:28');
    wjdi(04)=datenum('20-Jan-2012 15:24:31'); wjdf(04)=datenum('20-Jan-2012 15:30:52');
    wjdi(05)=datenum('20-Jan-2012 15:40:45'); wjdf(05)=datenum('20-Jan-2012 15:47:49');
    wjdi(06)=datenum('20-Jan-2012 16:07:56'); wjdf(06)=datenum('20-Jan-2012 16:22:24');
    wjdi(07)=datenum('20-Jan-2012 16:37:14'); wjdf(07)=datenum('20-Jan-2012 16:55:56');
    wjdi(08)=datenum('20-Jan-2012 17:13:14'); wjdf(08)=datenum('20-Jan-2012 18:00:00');
    wjdi(09)=datenum('20-Jan-2012 18:00:00'); wjdf(09)=datenum('20-Jan-2012 22:35:49');
    wjdi(10)=datenum('21-Jan-2012 04:11:49'); wjdf(10)=datenum('21-Jan-2012 04:18:10');
    wjdi(11)=datenum('21-Jan-2012 08:36:52'); wjdf(11)=datenum('21-Jan-2012 09:11:07');
    wjdi(12)=datenum('21-Jan-2012 15:10:03'); wjdf(12)=datenum('21-Jan-2012 15:15:42');
    wjdi(13)=datenum('22-Jan-2012 14:55:56'); wjdf(13)=datenum('22-Jan-2012 15:02:38');
    wjdi(14)=datenum('22-Jan-2012 15:29:07'); wjdf(14)=datenum('22-Jan-2012 15:33:00');
    wjdi(15)=datenum('22-Jan-2012 16:24:52'); wjdf(15)=datenum('22-Jan-2012 16:29:49');
    wjdi(16)=datenum('22-Jan-2012 17:46:03'); wjdf(16)=datenum('22-Jan-2012 17:52:03');
    wjdi(17)=datenum('22-Jan-2012 18:49:14'); wjdf(17)=datenum('22-Jan-2012 18:55:35');
    wjdi(18)=datenum('23-Jan-2012 08:08:17'); wjdf(18)=datenum('23-Jan-2012 09:43:14');
    wjdi(19)=datenum('23-Jan-2012 10:51:21'); wjdf(19)=datenum('23-Jan-2012 10:58:45');
    wjdi(20)=datenum('24-Jan-2012 19:26:38'); wjdf(20)=datenum('25-Jan-2012');
    wjdi(21)=datenum('25-Jan-2012 19:07:14'); wjdf(21)=datenum('25-Jan-2012 19:17:49');

  end
%  x=0;
%  for w=1:nw
%    jdi=wjdi(w);
%    jdf=wjdf(w);
%    x=x+jdf-jdi;
%  end
%  return
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
    
    totfile=totfile+nfile;
  end
  if (totfile>0)
    out=['beta_klett_' tag{z} '.mat'];
    save(out,'klett_beta_aero','klett_alpha_aero','totheads')
  end
end
%
