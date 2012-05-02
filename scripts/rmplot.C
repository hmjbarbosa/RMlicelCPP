void rmplot(char *fname, int chid, int opt=0) 
{
  RMDataFile rm;
  profile_read(fname, &rm);

  int nbin = rm.ch[chid].ndata;

  float x[16380], y[16380]; 
  for (int i=0; i< nbin; i++) {
    x[i]=i;
    y[i]=rm.ch[chid].phy[i];
    if (opt>0) y[i] *= pow(7.5*i, 2);
  }

  TGraph *gr=new TGraph(nbin, x, y);
  gr->Draw("al");
}
