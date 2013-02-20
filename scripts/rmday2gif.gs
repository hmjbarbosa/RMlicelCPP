function rmday2gif(args)
reinit
'set display color white'
file=subwrd(args,1)
'xdfopen 'file

channel=subwrd(args,2)
if (channel='')
  channel='ch355an'
endif

* get time limits
'set t 1 last '
'q time'; d1=subwrd(result,3); d1=substr(d1,strlen(d1)-8,9)
say d1

* get number of vertical bins
'q ctlinfo'; lin=sublin(result,7); zmax=subwrd(lin,2)
zmin=zmax-500

* calculate background and std_dev for each time
'set z 1 '; 
say 'calculating bg'
'bg=ave('channel',z='zmin',z='zmax')'
say 'calculating sigma(bg)'
'bg2=ave('channel'*'channel',z='zmin',z='zmax')'
'sig=sqrt(bg2-bg*bg)'

* calculate range/background corrected signal
* arbitrarily divide by 1.e5
'set z 1 2000'
say 'calculating RCS'
'mask=const(maskout(lat*0+1,'channel'-bg(z=1)-3*sig(z=1)),-1,-u)'
'rcs=maskout('channel'-bg(z=1),mask)*lev*lev*7.5*7.5'
'rcst=ave(rcs,t-2,t+2)'
'rcstz=ave(rcst,z-2,z+2)'

* max and min
'set gxout stat'
'd rcstz'
line=sublin(result,8)
min=subwrd(line,4); min=min*1
max=subwrd(line,5); max=max*1
line=sublin(result,11)
ave=subwrd(line,2)
line=sublin(result,14)
sig=subwrd(line,2)

* plot
say 'plotting'
'palete2'
'clear'
'set grads off'
'set parea 1 9.7 0.8 7.4'
'set gxout grfill'
'set yaxis 0 15 1'
'set ylopts 1 1 0.17';  
'set xlopts 1 1 0.17'; 
'set tlsupp month'

ncores=137
*max=400.e5
max=ave+0*sig
k=0; ccol='1 '; clev=''
while(k<ncores)
  ccol=ccol' '237-k
  clev=clev' 'k*max/ncores
  k=k+1
endwhile
ccol=ccol'  15 '
clev=clev' 'k*max/ncores
'set clevs 'clev
'set ccols 'ccol

'd smth9(rcstz)'
'cbarn10 1 1 9.9'

* labels
'set string 1 c 1 90'
'set strsiz 0.20 '
'draw string 0.3 4.05 `0 Range ASL (km)'
'set string 1 c 1 0 '
'draw string 5.35 0.25 `0 Local Time (UTC-4)'
'set strsiz 0.24 '
'draw string 5.35 8.2 `0 Range and BG corrected signal [a.u.]'
'set strsiz 0.22 '
'draw string 5.35 7.7 `0 'channel' - 'd1

* output
n=strlen(file)
png=substr(file,1,n-4)
png=png'_'channel'.png'
'printim 'png
*end