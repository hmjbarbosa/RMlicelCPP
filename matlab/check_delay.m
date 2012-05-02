function [] = check_delay(sig_an, sig_pc, head)

% length of data
n=head.ndata(3);
n=n-100;

% Resolution (mV) of analog channel)
resol=head.discr(3)/2^head.bits(3);

for delay = 0:20
  an=sig_an(1+delay:n+delay);
  %phy(1+delay:n+delay,3);
  pc=sig_pc(1:n);
  %phy(1:n,4);

  % Create a mask for the region where analog and PC are thought to be
  % proportional: below 7MHZ and above 5*resolution
  mask=(an>5*resol) & (pc<5.);
  maskout=excludedata(an,pc,'indices',mask);

  % Do a linear fit between both channels
  % and stores the value of rsquare
  [cfun, gof, out]=fit(an(maskout),pc(maskout),'poly1');
  rsq(delay+1) = gof.rsquare;

  % Plot each step to the user
  plot(cfun,'m',an(maskout), pc(maskout),'o');
  s=['Delay(bins)=' int2str(delay) '  R^2=' num2str(gof.rsquare)]; 
  title(s);
  pause(0.2);
end

plot(rsq); grid on;
title('Correlation between analog and PC');
xlabel('Delay(bins)+1');
ylabel('R^2 from linear fit of PC x AN');

%