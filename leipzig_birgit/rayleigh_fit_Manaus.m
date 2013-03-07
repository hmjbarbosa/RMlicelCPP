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

toextrapolate=0;

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
%%  LOOP ON BACKGROUND CORRECTION AND RAYLEIGH FIT
%%------------------------------------------------------------------------

% for elastic and raman channels
for ch=1:1
  
  % LOOP ON BACKGROUND CORRECTION
  %
  % This is a 1-D numerical algorithm for finding a root, ie, b=0
  % after the rayleigh fit, by changing the parameter BG. First step is
  % to bracket the function, ie, to find limits for our parameter such
  % that func(param1) < 0 and func(param2) > 0 or vice-versa. If this
  % is the case, we know the root is between these values.
  pmin=nanmin(P(rangebins-100:rangebins,ch));
  pmax=nanmax(P(rangebins-100:rangebins,ch));
  pave=nanmean(P(rangebins-100:rangebins,ch));
  bg1=pave-10*(pmax-pmin);
  bg2=pave;
  bg3=pave+10*(pmax-pmin);
%  bg2=50;

  % In each step of the loop, we will divide the interval in half, and
  % calculate the function in between, and then choose one side. The
  % convergence criteria is meet when size of this interval
  % (i.e. uncertainty in the value of BG, our parameter) becomes small
  % enough compared to BG itself.
  nBG=1; sb=1e-10;
%  while(abs((bg1-bg2)/(bg1+bg2)) > 1e-6)
%  while(abs((bg1-bg2)/(bg1+bg2)) > 1e-4 & abs(bg1-bg2) > sb)
  while(nBG<40)

    % At this point we do not know yet f1=func(bg1) or f2=func(bg2)
    % In principle, the estimation above should do it, but right
    % now we only have a wild guess. Therefore the first two steps
    % are just to calculate b(bg1) and b(bg2), and after that we
    % start dividing the interval in half.
    if (nBG==1)
      bg=bg1;
    elseif(nBG==2)
      bg=bg2;
    elseif(nBG==3)
      bg=bg3;
    else
      if (bg2-bg1 < bg3-bg2)
        bg=bg2+0.38*(bg3-bg2);
      else
        bg=bg2-0.38*(bg2-bg1);
      end
    end
    
    bg=0+100*nBG/40;
    
    disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);
    disp(['% ch= ' num2str(ch) '  trying BG= ' num2str(bg) ]);
    disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);

    % Select data from a channel and apply the correction
    tmpXX=P_mol  (1:maxbin,ch);
    tmpYY=P      (1:maxbin,ch)-bg;
    tmpX =tmpXX;%Pr2_mol(1:maxbin,ch);
    tmpY =tmpYY;%Pr2    (1:maxbin,ch)-bg*altsq(1:maxbin);
    tmpZ =alt    (1:maxbin)*1e-3;

    tmpY(1:150)=NaN;
    
    figure(23); clf;
    scatter(tmpX,tmpY,10,tmpZ);
    xlabel('Pr2 molecular'); ylabel('Pr2 lidar');
    hold on; grid on; colorbar;

%    % Calculate the local derivative using a running linear fit
%    pathlen=1000; % meters
%    npath=floor(pathlen*1e-3/2/r_bin);
%    [fval, a]=runfit2(tmpY, tmpX, npath, npath);
%    slope=atan(a);
  
    % Initialize counters for the number of NaN data points
    nmask=sum(isnan(tmpY)); nmask_old=-1;

    % LOOP ON RAYLEIGH FIT
    % Convergence will stop when no more points are removed based
    % on the criteria stablished below
    iter=0;
    while(nmask_old ~= nmask)
      nmask_old=nmask;
    
      % Do a linear fit using all points
      [a, b, fval, sa, sb, chi2red, ndf] = fastfit(tmpX,tmpY);
      % For each point, exclude those which are too far away
      distance=abs(tmpY-fval)./sqrt(chi2red); 
      tmpY(distance>2)=nan;
      % For each point, exclude those not aligned
%      tmpY(abs(slope-atan(a))>pi/2.)=nan;
      % Recompute the mask counter
      nmask=sum(isnan(tmpY));
    
      disp(['iter= ' num2str(iter) ' nmask=' num2str(nmask) ...
	    ' a=' num2str(a) ' sa=' num2str(sa) ... 
	    ' b=' num2str(b) ' sb=' num2str(sb) ... 
	    ' chi2red=' num2str(chi2red) ' ndf=' num2str(ndf) ]); 
    
      figure(24); clf; hold off;
      scatter(tmpX(~isnan(tmpY)),tmpY(~isnan(tmpY)),10,tmpZ(~isnan(tmpY)));
      hold on; grid on;
      plot(tmpX(~isnan(tmpY)),tmpX(~isnan(tmpY))*a+b,'r');
      xlabel('Pr2 mol'); ylabel('Pr2 and Fit');
      
      iter=iter+1; 
    end
    
    disp(['iter= ' num2str(iter) ' nmask=' num2str(nmask) ...
	  ' a=' num2str(a) ' sa=' num2str(sa) ... 
	  ' b=' num2str(b) ' sb=' num2str(sb) ... 
	  ' chi2red=' num2str(chi2red) ' ndf=' num2str(ndf) ]); 

    figure(24); clf; hold off;
    scatter(tmpX(~isnan(tmpY)),tmpY(~isnan(tmpY)),10,tmpZ(~isnan(tmpY)));
    hold on; grid on;
    plot(tmpX(~isnan(tmpY)),tmpX(~isnan(tmpY))*a+b,'r');
    xlabel('Pr2 mol'); ylabel('Pr2 and Fit');
    colorbar;
    
    figure(23); plot(Pr2_mol(1:maxbin,ch),Pr2_mol(1:maxbin,ch)*a+b,'r');

    % Save some info about the Pr2 fit for future analysis
    tmpZ(isnan(tmpY))=NaN;
    ['lowest used bin #' num2str(min(tmpZ)) ' at height=' num2str((min(tmpZ))) ]
    ['highest used bin #' num2str(max(tmpZ)) ' at height=' num2str((max(tmpZ))) ]
    out(1,nBG,ch)=bg;
    out(2,nBG,ch)=iter;
    out(3,nBG,ch)=nmask;
    out(4,nBG,ch)=chi2red;
    out(5,nBG,ch)=min(tmpZ);
    out(6,nBG,ch)=max(tmpZ);

    % Use the points selected by the Pr2() fit and now fit in P() We
    % need to check if the BG*R^2 term which is missing from the
    % previous fit will not cause problem when data has too much
    % noise.
    [a, b, fval, sa, sb, chi2red, ndf] = fastfit(...
	tmpXX(~isnan(tmpY)),tmpYY(~isnan(tmpY)));
    disp(['iter= ' num2str(iter) ' nmask=' num2str(nmask) ...
	  ' a=' num2str(a) ' sa=' num2str(sa) ... 
	  ' b=' num2str(b) ' sb=' num2str(sb) ... 
	  ' chi2red=' num2str(chi2red) ' ndf=' num2str(ndf) ]);     

    figure(26); clf;
    scatter(tmpXX(~isnan(tmpY)),tmpYY(~isnan(tmpY)),10,tmpZ(~isnan(tmpY)));
    xlabel('P molecular'); ylabel('P lidar');
    hold on; grid on; colorbar;
    plot(tmpXX(~isnan(tmpY)),tmpXX(~isnan(tmpY))*a+b,'r');
    tmp=axis(); tmp(3)=-0.2; tmp(4)=0.8;
    axis(tmp); 

    % Save some info about the P fit for future analysis
    out(7 ,nBG,ch)=b;
    out(8 ,nBG,ch)=sb;
    out(9 ,nBG,ch)=chi2red;
    out(10,nBG,ch)=a;
    out(11,nBG,ch)=sa;
  
    % Verify if root is in [bg1, bg] or [bg, bg2]
    f=out(4,nBG,ch);
    if (nBG==1)
      f1=f;
    elseif (nBG==2)
      f2=f;
    elseif (nBG==3)
      f3=f;
    else
      [' bg1 ' num2str(bg1) ' f1 ' num2str(f1) ...
       ' bg2 ' num2str(bg2) ' f2 ' num2str(f2) ....
       ' bg3 ' num2str(bg2) ' f3 ' num2str(f3) ....
       ' bg  ' num2str(bg)  ' f '  num2str(f) ]

      if (bg2-bg1 < bg3-bg2)
        if (f2 < f)
          bg3=bg;
          f3=f;
        else
          bg1=bg2;
          f1=f2;
          bg2=bg;
          f2=f;
        end
      else
        if (f2 < f)
          bg1=bg;
          f1=f;
        else
          bg3=bg2;
          f3=f2;
          bg2=bg;
          f2=f;
        end
      end
    end
    nBG=nBG+1;

    figure(25);
    plot( out(7,:,ch)); hold on;
    plot( out(8,:,ch),'r');
    plot(-out(8,:,ch),'r');
    plot( out(1,:,ch),'g'); hold off;
    legend('b','+sig','-sig','bg');
  
  end % bg convergence loop
  
  disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);
  disp(['% ch= ' num2str(ch) '  last BG= ' num2str(bg1) ' ' num2str(bg2) ]);
  disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);

  %% APPLY THE CALCULATED BG
  P  (:,ch) = P(:,ch)-(bg1+bg2)*0.5;
  Pr2(:,ch) = P(:,ch).*altsq(:);
  
  %% APPLY THE CALCULATED SCALLING
  P_mol(1:maxbin,ch) = P_mol(1:maxbin,ch)*a;
  Pr2_mol(1:maxbin,ch) = P_mol(1:maxbin,ch).*altsq(1:maxbin);

  %% SET THE REFERENCE BIN
  RefBin(ch) = floor((out(5,nBG-1,ch)+out(6,nBG-1,ch))*0.5/r_bin); 
  
  %% SAVE MOLECULAR MASK
  mask_mol(1:maxbin,ch)=~isnan(tmpY);
  
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
figure(6)
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
figure(7)
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

