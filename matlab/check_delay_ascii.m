function [rsq,tim] = check_delay_ascii(sig_an, sig_pc, discr, bits)

% length of data
n=length(sig_an);
anbg=nanmean(sig_an(n-500:n));
pcbg=nanmean(sig_pc(n-500:n));
anstd=nanstd(sig_an(n-500:n));
pcstd=nanstd(sig_pc(n-500:n));

disp(['check_delay:: an_bg= ' num2str(anbg) ' +- ' num2str(anstd)]);
disp(['check_delay:: pc_bg= ' num2str(pcbg) ' +- ' num2str(pcstd)]);
n=n-50;

% Resolution (mV) of analog channel)
resol=discr*1e3/2^bits;

figure(1)
i=1;
for delay = -10:30
  an=sig_an(50+delay:n+delay);
  pc=sig_pc(50:n);

  % Create a mask for the region where analog and PC are thought to be
  % proportional: below 15MHZ and above 5*resolution
  mask=(an>5*resol) & (pc<15.) & (an>anbg+3*anstd) & (pc>pcbg+3*pcstd);
  maskout=excludedata(an,pc,'indices',mask);

  % now correct for the background
  an=an-anbg;
  pc=pc-pcbg;

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

figure(2)
plot(tim,rsq); grid on;
title('Correlation between analog and PC');
%xlabel('Delay(bins)+1');
xlabel('Delay(bins)');
ylabel('R^2 from linear fit of PC x AN');

%