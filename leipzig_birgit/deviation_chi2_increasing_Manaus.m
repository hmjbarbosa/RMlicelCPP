function [abl_chi2,chi2,q,u] = deviation_chi2_increasing_Manaus(input,range,rbbb,fit_width,datum2)
% ----------------------------------------------------
%  increasing the fit-width monotonically with increasing height 
%  - through changes in k and ndata!
% ----------------------------------------------------
%  is called by Raman_Manaus.m
%  calculate deviation           		09/06   BHeese
%  for Polly and PollyXT 		     	04/07   BHeese
%  adaption to Hefei Lidar              05/10 	BHeese	
%  adaption to Manaus Lidar             06/12 	BHeese	
%
warning off all
addpath('Numerical Recipes');
clear x y
%
lower = 2; % depends on overlap height
u = lower; 
%
% --------------------------------------
%    fit to a staight line y = a + bx
% --------------------------------------
mwt = 0;
sig = 0;  
%
deltar = range(2)-range(1); 
%
% ----------------------
%   writing a protocol 
% ----------------------
O = [lower , fit_width ];
dlmwrite(['protocol_linfit_' datum2 '.dat'], O,'delimiter', '\t');  
N = ['i' 'ndata'];
dlmwrite(['protocol_linfit_' datum2 '.dat'], N,'delimiter', '\t', '-append');
%
% --------------------------------------
%  lower part: variable fit-width
% --------------------------------------
for i = lower : lower + fit_width
  ndata = (2*(i-lower)+1); 
  % shall start at lower = 10 and shall only fit upwards
  % writing
  M = [range(i),ndata, ndata*deltar];
  dlmwrite(['protokol_linfit_' datum2 '.dat'], M, 'delimiter', '\t', '-append'); 
  %    
  x = range(i-(i-lower):i+(i-lower)+1); 
  y = input(i-(i-lower):i+(i-lower)+1); 
  [a,b,siga,sigb,chi2,q] = fit_chi2(x,y,ndata,sig,mwt); 
  yy = a + b.*x;   
  box on 
  hold on
  %    plot(x,y,'r')
  %    plot(x,yy,'g')
    
  abl_chi2(i) = (yy(ndata) - yy(1))/...
                        (x(ndata) - x(1));
end

plot(x,y,'r')
plot(x,yy,'g')

% ----------------------------
%      middle and upper part
% ----------------------------
for i = lower + fit_width+1 : rbbb - fit_width
  k = fix(0.1*i);
  ndata = 2*fit_width+1+2*k;
  % writing
  M = [range(i),ndata , ndata*deltar];
  dlmwrite(['protokol_linfit_' datum2 '.dat'], M, 'delimiter', '\t', '-append'); 
  %    
  x = range(i-fit_width+1-k : min(i+fit_width+1+k,rbbb));
  y = input(i-fit_width+1-k : min(i+fit_width+1+k,rbbb));
  [a,b,siga,sigb,chi2,q] = fit_chi2(x,y,ndata,sig,mwt); 
  yy = a + b.*x; 
  % figure(1)   
  %    plot(x,y,'b')
  %    plot(x,yy,'c')
    
  abl_chi2(i) = (yy(ndata) - yy(1)) / (x(ndata)- x(1));
  if i >= 0.9*rbbb
    return
  end
end

figure(1)   
plot(x,y,'b')
plot(x,yy,'c')

%