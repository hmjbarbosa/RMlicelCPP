
%% PLOTS
dtime=mod(jd,1)*24.;

figure(2)
[C2, h2]=gplot(mixr(1:1000,:), [0:1:20]);
title([datestr(jd(1)) ' to ' datestr(jd(nfile))]);
grid on;

figure(1)
[C1, h1]=gplot(channel(1).phy(1:1000,:));
title([datestr(jd(1)) ' to ' datestr(jd(nfile))]);
grid on;

%
%