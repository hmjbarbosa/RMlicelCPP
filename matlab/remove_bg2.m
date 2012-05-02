function [out] = remove_bg2(signal, bg, bgstd, nlim)

[nx, ny] = size(signal);
if (nlim==0)
  nlim=3;
end

%% REMOVE BG
%% MASK VALUES BELOW NOISE
for j=1:ny
  for i=1:nx
    out(i,j)=signal(i,j)-bg(j);
%    if (abs(out(i,j)) < nlim*bgstd(j))
%      out(i,j)=NaN;
%    end
  end
end

%