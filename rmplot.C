void rmplot(char *fname, int chid) 
{
  RMDataFile rm;
  profile_read(fname, &rm);

  int nbin = rm.ch[chid].ndata;

  float x[16380]; 
  for (int i=0; i< nbin; i++) x[i]=i;

  TGraph *gr=new TGraph(nbin, x, rm.ch[chid].phy);
  gr->Draw("al");
}
