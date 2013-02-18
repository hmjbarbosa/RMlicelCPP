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
clear maxbin beta_mol alpha_mol
clear xl_scal_1 xu_scal_1 xl_scal_2 xu_scal_2 xl_scal_3 xu_scal_3
clear meanRaySig meanPr2 SigFak RaySig log_Pr2 Ray_Fit
clear RefBin diff_1 abst_1 diff_2 abst_2 diff_3 abst_3
% ---------------------------------------------------

%%------------------------------------------------------------------------
%%  INTERPOLATION TO LIDAR SAMPLING ALTITUDES
%%------------------------------------------------------------------------

toextrapolate=0;

if toextrapolate==0
  % Set maximum lidar bin to highest altitude of sounding 
  maxbin=floor(alt_snd(nlev_snd)*1e-3/r_bin);

  % Simple linear interpolation within the souding range
  beta_mol(:,1) = interp1(alt_snd, beta_mol_snd(:,1), ... 
			      alt(1:maxbin),'linear','extrap');
  beta_mol(:,2) = interp1(alt_snd, beta_mol_snd(:,2), ...
			      alt(1:maxbin),'linear','extrap');
else
  % Set maximum lidar bin to total number of bins
  maxbin = size(Pr2,1);

  % Beta_mol() decays exponentially towards zero with increasing
  % height. Extrapolating it above the highest level in the sounding can
  % lead to negative (unphysical) values. Hence interpolation is done in
  % log() and then the exp() of the result is taken.
  beta_mol(:,1) = exp(interp1(alt_snd, log(beta_mol_snd(:,1)), ... 
			      alt(1:maxbin),'linear','extrap'));
  beta_mol(:,2) = exp(interp1(alt_snd, log(beta_mol_snd(:,2)), ...
			      alt(1:maxbin),'linear','extrap'));
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
%hmjb try to use trapezium rule
%      tau(j,i) = tau(j,i-1)+alpha_mol(i,j)*r_bin; 
      tau(i,j) = tau(i-1,j)+(alpha_mol(i,j)+alpha_mol(i,j))*r_bin/2; 
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
%% 
%%------------------------------------------------------------------------

% ----------------------------------------
%  choose altitude range for Rayleigh fit
% ----------------------------------------
% elastic channel
xl_scal_1 = round(15/r_bin); % km
xu_scal_1 = round(17/r_bin); % km
% Raman channel
xl_scal_2 = round(15/r_bin); % km
xu_scal_2 = round(17/r_bin); % km

% simulado molecular
meanRaySig(1) = mean(Pr2_mol(xl_scal_1:xu_scal_1,1)); 
meanRaySig(2) = mean(Pr2_mol(xl_scal_2:xu_scal_2,2)); 
% 
% ----------------
%   mean signals 
% -----------------
% medido lidar
meanPr2(1) = mean(Pr2(xl_scal_1:xu_scal_1,1)); 
meanPr2(2) = mean(Pr2(xl_scal_2:xu_scal_2,2)); 
%    
% Scales the molecular-sounding to the "values" of the lidar data
RaySig(:,1) = Pr2_mol(:,1)*meanPr2(1)/meanRaySig(1); 
RaySig(:,2) = Pr2_mol(:,2)*meanPr2(2)/meanRaySig(2); 


% ------------
%  logarithm
% ------------
Ray_Fit(1,:) = log(RaySig(:,1));  
Ray_Fit(2,:) = log(RaySig(:,2)); 
log_Pr2 = real(log(Pr2));    

% Data to use for determination of molecular region
tmpX=Pr2_mol(1:maxbin,1);
tmpY=Pr2(1:maxbin,1);
tmpZ=(1:maxbin);

figure(23); clf;
scatter(tmpX,tmpY,10,tmpZ);
xlabel('Pr2 molecular'); ylabel('Pr2 lidar');
grid on; colorbar;

[a, b, fval, sa, sb, chi2red, ndf] = fastfit(tmpX,tmpY);

disp(['masking based on linear coef...']);
nmask=sum(isnan(tmpY)); nmask_old=-1;
iter=0;
while(nmask_old ~= nmask)
  nmask_old=nmask;
  
  disp(['iter= ' num2str(iter) ' nmask=' num2str(nmask) ...
        ' a=' num2str(a) ' sa=' num2str(sa) ... 
        ' b=' num2str(b) ' sb=' num2str(sb) ... 
        ' chi2red=' num2str(chi2red) ' ndf=' num2str(ndf) ]); 

  distance=abs(tmpY-fval)./sqrt(chi2red); 

  tmpY(distance>3)=nan;
%  for i=2:length(tmpY)-1
%    if (tmpY(i-1)==NaN & tmpY(i+1)==NaN)
%      tmpY(i)=NaN;
%    end
%  end
  nmask=sum(isnan(tmpY));

  [a, b, fval, sa, sb, chi2red, ndf] = fastfit(tmpX,tmpY);

  figure(26); clf; hold off;
  scatter(log(tmpX(~isnan(tmpY))),log(tmpY(~isnan(tmpY))),10,tmpZ(~isnan(tmpY)));
  hold on; grid on;
  plot(log(tmpX(~isnan(tmpY))),log(tmpX(~isnan(tmpY))*a+b),'r');
  xlabel('log(Pr2 mol)'); ylabel('log(Pr2) and log(Fit)');

  figure(27); clf; hold off;
  scatter(tmpX(~isnan(tmpY)),tmpY(~isnan(tmpY)),10,tmpZ(~isnan(tmpY)));
  hold on; grid on;
  plot(tmpX(~isnan(tmpY)),tmpX(~isnan(tmpY))*a+b,'r');
  xlabel('Pr2 mol'); ylabel('Pr2 and Fit');

  iter=iter+1; 
end
tmpZ(isnan(tmpY))=NaN;
['lowest used bin #' num2str(min(tmpZ)) ...
 ' at height=' num2str(alt(min(tmpZ))) ]

['highest used bin #' num2str(max(tmpZ)) ...
 ' at height=' num2str(alt(max(tmpZ))) ]

[a, b, fval, sa, sb, chi2red, ndf] = fastfit(P_mol(~isnan(tmpY)),P(~isnan(tmpY)));

disp(['iter= ' num2str(iter) ' nmask=' num2str(nmask) ...
      ' a=' num2str(a) ' sa=' num2str(sa) ... 
      ' b=' num2str(b) ' sb=' num2str(sb) ... 
      ' chi2red=' num2str(chi2red) ' ndf=' num2str(ndf) ]); 

figure(28); clf; hold off;
scatter(log(P_mol(~isnan(tmpY))),log(P(~isnan(tmpY))),10,tmpZ(~isnan(tmpY)));
hold on; grid on;
plot(log(P_mol(~isnan(tmpY))),log(P_mol(~isnan(tmpY))*a+b),'r');
xlabel('P mol'); ylabel('P and Fit');

return
%figure(24); clf; plot(b,'r'); hold on; plot(mask,'g'); ylabel('b');

%disp(['masking based on angular coef...']);
%amask=a; 
%%amask(isnan(bmask))=nan;
%namask=sum(isnan(amask));
%namask_old=-1;
%iter=0;
%while(namask_old ~= namask)
%  namask_old=namask;
%  disp(['iter= ' num2str(iter) ' namask=' num2str(namask) ' of ' ...
%        num2str(size(a,1)) ' amask=' num2str(nanmean(amask)) ]);
%  distance=abs(amask-nanmean(amask))./nanstd(amask);
%  amask(distance>3)=nan;
%  namask=sum(isnan(amask));
%  iter=iter+1;
%end
%figure(25); clf; plot(a,'r'); hold on; plot(amask,'g'); ylabel('a');
%
%
%return
        
% ----------------------
%   find reference bins
% ----------------------
% *****************
%    channel 1
% *****************
%hmjb abst_1=1e-3;
abst_1=(real(log_Pr2(xl_scal_1,1)) - Ray_Fit(1,xl_scal_1)).^2;
RefBin(1)=xl_scal_1;
for j=xl_scal_1:xu_scal_1
  diff_1(j) = (real(log_Pr2(j,1)) - Ray_Fit(1,j)).^2; 
  if diff_1(j) < abst_1
    abst_1 = diff_1(j);
    RefBin(1)=j;  
  end
end

% *****************
%    channel 2
% *****************
%hmjb abst_2=1e-3; 
abst_2=(real(log_Pr2(xl_scal_2,2)) - Ray_Fit(2,xl_scal_2)).^2;
RefBin(2)=xl_scal_2;
for j=xl_scal_2:xu_scal_2 
  diff_2(j) = (real(log_Pr2(j,2))- Ray_Fit(2,j)).^2;  
  if diff_2(j) < abst_2
    abst_2=diff_2(j);
    RefBin(2)=j; 
  end
end


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
plot(RaySig(1:maxbin,1), alt(1:maxbin)*1e-3,'g','LineWidth',2); 
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
plot(RaySig(1:maxbin,2), alt(1:maxbin)*1e-3,'g','LineWidth',2); 
plot(Pr2(RefBin(2),2), alt(RefBin(2))*1e-3,'r*');
legend('Lidar', 'Rayleigh Fit', 'Reference Bin'); 
%
%
% -------------
figure(7)
xx=xx0+3*wdx; yy=yy0+3*wdy;
set(gcf,'position',[xx,yy,2*wsx,wsy]); % units in pixels!
subplot(1,2,1)
plot(log_Pr2(1:maxbin,1),alt(1:maxbin)*1e-3,'b');    
xlabel('ln range smooth bg-corr signal','fontsize',[10])  
ylabel('height / km','fontsize',12)
title('Rayleigh fit Ln 355' ,'fontsize',14) 
grid on 
hold on
plot(Ray_Fit(1,1:maxbin),alt(1:maxbin)*1e-3,'g','LineWidth',2);   
plot(log_Pr2(RefBin(1),1), alt(RefBin(1))*1e-3,'r*');
hold off
%
subplot(1,2,2)
plot(log_Pr2(1:maxbin,2),alt(1:maxbin)*1e-3,'b');  
xlabel('ln range smooth bg-corr signal','fontsize',[10])  
title('Rayleigh fit Ln 387' ,'fontsize',14) 
grid on
hold on
plot(Ray_Fit(2,1:maxbin),alt(1:maxbin)*1e-3,'g','LineWidth',2);   
plot(log_Pr2(RefBin(2),2), alt(RefBin(2))*1e-3,'r*');
hold off
%
disp('End of program: rayleigh_fit_Manaus.m, Vers. 1.0 06/12')

