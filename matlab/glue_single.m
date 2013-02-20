function [glued] = glue_single(anSignal, anChannel, pcSignal, pcChannel, toplot)

N=ndims(anSignal);
if (N>1)
  [nx ny] = size(anSignal);
  if (ny>1 || N>2)
    error('Only 1-dim to glue!')
  end
end

% Length of data
n=anChannel.ndata;
idx=1:n;

% Resolution (mV) of analog channel)
resol=anChannel.discr/2^anChannel.bits;
if exist('toplot','var')
  disp(['resol= ' num2str(resol)]);
end

% Create a mask for the region where analog and PC are thought to be
% proportional: below 7MHZ and above 5*resolution
mask=(anSignal>5*resol) & (anSignal>0.) & (anSignal~=NaN) & ...
     (pcSignal<7.)      & (pcSignal>0.) & (pcSignal~=NaN);
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
  if exist('toplot','var')
    disp(['error #1']);
  end  
  glued(1:n)=NaN;
  return;
end
% take only a continuous mask, with no 0s in between
%for i=idxmin:idxmax
%  if ~mask(i)
%    mask(i:idxmax)=0;
%    idxmax=i-1;
%    break;
%  end
%end
% check if there is enough points
if (idxmax-idxmin<10 || sum(mask)<10)
  glued(1:n)=NaN;
  if exist('toplot','var')
    disp(['error #2']);
  end  
  return;
end

% Do a linear fit between both channels
if exist('toplot','var')
  [cfun]=fit(anSignal(mask),pcSignal(mask),'poly1');
end
[a, b]=fastfit(anSignal(mask),pcSignal(mask));

% glue vectors
ig=floor((idxmax+idxmin)/2);
% glued(1:ig)=cfun(anSignal(1:ig));
glued(1:ig)=bsxfun(@plus, bsxfun(@times,anSignal(1:ig),a), b);
glued(ig+1:n)=pcSignal(ig+1:n);
glued=glued';

% Plot glue function 
if exist('toplot','var')
  plot(cfun,'m',anSignal(mask), pcSignal(mask),'o');
  title('Linear fit for glueing');
  xlabel('anSignal (mV)');
  ylabel('pcSignal (MHz)');
  grid on;
  cfun
  pause;

  % Plot glued and PC
  semilogy(idx(1:3000),pcSignal(1:3000),'r');
  hold on;
  semilogy(idx(1:3000),glued(1:3000),'b');
  semilogy(idx(mask),pcSignal(mask),'.g');
  semilogy(idx(1:3000),anSignal(1:3000),'.m');
  legend('Uncorrected PC','Scaled Analog','fit region','analog');
  xlabel('#bins');
  ylabel('PC (MHz)');
  hold off;
end

%