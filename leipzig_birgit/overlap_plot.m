
mfinal1=mean(finalover(:,1:28),2);
sfinal1 =std(finalover(:,1:28),0,2);

alt=[1:600]*7.5;
%mfinal2=mean(finalover(:,30:38),2);
%sfinal2 =std(finalover(:,30:38),0,2);

figure(300); clf; grid on; hold on;
plot(alt(1:600)*1e-3, finalover(1:600,:));
plot(alt(1:600)*1e-3, mfinal1(1:600),'r-','linewidth',3);
%plot(alt(1:600)*1e-3, mfinal2(1:600),'r-','linewidth',2);
%plot(alt(1:600)*1e-3, mfinal(1:600)+sfinal(1:600),'k--','linewidth',2);
%plot(alt(1:600)*1e-3, mfinal(1:600)-sfinal(1:600),'k--','linewidth',2);

%