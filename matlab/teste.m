%tmp=aero_ext_raman;
%idx=[1:size(tmp,1)];
%ok=min(idx(isnan(tmp)))-1;
%y=tmp(1:ok);

y=aero_ext_raman;
y(isnan(y))=0;

%fftf(alt, y);
%return
figure(101); clf;
plot(aero_ext_raman(10:end));
%ylim([-0.05 0.2]);

T=alt(2)-alt(1);
Fs=1/T;
L=size(y,1);
NFFT=2^nextpow2(L);
Y=fft(y,NFFT)/L;
f=Fs/2*linspace(0,1,NFFT/2+1);
% Plot single-sided amplitude spectrum.
figure(100); clf;
%plot(1./f,2*abs(Y(1:NFFT/2+1))) 
%set(gca,'xscale','log')
%xlabel(' (1/m)')
%plot(f,2*abs(Y(1:NFFT/2+1))) 
plot(abs(Y)) 
xlabel('Frequency (1/m)')
%
title('Single-Sided Amplitude Spectrum of y(t)')
ylabel('|Y(f)|')
grid
%plot(y);

Y2=Y;
n=150;
m=182;
Y2(2+n:2+m)=0;
%Y2(512-m:512-n)=0;
%Y2(20)=0;
%Y2(512)=0;
y2=ifft(Y2*L);
figure(101); hold on;
plot(real(y2(10:end)),'r');

