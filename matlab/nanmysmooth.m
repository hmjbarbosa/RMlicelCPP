function [out] = nanmysmooth(in, span, span2)

M = size(in);
if M(1)==1
  in=in';
  nx=M(2);
else
  nx=M(1);
end

for i=1:nx
  c=floor((i-1)*(span2-span)/(nx-1)+span+0.5);
  p1=i-c;
  p2=i+c;
  if (p1<1)
    p1=1;
    p2=1+2*c;
  end
  if (p2>nx)
    p1=nx-2*c;
    p2=nx;
  end

  out(i,:) = nanmean(in(p1:p2,:));
end

if M(1)==1
  out=out';
end
