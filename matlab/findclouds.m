
%for j=1:1800
%  sigin(j,1)=channel(2).phy3(j,428);
%  if (sigin(j,1)<=0)
%    sigin(j,1)=NaN;
%  end
%end
ch=2;
time=428;
sigin(1:1800,1)=channel(ch).phy(1:1800,time);
alt=zh(1:1800);

base(1)=NaN;
peak(1)=NaN;
top(1)=NaN;

%% -----------------------------------------------------------------
%%  FIRST STEP:
%% -----------------------------------------------------------------
% Using the range-uncorrected averaged vertical profile, calculate:
%   a) slope
%   b) quality
%   b) standard deviation "sigma" of the background noise level
%% -----------------------------------------------------------------
%
% runfit() calculates a running linear fit at each point and then
% calculates eq.(1) of Wang & Sassen. 
%
FIT_SLOPE_NPT=10;
[fval, slope, linear, relerr] = runfit(log(sigin), alt, FIT_SLOPE_NPT);
% relerr:
%   The so called "quality of signal" is given by relative error
%   "relerr" which measures the fluctuations around the linear fit for
%   a given point. Hence, it increases with increasing noise.
%
% slope:
%   The inclination of the linear fit at each point is the slope of
%   the curve in an "averaged" vertical profile. 2*NPT_FIT_SLOPE+1
%   points are used to calculate each linear regression, and hence
%   NPT_FIT_SLOPE controls the smoothness of the calculated slope.
qq=1; ww=1800; temp_plot;

%% -----------------------------------------------------------------
%%  SECOND STEP:
%% -----------------------------------------------------------------
% Examine lidar signal upward from the ground and record:
%   a) Height of layer base
%   b) Height of layer peak
%   c) Height of layer top
%   d) Ratio of peak signal to that of layer base
%   e) Maximum negative slope
%
% The algorithm will then decide if layer is a cloud, aerossol or
% noise.

%% SLOPE BG LEVEL
%hmjb: not sure... if we take the end of the spectrue, the signal
% is only noise, hence the slope will be zero and not the molecular
% slope. 
BASE_BG_NPT=500;
BASE_BG_SNR=4;
[slope_bg slope_std] = calc_bg2(slope, BASE_BG_NPT);

%% LAYER BASE
% It is where the signal starts to increase in terms of positive
% signal slope
BASE_INC_NPT=5;
FULL_OVERLAP_IDX=80;
for t=1:size(sigin,2)
  base(t)=NaN;
  for z=FULL_OVERLAP_IDX:size(sigin,1)-1
    idx=z-FIT_SLOPE_NPT-1;
    % slope must be positive and larger than 3*sigma
    %if (slope(z,t)>0 && slope(z,t)>slope_bg(t)+BASE_BG_SNR*slope_std(t))
%    if (slope(z,t)>0 && ...
%        (fval(z,t) > ( linear(idx,t)+slope(idx,t)*alt(z,t) + ...
%          BASE_BG_SNR*relerr(idx,t))) )
    if (slope(z,t)>0 )
      % test if signal increases in the next 3 layers
%      if all(sigin(z:z+BASE_INC_NPT,t) < sigin(z+1:z+1+BASE_INC_NPT,t))
      if all(fval(z:z+BASE_INC_NPT,t) < fval(z+1:z+1+BASE_INC_NPT,t))
% z is actually being influenced by the last bin to the right!
%        base(t)=z+FIT_SLOPE_NPT;
        base(t)=z;
        break;
      end
    end
  end
end
['base']
base(1)
alt(base(1))
qq=base(1)-8; ww=base(1)+8; temp_plot;

%% LAYER TOP
% It is where the signal returns to the molecular backscatering or
% noise level is found
for t=1:size(sigin,2)
  top(t)=NaN;
  neg(t)=NaN;
  for z=base(t)+1:size(sigin,1)-1
    % signal drops below 3*sigma (noise)
    if (sigin(z,t) < channel(ch).bg(time)+BG_SNR*channel(ch).std(time))
      top(t)=z;
      break;
    end
    % slope return to molecular backscatering 

    % hmjb I think that means to extrapolate Y=a*x+b at cloud base and
    % see when the signal returns to this level. Due to the signal
    % fluctuations, here I check against the smoothed (interpolated)
    % signal instead of real signal.
    % Because slope at base is already influenced by the cloud, I
    % am taking it FIT_SLOPE_NPT before base.
    idx=base(t)-2*FIT_SLOPE_NPT-1;
    if (slope(z,t)>slope(z-1,t)) && ... 
          (fval(z,t)<linear(idx,t)+slope(idx,t)*alt(z,t)- ...
           BASE_BG_SNR*relerr(idx,t))
      top(t)=z;
      break;
    end
  end
end
['top']
top(1)
alt(top(1))
qq=top(1)-8; ww=top(1)+8; temp_plot;

%% LAYER PEAK
% It is where the signal is maximum
for t=1:size(sigin,2)
  peak(t)=base(t);
  tmp=sigin(base(t),t);
  for z=base(t):top(t)
    if sigin(z,t) > tmp
      peak(t)=z;
      tmp=sigin(z,t);
    end
  end
end
['peak']
peak(1)
alt(peak(1))
qq=peak(1)-20; ww=peak(1)+20; temp_plot;

qq=1; ww=1800; temp_plot;

%fim