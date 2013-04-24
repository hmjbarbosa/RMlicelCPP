clear all
addpath('../matlab');
addpath('../sc');

jdi=datenum('29-Jul-2011 08:28:45'); jdf=datenum('29-Jul-2011 10:53:21');

read_ascii_Manaus3

figure(1)
for q=30:30
  x=mysmooth(mean(glue355(:,q-5:q+5),2),2,200);
  signal=remove_bg(x,500,3).*altsq;
  maxbin=min(find(isnan(signal)))-1;

  S=log(signal(1:maxbin));
  dS=diff(S); dSl=dS;

  % at first, not point should be excluded
  t=false(maxbin,1); 
  % except for the first one, to allow going into the loop
  t(1)=true;
  % So, while there are points to be removed, keep looping
  while any(t)
    dS(t)=NaN;
    cc=sum(isnan(dS));
    mm=nanmean(dS);
    ss=sqrt(nanmean(dS.*dS));

    t=abs(dS)>3*ss;
    sum(t)

    clf; plot(dSl); grid;
    hold on; plot(dS,'g'); plot(dS.*t,'r'); plot(ones(maxbin)*mm,'k');
    title(['cc=' num2str(cc) ' mean=' num2str(mm) ' std=' num2str(ss) ]);
    pause
  end
  
  % In the molecular range, dS should oscilate around zero and due
  % to random noise in the signal, it is very unlikely that more
  % than 5-6 consecutive points to appear above or below the line.
  nn=6;
  t=false(maxbin-1,1); 
  for i=nn+1:maxbin-nn-1
    t(i)=(all(dS(i:i+nn)>0) || all(dS(i:i+nn)<0) || ...
          all(dS(i-nn:i)>0) || all(dS(i-nn:i)<0));
  end
  sum(t)

  cc=sum(isnan(dS));
  mm=nanmean(dS);
  ss=sqrt(nanmean(dS.*dS));
  clf; plot(dSl); grid; ylim([-4*ss 4*ss]);
  hold on; plot(dS,'go-'); plot(dS.*t,'r'); plot(ones(maxbin)*mm,'k');
  title(['cc=' num2str(cc) ' mean=' num2str(mm) ' std=' num2str(ss) ]);
  pause

  dS(t)=NaN;

  cc=sum(isnan(dS));
  mm=nanmean(dS);
  ss=sqrt(nanmean(dS.*dS));
  clf; plot(dSl); grid; ylim([-4*ss 4*ss]);
  hold on; plot(dS,'go-'); plot(dS.*t,'r'); plot(ones(maxbin)*mm,'k');
  title(['cc=' num2str(cc) ' mean=' num2str(mm) ' std=' num2str(ss) ]);
  pause


end
    

%
