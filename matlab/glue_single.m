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
maskout=excludedata(analog,photon,'indices',mask);

% limits of fit region
idxmin=min(idx(maskout));
idxmax=max(idx(maskout));
if exist('toplot','var')
  {idxmin idxmax idxmax-idxmin}
end
% check if there is something different from NaN
if ~(numel(idxmin) & numel(idxmax))
  glued(1:n)=NaN;
  return;
end
% check if there is enough points
if (idxmax-idxmin<10)
  glued(1:n)=NaN;
  return;
end

% Do a linear fit between both channels
[cfun, gof]=fit(analog(maskout),photon(maskout),'poly1');

% glue vectors
ig=floor((idxmax+idxmin)/2);
glued(1:ig)=cfun(analog(1:ig));
glued(ig+1:n)=photon(ig+1:n);
glued=glued';

% Plot glue function 
if exist('toplot','var')
  plot(cfun,'m',analog(maskout), photon(maskout),'o');
  title('Linear fit for glueing');
  xlabel('Analog (mV)');
  ylabel('PC (MHz)');
  grid on;
  cfun
  pause;

  % Plot glued and PC
  semilogy(idx(1:1000),photon(1:1000),'r');
  hold on;
  semilogy(idx(1:1000),cfun(analog(1:1000)),'b');
  semilogy(idx(maskout),photon(maskout),'.g');
  legend('Uncorrected PC','Scaled Analog','fit region');
  hold off;
  pause
end

%