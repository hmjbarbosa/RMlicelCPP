function [out, bg, std] = remove_bg(signal, len, nlim)
%% Remove BG from the last 'len' elements in an array.
%% If second dimension > 1, operation is repeated over it.

[nx, ny] = size(signal);
if (len==0)
  len=nx/10;
end

%% CALCULATE BG AND STD_BG
for j=1:ny
  bg(j)=0; std(j)=0;
  for i=nx-len+1:nx
    bg(j)=bg(j)+signal(i,j);
    std(j)=std(j)+signal(i,j)^2;
  end
  bg(j)=bg(j)/len;
  std(j)=std(j)/len;
  std(j)=sqrt(std(j)-bg(j)^2);
end
%% REMOVE BG if ABOVE noise
for j=1:ny
  for i=1:nx
    if (signal(i,j) > bg(j)+nlim*std(j))
      out(i,j)=signal(i,j)-bg(j);
    else
      out(i,j)=NaN;
    end
  end
end

%