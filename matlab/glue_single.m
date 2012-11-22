function [glued] = glue_single(analog, photon, header, toplot)

N=ndims(analog);
if (N>1)
  [nx ny] = size(analog);
  if (ny>1 || N>2)
    error('Only 1-dim to glue!')
  end
end

% Length of data
n=header.ndata(3);
idx=1:n;

% Resolution (mV) of analog channel)
resol=header.discr(3)/2^header.bits(3);

% Create a mask for the region where analog and PC are thought to be
% proportional: below 7MHZ and above 5*resolution
mask=(analog>5*resol) & (analog>0.) & (analog~=NaN) & ...
     (photon<7.)      & (photon>0.) & (photon~=NaN);
%mask=(idx>1000) & (idx<1500.);

% limits of fit region. result of min() or max() is an array with the
% corresponding values for each column
idxmin=min(idx(mask));
idxmax=max(idx(mask));
if exist('toplot','var')
  {idxmin idxmax idxmax-idxmin}
end

% check if there was something different from NaN
% in this case, the size of max/min vectors should be larger than one
if ~(numel(idxmin) & numel(idxmax))
  glued(1:n)=NaN;
  return;
end
% take only a continuous mask, with no 0s in between
for i=idxmin:idxmax
  if ~mask(i)
    mask(i:idxmax)=0;
    idxmax=i-1;
    break;
  end
end
% check if there is enough points
if (idxmax-idxmin<10)
  glued(1:n)=NaN;
  return;
end

% Do a linear fit between both channels
if exist('toplot','var')
  [cfun]=fit(analog(mask),photon(mask),'poly1');
end
[a, b]=fastfit(analog(mask),photon(mask));

% glue vectors
ig=floor((idxmax+idxmin)/2);
% glued(1:ig)=cfun(analog(1:ig));
glued(1:ig)=bsxfun(@plus, bsxfun(@times,analog(1:ig),a), b);
glued(ig+1:n)=photon(ig+1:n);
glued=glued';

% Plot glue function 
if exist('toplot','var')
  plot(cfun,'m',analog(mask), photon(mask),'o');
  title('Linear fit for glueing');
  xlabel('Analog (mV)');
  ylabel('PC (MHz)');
  grid on;
  cfun
  pause;

  % Plot glued and PC
  semilogy(idx(1:3000),photon(1:3000),'r');
  hold on;
  semilogy(idx(1:3000),glued(1:3000),'b');
  semilogy(idx(mask),photon(mask),'.g');
  semilogy(idx(1:3000),analog(1:3000),'.m');
  legend('Uncorrected PC','Scaled Analog','fit region','analog');
  xlabel('#bins');
  ylabel('PC (MHz)');
  hold off;
end

%