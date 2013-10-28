function [out] = nanmysmooth(in, span, span2)

M = size(in);
if M(1)==1
  in=in';
  nx=M(2);
  ny=M(1)
else
  nx=M(1);
  ny=M(2);
end

% initialize out for faster processing
%out(1:nx,1:ny)=NaN;

for i=1:nx
  c=floor((i-1)*(span2-span)/(nx-1)+span+0.5);
  p1=i-c;
  p2=i+c;
  if (p1<1)
    p1=1;
%    p2=1+2*c;
  end
  if (p2>nx)
%    p1=nx-2*c;
    p2=nx;
  end

  out(i,:) = nanmean(in(p1:p2,:),1);
%  [i p1 p2 in(p1:p2,1)' out(i,1)]
end

if M(1)==1
  out=out';
end
