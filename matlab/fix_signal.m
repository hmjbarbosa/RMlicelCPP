function [out] = fix_signal(signal,dbin,dtime)

[nz nt nch] = size(signal);

% for channel 1 and 3, displace by dbin bins
% for channel 2, 4 and 5, correct dead-time
for j=1:5
  if (j==1 | j==3)
    % displace by dbin's
    out(1:nz-dbin,:,j) = signal(1+dbin:nz,:,j);

    % repeat the last dbin values to keep size of vectors
    out(nz-dbin+1:nz,:,j) = signal(nz-dbin+1:nz,:,j);
  else
    % correct for dead-time
    out(:,:,j) = signal(:,:,j)./(1-signal(:,:,j)*dtime);
  end
end


%