function [out] = smooth_region(signal,n1,lim12, n2, lim23, n3)

[nz, nt] = size(signal);
tmp=signal';

for i = 1:nz
  if (i<lim12)
    p1=i-n1;
    p2=i+n1;
  elseif ( (i>=lim12) & (i<lim23) )
    p1=i-n2;
    p2=i+n2;    
  else
    p1=i-n3;
    p2=i+n3;
  end
  if (p1<1)
    p1=1;
  end
  if (p2>nz)
    p2=nz;
  end

  tmp2(1:nt, i)=mean(tmp(1:nt, p1:p2),2);
end

out=tmp2';
%