clear all

% windows' size
wsx=250; wsy=650; 
% displacement for next window
wdx=260; xx0=-wsx;
% start position
wdy=0;   yy0=50;

% read physics constants
cte=constants(400.);

wjdi(01)=datenum('24-Aug-2014 19:00:00'); 
wjdf(01)=datenum('24-Aug-2014 21:00:00');

debug=3;

radiodir='/Users/hbarbosa/SkyDrive/sondagens2/dat';
datain='/Users/hbarbosa/DATA/Tiwa_LIDAR';
lambda=[0.532 0.607]*1e-6; % [m]

nw=1;
for w=1:nw
  jdi=wjdi(w);
  jdf=wjdf(w);

  %radiofile=search_sonde_Manaus(radiodir,'82332',(jdi+jdf)/2.);
  radiofile=[radiodir '/82332_2014_08_25_00z.dat'];
  read_sonde

  molecular

  % modificar este read_ascii para nao fazer a media de tudo, fazer
  % medias de 5-min ou inverter todos os perfis individuais
  read_ascii_Manaus2

  bottomlayer=6.5e3;%m
  toplayer=10e3;%m

  debug=0;
  for k=1:5%nfile
    % aqui poderia colocar a #1 e #2
    P(:,1)=chphy(1).data(:,k);
    P(:,2)=chphy(3).data(:,k);

    rayleigh_fit_Manaus3
    Klett_Manaus
    
    save_beta_klett(:,k) = beta_klett(:,1);
    save_alpha_klett(:,k) = alpha_klett(:,1);

  end
  
%  Raman_Manaus
%  Raman_beta_Manaus
  
end

%