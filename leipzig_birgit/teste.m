clear g1 g2 g3 g4 out1 out2 out3 out4
g1=fittype('(a-b)/(1+(x/x0)^p)+b');
g2=fittype('a*exp(-exp(-k*(x-x0)))');
g3=fittype('a/(1+exp(-k*(x-x0)))');
g4=fittype('(a+b*(x-x0))/(1+exp(-k*(x-x0)))');

n=600;
out1=fit(alt(1:n)*1e-3,overlap(1:n),g1,'startpoint',[0.1 1 1 0.1])
out2=fit(alt(1:n)*1e-3,overlap(1:n),g2,'startpoint',[1 10 0.1])
out3=fit(alt(1:n)*1e-3,overlap(1:n),g3,'startpoint',[1 10 0.1])
out4=fit(alt(1:n)*1e-3,overlap(1:n),g4,'startpoint',[1 0.1 10 0.1])

figure(91); clf
plot(alt(1:n)*1e-3,overlap(1:n),'o')
hold on 
plot(out1,'r')
plot(out2,'g')
plot(out3,'k')
plot(out4,'c')