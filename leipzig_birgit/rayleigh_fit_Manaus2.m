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
clear pmin pmax pave bg1 bg2 nBG 
clear tmpX tmpY tmpZ tmpXX tmpYY
clear fval a b sa sb chi2red ndf distance nmask
clear out nn RefBin
% ---------------------------------------------------

DEBUG=2;
error=0;

%%------------------------------------------------------------------------
%%  INTERPOLATION TO LIDAR SAMPLING ALTITUDES
%%------------------------------------------------------------------------

toextrapolate=1;

lidar_altitude=100;

if toextrapolate==0
  % Set maximum lidar bin to highest altitude of sounding 
  maxbin=floor((alt_snd(nlev_snd)-lidar_altitude)*1e-3/r_bin);

  % Simple linear interpolation within the souding range
  beta_mol(:,1) = interp1(alt_snd, beta_mol_snd(:,1), ... 
			  alt(1:maxbin)+lidar_altitude,'linear','extrap');
  beta_mol(:,2) = interp1(alt_snd, beta_mol_snd(:,2), ...
			  alt(1:maxbin)+lidar_altitude,'linear','extrap');
else
  % Set maximum lidar bin to total number of bins
  maxbin = size(Pr2,1);

  % Beta_mol() decays exponentially towards zero with increasing
  % height. Extrapolating it above the highest level in the sounding can
  % lead to negative (unphysical) values. Hence interpolation is done in
  % log() and then the exp() of the result is taken.
  beta_mol(:,1) = exp(interp1(alt_snd, log(beta_mol_snd(:,1)), ... 
			      alt(1:maxbin)+lidar_altitude,'linear','extrap'));
  beta_mol(:,2) = exp(interp1(alt_snd, log(beta_mol_snd(:,2)), ...
			      alt(1:maxbin)+lidar_altitude,'linear','extrap'));
end

%%------------------------------------------------------------------------
%%  RAYLEIGH SIGNAL 
%%------------------------------------------------------------------------

% Instead of interpolating alpha_mol_snd, it is more precise to
% calculate it again using the molecular lidar ratio
alpha_mol(:,1) = beta_mol(:,1).*LR_mol(1); 
alpha_mol(:,2) = beta_mol(:,2).*LR_mol(2); 

% Compute molecular optical depth between lidar height and each
% atmospheric level
for j = 1:2
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
for j = 1:2
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
for ch=1:2

  %%------------------------------------------------------------------------
  %%  LOOP ON RAYLEIGH FIT FOR DETERMINATION OF MOLECULAR RANGE
  %%------------------------------------------------------------------------
  disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);
  disp(['% Rayleigh fit for ch= ' num2str(ch) ]);
  disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);

  % Select data
  tmpX=P_mol(1:maxbin,ch);
  tmpY=P    (1:maxbin,ch);
  tmpZ =alt (1:maxbin)*1e-3;
  
  % plot to know what is going on
  figure(23); clf;
  scatter(log10(tmpX),log10(tmpY),10,tmpZ);
  xlabel('log10(Pmol)'); ylabel('log(P)');
  hold on; grid on; colorbar;
  title('ALL POINTS');

  % crop regions that we know will never be molecular
  % for now: 5km
  tmpY(1:floor(4/r_bin))=NaN;
  tmpY(floor(11/r_bin):maxbin)=NaN;
  
  % Initialize counter for the number of NaN data points
  nmask=sum(isnan(tmpY)); nmask_old=-1;
    
  % Convergence will stop when no more points are removed based on the
  % criteria stablished below
  iter=0;
  while(nmask_old ~= nmask)
    nmask_old=nmask;
    
    % Do a linear fit using all remaining points
    [a, b, fval, sa, sb, chi2red, ndf] = fastfit(tmpX,tmpY);
    % For each point, exclude those which are too far away 
    %
    % NOTE1: this exclusion does not depend on having the BG corrected
    % because it is a linear proportion between P and P_mol
    %
    % NOTE2: it would be better to draw the confidence curves
    % (hyperbola) as the error is larger near the ends. Here
    % sqrt(chi2red) is used as a measure of the uncertainty.
    distance=abs(tmpY-fval)./sqrt(chi2red); 
    tmpY(distance>2)=nan;
    
%    for i=2:maxbin-1
%      if isnan(tmpY(i-1)) & isnan(tmpY(i+1))
%	tmpY(i)=nan;
%      end
%    end
    
    % Recompute the mask counter
    nmask=sum(isnan(tmpY));
    
    % output interaction info for reading
    disp(['iter= ' num2str(iter) ' nmask=' num2str(nmask) ...
	  ' a=' num2str(a) ' sa=' num2str(sa) ... 
	  ' b=' num2str(b) ' sb=' num2str(sb) ... 
	  ' chi2red=' num2str(chi2red) ' ndf=' num2str(ndf) ]); 
    
    % update the plot window
    figure(24); clf; hold off;
    scatter(tmpX(~isnan(tmpY)),tmpY(~isnan(tmpY)),10,tmpZ(~isnan(tmpY)));
    hold on; grid on;
    plot(tmpX(~isnan(tmpY)),tmpX(~isnan(tmpY))*a+b,'r');
    xlabel('Pmol'); ylabel('P and Fit');
    
    iter=iter+1; 
  end

  figure(24); clf; hold off;
  scatter(tmpX(~isnan(tmpY)),tmpY(~isnan(tmpY)),10,tmpZ(~isnan(tmpY)));
  hold on; grid on;
  plot(tmpX(~isnan(tmpY)),tmpX(~isnan(tmpY))*a+b,'r');
  xlabel('Pmol'); ylabel('P and Fit');
  title('MOLECULAR POINTS');
  colorbar;

  figure(23); plot(log10(P_mol(1:maxbin,ch)),...
		   log10(P_mol(1:maxbin,ch)*a+b),'r');
  
  %% SET THE REFERENCE BIN
  tmpZ(isnan(tmpY))=NaN;
  [minZ,minI]=min(tmpZ); [maxZ,maxI]=max(tmpZ);
  disp(['lowest used bin #' num2str(minI) ' at height=' num2str(minZ) ]);
  disp(['highest used bin #' num2str(maxI) ' at height=' num2str(maxZ) ]);
  RefBin(ch) = floor((minZ+maxZ)*0.5/r_bin); 
  
  %% SAVE MOLECULAR MASK
  mask_mol(1:maxbin,ch)=~isnan(tmpY);

  %%------------------------------------------------------------------------
  %%  LOOP ON BACKGROUND CORRECTION
  %%------------------------------------------------------------------------
  disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);
  disp(['% BG correction for ch= ' num2str(ch) ]);
  disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);

  nBG=1; 
  bg=0;
  while(abs(b/sb)>1 || abs(b/bg) > 1e-6)

    bg=bg+b;
    tmpY=tmpY-b;
    
    disp(['ch= ' num2str(ch) '  trying BG= ' num2str(bg) ]);

    [a, b, fval, sa, sb, chi2red, ndf] = fastfit(tmpX,tmpY);

    disp(['nBG= ' num2str(nBG) ' a=' num2str(a) ' sa=' num2str(sa) ... 
	  ' b=' num2str(b) ' sb=' num2str(sb) ... 
	  ' chi2red=' num2str(chi2red) ' ndf=' num2str(ndf) ]);     

  end % bg convergence loop
  disp(['ch= ' num2str(ch) '  last BG= ' num2str(bg) ]);

  %% APPLY THE CALCULATED BG
%  P  (:,ch) = P(:,ch)-bg;
%  Pr2(:,ch) = P(:,ch).*altsq(:);
  
  %% APPLY THE SCALLING
  P_mol(1:maxbin,ch) = P_mol(1:maxbin,ch)*a;
  Pr2_mol(1:maxbin,ch) = P_mol(1:maxbin,ch).*altsq(1:maxbin);

end % channel loop

%------------------------------------------------------------------------
%  Plots
%------------------------------------------------------------------------
%
%
% -------------
figure(5)
xx=xx0+4*wdx; yy=yy0+4*wdy;
set(gcf,'position',[xx,yy,wsx,wsy]); % units in pixels!
% at lidar levels
plot(beta_mol(:,1),alt(1:maxbin)*1e-3,'b'); 
hold on
plot(beta_mol(:,2),alt(1:maxbin)*1e-3,'c');
% at sounding levels
plot(beta_mol_snd(:,1),alt_snd(:)*1e-3,'bo'); 
plot(beta_mol_snd(:,2),alt_snd(:)*1e-3,'co');
xlabel('Lidar Beta / m-1')
ylabel('Height / km')
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
subplot(1,2,1)
plot(Pr2(1:maxbin,1), alt(1:maxbin)*1e-3); 
xlabel('range smooth bg-corr signal','fontsize',[10])  
ylabel('height / km','fontsize',12)
title('Rayleigh Fit 355','fontsize',14)
grid on
hold on
plot(Pr2_mol(1:maxbin,1), alt(1:maxbin)*1e-3,'g','LineWidth',2); 
plot(Pr2(RefBin(1),1), alt(RefBin(1))*1e-3,'r*');
hold off
legend('Lidar', 'Rayleigh Fit', 'Reference Bin'); 
%   
subplot(1,2,2)
plot(Pr2(1:maxbin,2), alt(1:maxbin)*1e-3); 
xlabel('range smooth bg-corr signal','fontsize',[10])  
title('Rayleigh Fit 387','fontsize',14)
grid on
hold on
plot(Pr2_mol(1:maxbin,2), alt(1:maxbin)*1e-3,'g','LineWidth',2); 
plot(Pr2(RefBin(2),2), alt(RefBin(2))*1e-3,'r*');
legend('Lidar', 'Rayleigh Fit', 'Reference Bin'); 
%
%
% -------------
figure(7); clf
xx=xx0+3*wdx; yy=yy0+3*wdy;
set(gcf,'position',[xx,yy,2*wsx,wsy]); % units in pixels!
subplot(1,2,1)
plot(log(Pr2(1:maxbin,1)),alt(1:maxbin)*1e-3,'b');    
xlabel('ln range smooth bg-corr signal','fontsize',[10])  
ylabel('height / km','fontsize',12)
title('Rayleigh fit Ln 355' ,'fontsize',14) 
grid on 
hold on
plot(log(Pr2_mol(1:maxbin,1)),alt(1:maxbin)*1e-3,'g','LineWidth',2);   
plot(log(Pr2(RefBin(1),1)), alt(RefBin(1))*1e-3,'r*');
hold off
%
subplot(1,2,2)
plot(log(Pr2(1:maxbin,2)),alt(1:maxbin)*1e-3,'b');  
xlabel('ln range smooth bg-corr signal','fontsize',[10])  
title('Rayleigh fit Ln 387' ,'fontsize',14) 
grid on
hold on
plot(log(Pr2_mol(1:maxbin,2)),alt(1:maxbin)*1e-3,'g','LineWidth',2);   
plot(log(Pr2(RefBin(2),2)), alt(RefBin(2))*1e-3,'r*');
hold off
%
disp('End of program: rayleigh_fit_Manaus.m, Vers. 1.0 06/12')

