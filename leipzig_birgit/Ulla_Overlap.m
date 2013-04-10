% Overlap Ulla iterative method
% The basic idea behind the iterative approach is that the aerosol signal,
% after correction of the range and overlap dependencies, is proportional 
% to the backscatter coefficient Po(z)O(z)-1z2 =~ beta_raman(z) + beta_o_mol(z)  
%
%function [fsol] = OverlapU(beta_raman, beta_klett, beta_mol)% Ulla 2002 iterative method...

clear all
addpath('../matlab');
addpath('../sc');
% windows' size
wsx=250; wsy=650; 
% displacement for next window
wdx=260; xx0=-wsx;
% start position
wdy=0;   yy0=50;

%jdi=datenum('2011-08-30 23:00');
%jdf=datenum('2011-08-30 23:50');
%read_ascii_Manaus3;
read_ascii_synthetic

%P(:,1)=mean(chphy(1).data(:,1:1),2); % an 355
%P(:,2)=mean(chphy(3).data(:,1:1),2); % an 387
%
%P(:,1)=smooth_region(P(:,1),3,500,7,1000,9);
%P(:,2)=smooth_region(P(:,2),3,500,7,1000,9);
%
%Pr2(:,1) = P(:,1).*altsq(:);
%Pr2(:,2) = P(:,2).*altsq(:);

%read_ascii_Manaus;

constants;
radiofile='../../sondagens/dat/82332_2011_08_31_00Z.dat';
read_sonde_synthetic
%read_sonde_Manaus3
%read_sonde_Manaus;

molecular;
rayleigh_fit_Manaus3;
Klett_Manaus;
Raman_Manaus;
Raman_beta_Manaus;
return;
itnum = 0;it=1;
%Eq. 7 Ulla 2002:  delta_O = (beta_raman - beta_klett)./(beta_raman + beta_o_mol);
PS = P(:,1); 
while it < 15 %~strcmp(it,'n')
    delta_O = (beta_raman - beta_aerosol(1:length(beta_raman)))./(beta_raman + beta_mol(1:length(beta_raman),1)');
    itnum = itnum + 1;
    %it = input('otra?:','s')
    it = it + 1;
    %Eq. 8 Ulla 2002:  Po i+1(z) = Po i(z)[1 + delta_O i(z)];
    P(1:length(beta_raman),1) = P(1:length(beta_raman),1).*(1 + delta_O)';
%    P(1:length(beta_raman),1) = P(1:length(beta_raman),1)./(1 - delta_O)';
    Pr2(:,1) = P(:,1).*altsq(:);
    Klett_Manaus;
    PS(:,itnum+1) = P(:,1);
    
    
    figure(90); clf
    plot(beta_raman,'r')
    hold on;
    plot(beta_aerosol(1:length(beta_raman)),'b')
    
    figure(91); clf
    plot(PS(:,1)./PS(:,end),alt)
    grid; hold on; ylim([0 10e3]);
    plot(smooth_region(PS(:,1)./PS(:,end),3,500,9,1000,27),alt,'r')
end
P(:,2)=P(:,2)./PS(:,1).*PS(:,end);
Pr2(:,2) = P(:,2).*altsq(:);

figure(90); grid
%figure(91); grid; 
%hold on; ylim([0 10e3]);
%plot(smooth_region(PS(:,1)./PS(:,end),3,500,9,1000,27),alt,'r')

