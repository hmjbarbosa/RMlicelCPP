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
clear maxbin beta_mol alpha_mol out nn 
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
%xl_scal_1 = round(15/r_bin); % km
%xu_scal_1 = round(17/r_bin); % km
%% Raman channel
%xl_scal_2 = round(15/r_bin); % km
%xu_scal_2 = round(17/r_bin); % km

% simulado molecular
%meanRaySig(1) = mean(Pr2_mol(xl_scal_1:xu_scal_1,1)); 
%meanRaySig(2) = mean(Pr2_mol(xl_scal_2:xu_scal_2,2)); 
% 
% ----------------
%   mean signals 
% -----------------
% medido lidar
%meanPr2(1) = mean(Pr2(xl_scal_1:xu_scal_1,1)); 
%meanPr2(2) = mean(Pr2(xl_scal_2:xu_scal_2,2)); 
%    
% Scales the molecular-sounding to the "values" of the lidar data
%RaySig(:,1) = Pr2_mol(:,1)*meanPr2(1)/meanRaySig(1); 
%RaySig(:,2) = Pr2_mol(:,2)*meanPr2(2)/meanRaySig(2); 


% ------------
%  logarithm
% ------------
%Ray_Fit(1,:) = log(RaySig(:,1));  
%Ray_Fit(2,:) = log(RaySig(:,2)); 
%log_Pr2 = real(log(Pr2));    

% loop on background correction

bg=1e-20; b=1e-23; 
ch=1; nn=0;

pmin=nanmin(P(rangebins-100:rangebins,ch));
pmax=nanmax(P(rangebins-100:rangebins,ch));
pave=nanmean(P(rangebins-100:rangebins,ch));

bg1=pave+10*(pmax-pmin);
bg2=pave-10*(pmax-pmin);

while(abs((bg1-bg2)/(bg1+bg2)) > 1e-3)

% (-linear coef) of fitting between P x Pmol is the BG correction
% to be made. Correct for that before procedding.
  if (nn==0)
    bg=bg1;
  elseif(nn==1)
    f1=b;
    bg=bg2;
  elseif(nn==2)
    f2=b;
    bg=(bg1+bg2)*0.5;
  else
    ['bg1 ' num2str(bg1) ' f1 ' num2str(f1) ' bg2 ' num2str(bg2) ' f2 ' ...
     num2str(f2) ' bg ' num2str(bg) ' f ' num2str(b) ]

%    poly=inv([bg1^2 bg1 1; bg2^2 bg2 1; bg^2 bg 1])*[f1;f2;b];
%    bg=    
    if (f1*b<0)
      f2=b;
      bg2=bg;
    else
      f1=b;
      bg1=bg;
    end
    bg=(bg1+bg2)*0.5;
  end
  if (nn==3)
%    return
  end
%  bg=bg+b;
  ['TOTAL BG: ' num2str(bg) ' EXTRA BG: ' num2str(b) ' ratio=' num2str(b/bg)]

  % Data to use for determination of molecular region
  tmpXX=P_mol(1:maxbin,ch);
  tmpYY=P(1:maxbin,ch)-bg;

  tmpX=Pr2_mol(1:maxbin,ch);
  tmpY=Pr2(1:maxbin,ch)-bg*altsq(1:maxbin);
  tmpZ=(1:maxbin);

  [fval, a]=runfit2(tmpY, tmpX, 120, 120);
  slope=atan(a);
  
  figure(23); clf;
  scatter(tmpX,tmpY,10,tmpZ);
  xlabel('Pr2 molecular'); ylabel('Pr2 lidar');
  hold on; grid on; colorbar;

  disp(['masking based on linear coef...']);
  nmask=sum(isnan(tmpY)); nmask_old=-1;
  iter=0;
  while(nmask_old ~= nmask)
    nmask_old=nmask;
    
    [a, b, fval, sa, sb, chi2red, ndf] = fastfit(tmpX,tmpY);
    distance=abs(tmpY-fval)./sqrt(chi2red); 
    tmpY(distance>2)=nan;
    tmpY(abs(slope-atan(a))>pi/2.)=nan;
    nmask=sum(isnan(tmpY));
    
    disp(['iter= ' num2str(iter) ' nmask=' num2str(nmask) ...
          ' a=' num2str(a) ' sa=' num2str(sa) ... 
          ' b=' num2str(b) ' sb=' num2str(sb) ... 
          ' chi2red=' num2str(chi2red) ' ndf=' num2str(ndf) ]); 
    
    figure(27); clf; hold off;
    scatter(tmpX(~isnan(tmpY)),tmpY(~isnan(tmpY)),10,tmpZ(~isnan(tmpY)));
    hold on; grid on;
    plot(tmpX(~isnan(tmpY)),tmpX(~isnan(tmpY))*a+b,'r');
    xlabel('Pr2 mol'); ylabel('Pr2 and Fit');
    
    iter=iter+1; 
  end
  figure(27); clf; hold off;
  scatter(tmpX(~isnan(tmpY)),tmpY(~isnan(tmpY)),10,tmpZ(~isnan(tmpY)));
  hold on; grid on;
  plot(tmpX(~isnan(tmpY)),tmpX(~isnan(tmpY))*a+b,'r');
  xlabel('Pr2 mol'); ylabel('Pr2 and Fit');
  colorbar;
  figure(23); plot(Pr2_mol(1:maxbin,ch),Pr2_mol(1:maxbin,ch)*a+b,'r');
  
  tmpZ(isnan(tmpY))=NaN;
  ['lowest used bin #' num2str(min(tmpZ)) ' at height=' num2str(alt(min(tmpZ))) ]
  ['highest used bin #' num2str(max(tmpZ)) ' at height=' num2str(alt(max(tmpZ))) ]
  
  [a, b, fval, sa, sb, chi2red, ndf] = fastfit(tmpXX(~isnan(tmpY)),tmpYY(~isnan(tmpY)));
  
  disp(['iter= ' num2str(iter) ' nmask=' num2str(nmask) ...
        ' a=' num2str(a) ' sa=' num2str(sa) ... 
        ' b=' num2str(b) ' sb=' num2str(sb) ... 
        ' chi2red=' num2str(chi2red) ' ndf=' num2str(ndf) ]); 
  
  ['TOTAL BG: ' num2str(bg) ' EXTRA BG: ' num2str(b) ' ratio=' num2str(b/bg)]
  
  nn=nn+1;
  out(nn,1)=bg;
  out(nn,2)=b;
  out(nn,3)=sb;
  out(nn,4)=ndf;
  figure(1);
  plot(out(:,2)); hold on;
  plot(out(:,3),'r');
  plot(-out(:,3),'r');
  plot(out(:,1),'g'); hold off;
  legend('b','+sig','-sig','bg');
  
%  figure(28); clf; hold off;
%  scatter((P_mol(~isnan(tmpY),ch)),(P(~isnan(tmpY),ch)),10,tmpZ(~isnan(tmpY)));
%  hold on; grid on; colorbar;
%  plot((P_mol(~isnan(tmpY),ch)),(P_mol(~isnan(tmpY),ch)*a+b),'r');
%  xlabel('P mol'); ylabel('P and Fit');
  
%  pause
  
end

%return
        
%% ----------------------
%%   find reference bins
%% ----------------------
%% *****************
%%    channel 1
%% *****************
%%hmjb abst_1=1e-3;
%abst_1=(real(log_Pr2(xl_scal_1,1)) - Ray_Fit(1,xl_scal_1)).^2;
%RefBin(1)=xl_scal_1;
%for j=xl_scal_1:xu_scal_1
%  diff_1(j) = (real(log_Pr2(j,1)) - Ray_Fit(1,j)).^2; 
%  if diff_1(j) < abst_1
%    abst_1 = diff_1(j);
%    RefBin(1)=j;  
%  end
%end
%
%% *****************
%%    channel 2
%% *****************
%%hmjb abst_2=1e-3; 
%abst_2=(real(log_Pr2(xl_scal_2,2)) - Ray_Fit(2,xl_scal_2)).^2;
%RefBin(2)=xl_scal_2;
%for j=xl_scal_2:xu_scal_2 
%  diff_2(j) = (real(log_Pr2(j,2))- Ray_Fit(2,j)).^2;  
%  if diff_2(j) < abst_2
%    abst_2=diff_2(j);
%    RefBin(2)=j; 
%  end
%end
%

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
plot(Pr2_mol(1:maxbin,1)*a, alt(1:maxbin)*1e-3,'g','LineWidth',2); 
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
plot(Pr2_mol(1:maxbin,2)*a, alt(1:maxbin)*1e-3,'g','LineWidth',2); 
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

