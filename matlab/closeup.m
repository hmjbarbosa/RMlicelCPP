%%function [C1, h1, C2, h2] = zoom(n1, n2)

if ~exist('z1','var') z1=1; end
if ~exist('z2','var') z2=size(mixr,1); end
if ~exist('n1','var') n1=1; end
if ~exist('n2','var') n2=size(mixr,2); end

figure(2)
hours=jd1/60.;
[C2, h2] = gplot(mixr(z1:z2,n1:n2), [0:1:20], [n1:n2], [z1:z2]);
grid on;

figure(1)
[C1, h1] = gplot(channel(1).phy(z1:z2,n1:n2), [], [n1:n2], [z1:z2]);
grid on;

%