% Overlap Ulla iterative method
% The basic idea behind the iterative approach is that the aerosol signal,
% after correction of the range and overlap dependencies, is proportional 
% to the backscatter coefficient Po(z)O(z)-1z2 =~ beta_raman(z) + beta_o_mol(z)  
%          
clear delta_O PS overlap
it=1;
itnum = 0;
PS = P(:,1); 

initover=false;
if (initover)
  delta_O = (beta_raman(1:RefBin(1)) - beta_klett(1:RefBin(1)))./...
            (beta_raman(1:RefBin(1)) + beta_mol(1:RefBin(1),1));
  dts=diff((1-delta_O));
  i=2;
  while( ~ (dts(i)>dts(i-1) & dts(i)>dts(i+1)) )
    i=i+1;
  end
  n=2*i;

  figure(300); clf;
  n=450;
  plot((1-delta_O(1:n)),'o-r'); hold on;
  plot(diff((1-delta_O(1:n))),'o-b'); grid;

  initover=false;
  return
end

overlap=ones(n,1);
while it < 15
  %Eq. 7 Ulla 2002:  delta_O = (beta_raman - beta_klett)./(beta_raman + beta_o_mol);
  %warn: limit to RefBin, klett does not work upward
  delta_O = (beta_raman(1:n) - beta_klett(1:n))./...
            (beta_raman(1:n) + beta_mol(1:n,1));

  % accumulate contribuitions to the overlap
  overlap=overlap.*(1-delta_O);
  
  itnum = itnum + 1;
  it = it + 1;
  %Eq. 8 Ulla 2002:  Po i+1(z) = Po i(z)[1 + delta_O i(z)];
  %P(1:n,1) = P(1:n,1).*(1 + delta_O); 
  %P(1:n,1) = P(1:n,1)./(1 - delta_O);
  P(1:n,1) = PS(1:n,1)./overlap;
  Pr2(1:n,1) = P(1:n,1).*altsq(1:n);

  Klett_Manaus;

  PS(:,itnum+1) = P(:,1);

  if (debug>1)
    %figure(90); clf
    %plot(beta_raman(1:n),'r')
    %hold on;
    %plot(beta_klett(1:n),'b')

    figure(91); clf
    plot(overlap,alt(1:n)*1e-3)
    grid; 
  end
    
  %if (debug>1)
  %  ginput(1);
  %end
end
%overlap=PS(:,1)./PS(:,end);
P(1:n,2)=P(1:n,2)./overlap(1:n);
Pr2(1:n,2) = P(1:n,2).*altsq(1:n);

if (debug>1)
  %figure(90); grid

  figure(91); grid; 
  hold on; ylim([0 15e3]);
  plot(smooth_region(PS(:,1)./PS(:,end),3,500,9,1000,27),alt,'r')
end

%figure(10)
%hold on;
%plot(beta_klett(bin1st:maxbin,1)*1e3, alt(bin1st:maxbin),'b--');
%Raman_Manaus
%Raman_beta_Manaus
%addresult
%
