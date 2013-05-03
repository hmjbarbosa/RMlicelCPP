% Overlap Ulla iterative method
% The basic idea behind the iterative approach is that the aerosol signal,
% after correction of the range and overlap dependencies, is proportional 
% to the backscatter coefficient Po(z)O(z)-1z2 =~ beta_raman(z) + beta_o_mol(z)  
%
it=1;
itnum = 0;
PS = P(:,1); 
while it < 15
  %Eq. 7 Ulla 2002:  delta_O = (beta_raman - beta_klett)./(beta_raman + beta_o_mol);
  delta_O = (beta_raman - beta_klett)./(beta_raman + beta_mol(:,1));
  itnum = itnum + 1;
  %it = input('otra?:','s')
  it = it + 1;
  %Eq. 8 Ulla 2002:  Po i+1(z) = Po i(z)[1 + delta_O i(z)];
  %    P(1:maxbin,1) = P(1:maxbin,1).*(1 + delta_O);
  P(1:maxbin,1) = P(1:maxbin,1)./(1 - delta_O);
  Pr2(:,1) = P(:,1).*altsq(:);
  Klett_Manaus;
  PS(:,itnum+1) = P(:,1);
  
  
  figure(90); clf
  plot(beta_raman(1:100),'r')
  hold on;
  plot(beta_klett(1:100),'b')
  
  figure(91); clf
  plot(PS(:,1)./PS(:,end),alt)
  grid; hold on; ylim([0 10e3]);
  plot(smooth_region(PS(:,1)./PS(:,end),3,500,9,1000,27),alt,'r')
end
overlap=PS(:,1)./PS(:,end);
P(:,2)=P(:,2)./overlap(:);
Pr2(:,2) = P(:,2).*altsq(:);

figure(90); grid
%figure(91); grid; 
%hold on; ylim([0 10e3]);
%plot(smooth_region(PS(:,1)./PS(:,end),3,500,9,1000,27),alt,'r')

