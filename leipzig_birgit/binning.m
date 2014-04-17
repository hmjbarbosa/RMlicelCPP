function out = binning(in,N,dir)

[nx ny]=size(in);
if dir==1
  j=0;
  for i=1:N:nx
    j=j+1;
    out(j,:)=nanmean(in(i:min(i+N-1,nx),:),1);
  end
else
  i=0;
  for j=1:N:ny
    i=i+1;
    out(:,i)=nanmean(in(:,j:min(j+N-1,ny),:),2);
  end
end
%