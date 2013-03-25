function [out] = smooth_time(signal,n1)

[nz, nt] = size(signal);

for t=1:nt
  p1=t-n1;
  p2=t+n1;
  if (p1<1) p1=1; end
  if (p2>nt) p2=nt; end
  out(1:nz, t)=nanmean(signal(1:nz, p1:p2),2);
end
  
%