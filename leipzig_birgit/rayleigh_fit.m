% rayleigh_fit_Manus.m 
%
%  scales the molecular signal onto the lidar signal 
% ---------------------------------------------------
%  adaption to Manaus Raman Lidar    BHeese 06/12
%---------------------------------------------------
%  first run the following programs:   
%
%       read_ascii_Manaus.m 
%       read_sonde_Manaus.m
% ---------------------------------------------------
clear maxbin beta_mol alpha_mol tau P_mol Pr2_mol
clear tmpX tmpY tmpZ good minZ maxZ 
clear fval2 a2 b2 err2 smed2 nmask
clear fval a b sa sb chi2red ndf distance 
clear RefBin toerase cloudsize n1 n2
clear RefBinTop mask_mol
% ---------------------------------------------------

%%------------------------------------------------------------------------
%%  INTERPOLATION TO LIDAR SAMPLING ALTITUDES
%%------------------------------------------------------------------------

toextrapolate=1;
nch=length(lambda);

%lidar_altitude=100;
%

if ~exist('lidar_altitude','var')
  disp(['WARNING:: lidar altitude not set!!! assuming ZERO-meters...']);
  lidar_altitude=0;
end

if toextrapolate==0
  % Set maximum lidar bin to highest altitude of sounding 
  maxbin=floor((snd.alt(nlev_snd)-lidar_altitude)/r_bin);

  % Simple linear interpolation within the souding range
  for j=1:nch
    beta_mol(:,j) = interp1(snd.alt, mol.beta_mol_snd(:,j), ... 
			    alt(1:maxbin)+lidar_altitude,...
			    'linear','extrap');
  end
else
  % Set maximum lidar bin to total number of bins
  maxbin = size(P,1);

  % Beta_mol() decays exponentially towards zero with increasing
  % height. Extrapolating it above the highest level in the sounding can
  % lead to negative (unphysical) values. Hence interpolation is done in
  % log() and then the exp() of the result is taken.
  for j=1:nch
    beta_mol(:,j) = exp(interp1(snd.alt, log(mol.beta_mol_snd(:,j)), ... 
			      alt(1:maxbin)+lidar_altitude,...
				'linear','extrap'));
  end
end

%%------------------------------------------------------------------------
%%  RAYLEIGH SIGNAL 
%%------------------------------------------------------------------------

% Instead of interpolating alpha_mol_snd, it is more precise to
% calculate it again using the molecular lidar ratio
for j=1:nch
  alpha_mol(:,j) = beta_mol(:,j).*mol.LR_mol(j); 
end

% Compute molecular optical depth between lidar height and each
% atmospheric level
for j = 1:nch
  for i=1:maxbin
    if i==1
      tau(i,j) = alpha_mol(i,j)*r_bin; 
    else
      tau(i,j) = tau(i-1,j)+(alpha_mol(i-1,j)+alpha_mol(i,j))*r_bin/2; 
    end
  end
end

% Compute "expected" molecular signal. Because it is not divided by
% z^2 this is already range corrected. Note that units are completely
% arbitrary: there is no detector efficiency, no mirror, not even the
% raman cross section! Beta_mol() however, is proportional to the
% nitrogen number density, and hence, proportional to the N2-raman
% back-scatter.
for j = 1:nch
  for i=1:maxbin
    % calculate Pr2_mol in km-1 
    Pr2_mol(i,j)=beta_mol(i,j)*exp(-tau(i,j)-tau(i,1));
    P_mol(i,j)=beta_mol(i,j)*exp(-tau(i,j)-tau(i,1))./altsq(i);
  end
end


%%------------------------------------------------------------------------
%%  LOOP ON CHANNELS
%%------------------------------------------------------------------------

% for elastic and raman channels
for ch=1:nch

  %%------------------------------------------------------------------------
  %%  LOOP ON RAYLEIGH FIT FOR DETERMINATION OF MOLECULAR RANGE
  %%------------------------------------------------------------------------
  if (debug>1)
    disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);
    disp(['% Rayleigh fit for ch= ' num2str(ch) ]);
    disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);
  end
  
  % Select data
  tmpX=P_mol(1:maxbin,ch);
  tmpY=P    (1:maxbin,ch);
  tmpZ=alt (1:maxbin);
  
  % crop regions that we know will never be molecular
  if ~exist('bottomlayer','var')
    bottomlayer=5e3;
  end
  if ~exist('toplayer','var')
    toplayer=10e3;
  end
  tmpY(1:floor(bottomlayer/r_bin))=NaN;
  tmpY(floor(toplayer/r_bin):end)=NaN;
  if (ch>1)
    tmpY(~mask_mol(:,ch-1))=NaN;
  end
    
  % Do a linear fit using all remaining points
  [a, b, fval, sa, sb, chi2red, ndf] = fastfit(tmpX,tmpY);
  
  % update the plot window
  if (debug>2)
    figure(24); clf; hold on;
    plot(tmpZ(~isnan(tmpY)),tmpY(~isnan(tmpY)),'.');
    plot(tmpZ(~isnan(tmpY)),tmpX(~isnan(tmpY))*a+b,'r-');
    %      plot(tmpZ(toerase),tmpY(toerase),'og');
    hold on; grid on;
    xlabel('Z'); ylabel('P, Pmol Fit');
    legend('lidar','mol*A+B');
    title('MOLECULAR POINTS');
    colorbar;
    if (debug>3)
      ginput(1);
    end
  end
  
  % output interaction info for reading
  if (debug>1)
    disp([' ch=' num2str(ch) ...
      ' a=' num2str(a) ' sa=' num2str(sa) ... 
      ' b=' num2str(b) ' sb=' num2str(sb) ... 
      ' chi2red=' num2str(chi2red) ' ndf=' num2str(ndf) ]); 
  end

  %% SET THE REFERENCE BIN
  tmpZ(isnan(tmpY))=NaN;
  [minZ,minI]=min(tmpZ); [maxZ,maxI]=max(tmpZ);
  if (debug>1)
    disp(['lowest used bin #' num2str(minI) ' at height=' num2str(minZ)]);
    disp(['highest used bin #' num2str(maxI) ' at height=' num2str(maxZ)]);
  end
  RefBinTop(ch) = floor(maxZ/r_bin); 
  RefBin(ch) = floor(minZ/r_bin); 

  %% SAVE MOLECULAR MASK
  mask_mol(1:maxbin,ch)=~isnan(tmpY);

  %%------------------------------------------------------------------------
  %%  BACKGROUND CORRECTION
  %%------------------------------------------------------------------------
  if (debug>1)
    disp(['% BG correction for ch= ' num2str(ch) ]);
  end

  % Don't try to remove BG if linear coef. is compatible with bg=0
  if (abs(b/sb)>3)
    bg(ch)=b;
  else
    bg(ch)=0;
  end
  errbg(ch)=sb;
  if (debug>1)
    disp(['ch= ' num2str(ch) '  last BG= ' num2str(bg(ch)) ]);
  end
 
  %% APPLY THE CALCULATED BG
  P  (:,ch) = P(:,ch)-bg(ch);
  n1=find(P(:,ch)<=0, 1);
% hmjb: is it necessary??
%  P(n1:end,ch)=NaN;
  Pr2(:,ch) = P(:,ch).*altsq(:);
  
  %% APPLY THE SCALLING
  P_mol(1:maxbin,ch) = P_mol(1:maxbin,ch)*a;
  Pr2_mol(1:maxbin,ch) = P_mol(1:maxbin,ch).*altsq(1:maxbin);

  %% FORCE THE REFERENCE BIN TO BE MOLECULAR
  P(RefBin(ch),ch)=P_mol(RefBin(ch),ch);
  Pr2(RefBin(ch),ch)=Pr2_mol(RefBin(ch),ch);

end % channel loop

if (debug>1)
  RefBin
  alt(RefBin)*1e-3
end

clear tmpX tmpY tmpZ 

%------------------------------------------------------------------------
%  Plots
%------------------------------------------------------------------------
if (debug<2)
  return
end
%
% -------------
figure(5)
xx=xx0+4*wdx; yy=yy0+4*wdy;
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
% at lidar levels
plot(beta_mol(:,1),(alt(1:maxbin)+lidar_altitude)*1e-3,'b'); 
hold on
if (nch>1)
  plot(beta_mol(:,2),(alt(1:maxbin)+lidar_altitude)*1e-3,'c');
end
% at sounding levels
plot(mol.beta_mol_snd(:,1),snd.alt(:)*1e-3,'bo'); 
if (nch>1)
  plot(mol.beta_mol_snd(:,2),snd.alt(:)*1e-3,'co');
end
xlabel('Lidar Beta / m-1')
ylabel('Altitude a.s.l. / km')
title('beta scatter for sounding','fontsize',[14]) 
legend('355', '387', '355 sonde', '387 sonde');
grid on
hold off
%
%
% -------------
figure(6); clf
xx=xx0+1*wdx; yy=yy0+1*wdy;
set(gcf,'position',[xx,yy,2*wsx,wsy]); % units in pixels!
if (nch>1)
  subplot(1,2,1)
end
plot(Pr2(1:maxbin,1), alt(1:maxbin)*1e-3); 
xlabel('range smooth bg-corr signal','fontsize',[10])  
ylabel('Height a.g.l / km','fontsize',12)
title('Rayleigh Fit 355','fontsize',14)
grid on
hold on
plot(Pr2_mol(1:maxbin,1), alt(1:maxbin)*1e-3,'g','LineWidth',2); 
plot(Pr2(RefBin(1),1), alt(RefBin(1))*1e-3,'r*');
plot(Pr2(RefBinTop(1),1), alt(RefBinTop(1))*1e-3,'r*');
hold off
legend('Lidar', 'Rayleigh Fit', 'Reference Bin'); 
%   
if (nch>1)
  subplot(1,2,2)
  plot(Pr2(1:maxbin,2), alt(1:maxbin)*1e-3); 
  xlabel('range smooth bg-corr signal','fontsize',[10])  
  title('Rayleigh Fit 387','fontsize',14)
  grid on
  hold on
  plot(Pr2_mol(1:maxbin,2), alt(1:maxbin)*1e-3,'g','LineWidth',2); 
  plot(Pr2(RefBin(2),2), alt(RefBin(2))*1e-3,'r*');
  plot(Pr2(RefBinTop(2),2), alt(RefBinTop(2))*1e-3,'r*');
  legend('Lidar', 'Rayleigh Fit', 'Reference Bin'); 
end
%
% -------------
figure(7); clf
xx=xx0+3*wdx; yy=yy0+3*wdy;
set(gcf,'position',[xx,yy,2*wsx,wsy]); % units in pixels!
if (nch>1)
  subplot(1,2,1)
end
plot(log(Pr2(1:maxbin,1)),alt(1:maxbin)*1e-3,'b');    
xlabel('ln range smooth bg-corr signal','fontsize',[10])  
ylabel('Height a.g.l. / km','fontsize',12)
title('Rayleigh fit Ln 355' ,'fontsize',14) 
grid on 
hold on
plot(log(Pr2_mol(1:maxbin,1)),alt(1:maxbin)*1e-3,'g','LineWidth',2);   
plot(log(Pr2(RefBin(1),1)), alt(RefBin(1))*1e-3,'r*');
plot(log(Pr2(RefBinTop(1),1)), alt(RefBinTop(1))*1e-3,'r*');
hold off
%
if (nch>1)
  subplot(1,2,2)
  plot(log(Pr2(1:maxbin,2)),alt(1:maxbin)*1e-3,'b');  
  xlabel('ln range smooth bg-corr signal','fontsize',[10])  
  title('Rayleigh fit Ln 387' ,'fontsize',14) 
  grid on
  hold on
  plot(log(Pr2_mol(1:maxbin,2)),alt(1:maxbin)*1e-3,'g','LineWidth',2);   
  plot(log(Pr2(RefBin(2),2)), alt(RefBin(2))*1e-3,'r*');
  plot(log(Pr2(RefBinTop(2),2)), alt(RefBinTop(2))*1e-3,'r*');
  hold off
end
%
disp('End of program: rayleigh_fit.m')

