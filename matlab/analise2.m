%% ERASE MEMORY
clear; 

filelist = dir('data/11/2/04/RM*');
nfile = size(filelist);

myclock=clock; myclock(4:6)
for nf=1:nfile
  % open file keeping only head and each channel in physical units
  % correct anlog delay (10 bins)
  % correct dead-time (0.004 us)
  [head, phy(:,nf,1)]=profile_read2(['data/11/2/04/' filelist(nf).name], 10, 0.004,1);

  % save profile time-stamp
  jd(nf)=datenum([head.datei(3:-1:1) head.houri]);
end
myclock=clock; myclock(4:6)

%for i=1:head.ndata(1)
%  rcs(nf,i,:)=phy2(nf,i,:)*(7.5*i)^21:nz,1:nt;
%end

  % suaviza pra nao fazer isso em cima dos buracos 
  % abaixo de 3sgima
%  phy3=smooth_region(phy2, 3, 400, 7, 800, 15);

  % remove o BG  calculado dos ultimos 500 bins
  % valores menores que (bg+3*std) são zerados
%  [phy4, bg, std] = remove_bg(phy3, 500, 3);

  %% cola o signal analogico ao PC
  %% os valores zerados nao entram na conta pois sao menores que a resolucao
%  N2=glue(phy4(:,3), phy4(:,4), head);
%  H2O=phy4(:,4)';

%
%