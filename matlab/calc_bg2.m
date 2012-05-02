function [bg, bgstd] = calc_bg2(signal, len)
%% Remove BG from the last 'len' elements in an array.
%% If second dimension > 1, operation is repeated over it.

[nx, ny] = size(signal);
if (len==0)
  len=nx/10;
end

%% CALCULATE BG AND STD_BG
bgstd=nanstd(signal(nx-len+1:nx,:));
bg=nanmean(signal(nx-len+1:nx,:));

%