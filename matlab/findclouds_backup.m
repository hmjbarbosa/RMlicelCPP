
sigin(:,1)=channel(1).phy(1:1800,450);
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
FIT_SLOPE_NPT=5;
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

%% LAYER BASE
% It is where the signal starts to increase in terms of positive
% signal slope
BASE_INC_NPT=3;
BASE_BG_NPT=500;
BASE_BG_SNR=3;
FULL_OVERLAP_IDX=80;
[slope_bg slope_std] = calc_bg2(slope, BASE_BG_NPT);
for t=1:1
  base(t)=NaN;
  for z=FULL_OVERLAP_IDX:size(alt,1)-1
    % slope must be positive and larger than 3*sigma
    if (slope(z,t)>0 && slope(z,t)>slope_bg(t)+BASE_BG_SNR*slope_std(t))
alt(z)
qq=z-20; ww=z+20; temp_plot;
      % test if signal increases in the next 3 layers
      if all(sigin(z:z+BASE_INC_NPT,t) < sigin(z+1:z+1+BASE_INC_NPT,t))
        base(t)=z;
        break;
      end
    end
  end
end
['base']
base(1)
alt(base(1))
qq=base(1)-20; ww=base(1)+20; temp_plot;

%% LAYER TOP
% It is where the signal returns to the molecular backscatering or
% noise level is found
for t=1:1
  top(t)=NaN;
  neg(t)=NaN;
  for z=base(t):size(alt,1)-1
    % signal drops below 3*sigma (noise)
    if (sigin(z,t) < channel(1).bg(450)+BG_SNR*channel(1).std(450))
      top(t)=-z;
      break;
    end
    % slope must become negative before returning to molecular
    if (slope(z,t)<0 && slope(z,t)<slope_bg(t)-BASE_BG_SNR* ...
        slope_std(t))
      neg(t)=z;
      break;
    end
  end
  if (~isnan(neg(t)))
    for z=neg(t):size(alt,1)-1
      % signal drops below 3*sigma (noise)
      if (sigin(z,t) < channel(1).bg(t)+BG_SNR*channel(1).std(t))
        top(t)=-z;
        break;
      end
      % slope return to molecular backscatering (~-0.8)
      %hmjb I think that means the same level of signal quality
      if (slope(z,t)>slope(z-1,t)) && ... 
         (slope(z,t)>slope_bg(t)-BASE_BG_SNR*slope_std(t))
        top(t)=z;
        break;
      end
    end
  end
end
['top']
top(1)
alt(top(1))
qq=top(1)-20; ww=top(1)+20; temp_plot;

%% LAYER PEAK
% It is where the signal is maximum
for t=1:1
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


%fim