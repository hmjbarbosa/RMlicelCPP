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
wjdi(01)=datenum('29-Jul-2011 00:00:00'); 
wjdf(01)=datenum('29-Jul-2011 01:00:00');

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