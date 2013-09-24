function [rsq,tim] = check_delay(sig_an, sig_pc, head)

% length of data
n=head.ch(1).ndata;
n=n-50;

% Resolution (mV) of analog channel)
resol=head.ch(1).discr/2^head.ch(1).bits;

figure(3)
i=1;
for delay = -10:30
  an=sig_an(50+delay:n+delay);
  %phy(1+delay:n+delay,3);
  pc=sig_pc(50:n);
  %phy(1:n,4);

  % Create a mask for the region where analog and PC are thought to be
  % proportional: below 7MHZ and above 5*resolution
  mask=(an>5*resol) & (pc<15.);
  maskout=excludedata(an,pc,'indices',mask);

  % Do a linear fit between both channels
  % and stores the value of rsquare
  [cfun, gof, out]=fit(an(maskout),pc(maskout),'poly1');
  tim(i) = delay;
  rsq(i) = gof.rsquare;

  % Plot each step to the user
  if (delay==0)
    plot(cfun,'m',an(maskout), pc(maskout),'o');
    s=['Delay(bins)=' int2str(delay) '  R^2=' num2str(gof.rsquare)]; 
    title(s);
    xlabel('Analog [mV]');
    ylabel('PC [Mhz]');
    pause(0.2);
  end
  i=i+1;
end

figure(4)
plot(tim,rsq); grid on;
title('Correlation between analog and PC');
%xlabel('Delay(bins)+1');
xlabel('Delay(bins)');
ylabel('R^2 from linear fit of PC x AN');

%