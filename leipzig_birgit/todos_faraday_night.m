clear all
addpath('../matlab');
addpath('../sc');

load overlap_narrow.mat

debug=0;

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
%  radiofile=radio{z};
%  read_sonde_Manaus3
%  molecular

  if (z==1)
    %% DRY NO CLOUDS
%    nw=19;
%    wjdi(01)=datenum('28-Jul-2011 23:59:28'); wjdf(01)=datenum('29-Jul-2011 03:52:24');
%    wjdi(02)=datenum('29-Jul-2011 04:06:10'); wjdf(02)=datenum('29-Jul-2011 04:20:17');
%    wjdi(03)=datenum('29-Jul-2011 04:40:24'); wjdf(03)=datenum('29-Jul-2011 05:21:42');
%    wjdi(04)=datenum('29-Jul-2011 18:30:00'); wjdf(04)=datenum('30-Jul-2011 01:19:14');
%    wjdi(05)=datenum('30-Jul-2011 18:30:00'); wjdf(05)=datenum('31-Jul-2011 06:00:00');
%    wjdi(06)=datenum('31-Jul-2011 21:21:42'); wjdf(06)=datenum('01-Aug-2011 04:47:49');
%    wjdi(07)=datenum('01-Aug-2011 19:14:38'); wjdf(07)=datenum('01-Aug-2011 19:20:38');
%    wjdi(08)=datenum('01-Aug-2011 19:35:28'); wjdf(08)=datenum('01-Aug-2011 19:52:24');
%    wjdi(09)=datenum('01-Aug-2011 20:01:35'); wjdf(09)=datenum('01-Aug-2011 20:28:45');
%    wjdi(10)=datenum('01-Aug-2011 20:41:07'); wjdf(10)=datenum('01-Aug-2011 23:26:38');
%    wjdi(11)=datenum('01-Aug-2011 23:58:24'); wjdf(11)=datenum('02-Aug-2011 00:11:07');
%    wjdi(12)=datenum('02-Aug-2011 00:21:00'); wjdf(12)=datenum('02-Aug-2011 01:21:21');
%    wjdi(13)=datenum('02-Aug-2011 22:06:31'); wjdf(13)=datenum('03-Aug-2011 06:00:00');
%    wjdi(14)=datenum('03-Aug-2011 23:08:38'); wjdf(14)=datenum('04-Aug-2011 00:03:00');
%    wjdi(15)=datenum('04-Aug-2011 02:02:17'); wjdf(15)=datenum('04-Aug-2011 02:21:21');
%    wjdi(16)=datenum('04-Aug-2011 02:33:00'); wjdf(16)=datenum('04-Aug-2011 05:30:00');
%    wjdi(17)=datenum('04-Aug-2011 18:30:00'); wjdf(17)=datenum('04-Aug-2011 23:31:56');
%    wjdi(18)=datenum('05-Aug-2011 00:13:14'); wjdf(18)=datenum('05-Aug-2011 02:05:49');
%    wjdi(19)=datenum('05-Aug-2011 02:23:49'); wjdf(19)=datenum('05-Aug-2011 05:40:00');

   % campanha
    nw=19;
    wjdi(01)=datenum('29-Aug-2011 18:30:00'); wjdf(01)=datenum('29-Aug-2011 20:44:07');
    wjdi(02)=datenum('29-Aug-2011 21:54:00'); wjdf(02)=datenum('30-Aug-2011 00:00:00');
    wjdi(03)=datenum('30-Aug-2011 00:00:00'); wjdf(03)=datenum('30-Aug-2011 05:40:00');
    wjdi(04)=datenum('30-Aug-2011 18:30:00'); wjdf(04)=datenum('31-Aug-2011 00:00:00');
    wjdi(05)=datenum('31-Aug-2011 00:00:00'); wjdf(05)=datenum('31-Aug-2011 05:40:00');
    wjdi(06)=datenum('31-Aug-2011 18:30:00'); wjdf(06)=datenum('01-Sep-2011 00:00:00');
    wjdi(07)=datenum('01-Sep-2011 00:00:00'); wjdf(07)=datenum('01-Sep-2011 02:09:31');
    wjdi(08)=datenum('01-Sep-2011 02:59:38'); wjdf(08)=datenum('01-Sep-2011 05:02:28');
    wjdi(09)=datenum('01-Sep-2011 18:30:00'); wjdf(09)=datenum('02-Sep-2011 00:00:00');
    wjdi(10)=datenum('02-Sep-2011 00:57:31'); wjdf(10)=datenum('02-Sep-2011 05:50:00');
    wjdi(11)=datenum('02-Sep-2011 18:30:00'); wjdf(11)=datenum('03-Sep-2011 00:00:00');
    wjdi(12)=datenum('03-Sep-2011 00:00:00'); wjdf(12)=datenum('03-Sep-2011 03:33:31');
    wjdi(13)=datenum('03-Sep-2011 05:18:42'); wjdf(13)=datenum('03-Sep-2011 05:38:28');
    wjdi(14)=datenum('04-Sep-2011 00:00:00'); wjdf(14)=datenum('04-Sep-2011 01:03:52');
    wjdi(15)=datenum('05-Sep-2011 00:00:00'); wjdf(15)=datenum('05-Sep-2011 05:40:00');
    wjdi(16)=datenum('05-Sep-2011 18:30:00'); wjdf(16)=datenum('06-Sep-2011 00:00:00');  
    wjdi(17)=datenum('06-Sep-2011 00:00:00'); wjdf(17)=datenum('06-Sep-2011 05:40:00');
    wjdi(18)=datenum('06-Sep-2011 19:52:35'); wjdf(18)=datenum('07-Sep-2011 00:00:00');
    wjdi(19)=datenum('07-Sep-2011 00:37:03'); wjdf(19)=datenum('07-Sep-2011 02:30:00');

  else
    %% WET - CEU LIMPO
    nw=21;
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

  totfile=0;
%  for w=5:5
  for w=1:nw
    jdi=wjdi(w);
    jdf=wjdf(w);
    disp(['-------------------------------------------------------------------------']);
    disp(['w= ' num2str(w) ' / ' num2str(nw) ' wjdi= ' datestr(jdi) ' wjdf= ' datestr(jdf)])

    radiodir=['../../sondagens/dat/'];
    search_sonde_Manaus
%    radiofile=radio{z};
    read_sonde_Manaus3
    molecular

    read_ascii_Manaus3  
    ns1=size(glue355,1);
    ns2=size(overmean,1);
    if (ns1>ns2)
      overmean(ns2:ns1)=1;
    end
    iq=0;
%    for q=692:nfile
    for q=1:nfile

      q1=q-2;
      if (q1<1)
        q1=1;
      end
      q2=q+2;
      if (q2>nfile)
        q2=nfile;
      end
      P(:,1)=nanmean(glue355(:,q1:q2),2)./overmean(1:ns1);
      Pr2(:,1) = P(:,1).*altsq(:);

      P(:,2)=nanmean(glue387(:,q1:q2),2)./overmean(1:ns1);
      Pr2(:,2) = P(:,2).*altsq(:);

      rayleigh_fit_Manaus4
      Klett_Manaus
      Raman_Manaus
      Raman_beta_Manaus

      klett_beta_aero(:,q+totfile)=beta_klett(:,1);
      klett_alpha_aero(:,q+totfile)=alpha_klett(:,1);
      raman_beta_aero(:,q+totfile)=beta_raman(:,1);
      raman_alpha_aero(:,q+totfile)=alpha_raman2(:,3);
      
      totheads(q+totfile)=heads(q);
      iq=iq+1;
      disp(['======> FINISHED PROFILE #' num2str(q+totfile) ' =  '...
            num2str(iq) ' / ' num2str(nfile) '  w= ' num2str(w) ' / ' num2str(nw)])
    end
    
    totfile=totfile+nfile;
  end
  if (totfile>0)
    out=['beta_klett_' tag{z} '_overlapfinal_set2011_night.mat'];
    save(out,'klett_beta_aero','klett_alpha_aero','raman_beta_aero','raman_alpha_aero','totheads')
  end
end
%
