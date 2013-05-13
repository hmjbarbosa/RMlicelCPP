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

%% LIST OF GOOD 1-HR PERIODS
list_overlap_select
nw=numel(wjdi);

for w=303:nw
%for w=224:224
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
    % check if molecular region is long enough
    if any(alt(RefBinTop-RefBin) < 5000)
      tryagain=1;
      disp(['WARN WARN WARN ---- WARN WARN WARN'])
      disp(['molecular region too short'])
      % allow a 500m lower rayleight-fit for fixing the negative
      % part in beta_raman
      bottomlayer=bottomlayer-0.5;
      if (bottomlayer<4)
        break
      else
        continue
      end
    else
      tryagain=0;
    end

    Klett_Manaus
    Raman_Manaus
    Raman_beta_Manaus
  
    % check if Raman solution is stable, i.e., if it does not
    % become negative before going positive
    for i=RefBin(1):-1:100
      if all(beta_raman(i-20:i) < 0)
        tryagain=1;
        disp(['WARN WARN WARN ---- WARN WARN WARN'])
        disp(['bottom layer at: ' num2str(bottomlayer) 'km too high!!'])
        % allow a 500m lower rayleight-fit for fixing the negative
        % part in beta_raman
        bottomlayer=bottomlayer-0.5;
        break
      else
        tryagain=0;
      end
    end
  
    % don't try to go lower than 4km
    if (bottomlayer<4)
      problem=1;
      break
    end
  end
  
  % the overlap should be calculated near the bins it has effect.
  % here 1km above the first point where beta_klett > beta_raman is
  % used.
  n=RefBin(1);
  for i=1:RefBin(1)
    if (beta_raman(i)<beta_klett(i))
      break;
    end
  end
  n=min(i+133,RefBin(1)); % add 1km
  
  Ulla_Overlap
  
  finalRefBin(w,:)=RefBin;
  finalRefBinTop(w,:)=RefBinTop;
  finalN(w)=n;
  finalBottomlayer(w)=bottomlayer;
  finalover(1:1000,w)=1;
  finalover(1:n,w)=overlap(1:n);
  finalalt(1:1000)=alt(1:1000);
  finaljdi(w)=jdi;
  finaljdf(w)=jdf;
  finalradio{w}=radiofile;
  finalminjdi(w)=minjdi;
  finalhascloud(w)=hascloud;
  finalbg(w,:)=bg;
  finalerrbg(w,:)=errbg;
  
  save('list_overlap_data4.mat','finalRefBin','finalRefBinTop', ...
       'finalN','finalBottomlayer','finalover','finalover', ...
       'finalalt','finaljdi','finaljdf','finalradio', ...
       'finalminjdi','finalhascloud','finalbg','finalerrbg');
end

%