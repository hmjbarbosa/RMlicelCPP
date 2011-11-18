function rmday2gif(file)
reinit
'set display color white'
'xdfopen 'file

* get time limits
'set t 1 last '
'q time'; d1=subwrd(result,3); d1=substr(d1,7,9)

* get number of vertical bins
'q ctlinfo'; lin=sublin(result,7); zmax=subwrd(lin,2)
zmin=zmax-500

* calculate background and std_dev for each time
'set z 1 '; 
say 'calculating bg'
'bg=ave(ch355an,z='zmin',z='zmax')'
say 'calculating sigma(bg)'
'bg2=ave(ch355an*ch355an,z='zmin',z='zmax')'
'sig=sqrt(bg2-bg*bg)'

* calculate range/background corrected signal
* arbitrarily divide by 1.e5
'set z 1 2000'
say 'calculating RCS'
'rcs=maskout(ch355an-bg(z=1),ch355an-bg(z=1)-3*sig(z=1))*lev*lev*7.5*7.5/1e5'

* plot
say 'plotting'
'palete.gs'
'clear'
'set grads off'
'set parea 1 9.7 0.8 7.4'
'set gxout grfill'
'set yaxis 0 15 1'
'set ylopts 1 1 0.17';  
'set xlopts 1 1 0.17'; 
'set tlsupp month'

k=0; ccol='1 '; clev=''
while(k<100)
  ccol=ccol' '101+k
  clev=clev' 'k*2
  k=k+1
endwhile
ccol=ccol'  1'
clev=clev' 'k*2
'set clevs 'clev
'set ccols 'ccol

'd rcs'
'cbarn10 1 1 10.1'

* labels
'set string 1 c 1 90'
'set strsiz 0.20 '
'draw string 0.3 4.05 `0 Range ASL (km)'
'set string 1 c 1 0 '
'draw string 5.35 0.25 `0 Local Time (UTC-4)'
'set strsiz 0.24 '
'draw string 5.35 8.2 `0 Range and BG corrected signal [a.u. x 10`a5`n]'
'set strsiz 0.22 '
'draw string 5.35 7.7 `0 Elastic 355nm/Analog - 'd1

* output
n=strlen(file)
png=substr(file,1,n-4)
png=png'.png'
'printim 'png
*end