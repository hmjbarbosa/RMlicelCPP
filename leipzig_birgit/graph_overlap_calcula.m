clear all
allsyn;
save(sprintf('overlap%03d.mat',0),'alt','beta_klett','beta_raman', ...
     'alpha_klett','alpha_raman');
n=600;
Ulla_Overlap;
Raman_Manaus;
Raman_beta_Manaus;
save(sprintf('overlap%03d.mat',n),'alt','beta_klett','beta_raman', ...
     'alpha_klett','alpha_raman','overlap');

