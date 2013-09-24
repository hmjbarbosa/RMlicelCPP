clear all

% diametro do telescopio (mm)
tel_diam=400;

% campo de visao do telescopio (rad)
tel_fov=0.85e-3;

quantel_div=0.7e-3*2*2;
quantel_diam=5.3;

expansion=4;

% final diametro do laser (mm)
laser_diam=quantel_diam*expansion;

% final divergencia do laser (rad)
laser_div=quantel_div/expansion;

% separacao dos eixos (mm)
sepaxis=300;

% pos x da borda do telecopio (m)
x0=tel_diam*1e-3/2; 

% pos x da borda interna do laser (m);
x1=(sepaxis-laser_diam/2)*1e-3;

% pos x da borda externa do laser (m);
x2=(sepaxis+laser_diam/2)*1e-3;

%% equacao da borda do telecopio
x=[-20:0.02:20]; % m
ytel1=(x+x0)*tan(pi/2 + tel_fov/2);
ytel2=(x-x0)*tan(pi/2 - tel_fov/2);

%% equacao da borda interna do laser
ylaserIn=(x-x1)*tan(pi/2 +laser_div/2);
%% equacao da borda interna do laser
ylaserOut=(x-x2)*tan(pi/2 -laser_div/2);

figure(1); clf; hold on; grid on;
plot(x,ytel1*1e-3,'r--')
plot(x,ytel2*1e-3,'r')
ylim([0 5]);
xlim([0 2]);
xlabel('horizontal [m]');
ylabel('vertical [km]');

plot(x,ylaserIn*1e-3,'b--'); 
plot(x,ylaserOut*1e-3,'b'); 
%