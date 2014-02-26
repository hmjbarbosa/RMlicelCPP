betam1=mysmooth(nanmean(beta(minbin:maxbin, 1000:2000),2),0,0);
alfam1=mysmooth(nanmean(alfa(minbin:maxbin, 1000:2000),2),2,7);
ldr1=alfam1./betam1;

betam2=mysmooth(nanmean(beta(minbin:maxbin, 5300:6300),2),0,0);
alfam2=mysmooth(nanmean(alfa(minbin:maxbin, 5300:6300),2),2,7);
ldr2=alfam2./betam2;

ldr1(alfam1<2)=NaN;
ldr2(alfam2<2)=NaN;

ldr1(betam1<0.05)=NaN;
ldr2(betam2<0.05)=NaN;

ldr1=nanmysmooth(ldr1,4,10);
ldr2=nanmysmooth(ldr2,4,10);

figure(5);
clf
plot(betam1, zz(minbin:maxbin),'b');
hold on
grid on
plot(betam2, zz(minbin:maxbin), 'r');

figure(6);
clf
plot(alfam1, zz(minbin:maxbin),'b');
hold on
grid on
plot(alfam2, zz(minbin:maxbin), 'r');

figure(7);
clf
plot(ldr1, zz(minbin:maxbin),'b');
hold on
grid on
plot(ldr2, zz(minbin:maxbin), 'r');
%