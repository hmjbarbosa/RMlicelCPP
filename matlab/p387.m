figure(3);
hold off;
plot(log(chphy(2).data(:,450)));
hold on;
plot(log(chphy(2).vsmooth(:,450)),'r');
plot(log(chphy(2).tsmooth(:,450)),'g');
plot(log(chphy(2).cs(:,89)),'c');
plot(log(glue355(:,89)),'k'); 
grid;
hold off;
%
figure(4);
hold off;
plot(log(chphy(4).data(:,450)));
hold on;
plot(log(chphy(4).vsmooth(:,450)),'r');
plot(log(chphy(4).tsmooth(:,450)),'g');
plot(log(chphy(4).cs(:,89)),'c');
plot(log(glue387(:,89)),'k'); 
grid;
hold off;
%