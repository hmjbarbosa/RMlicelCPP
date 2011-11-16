function rmday2gif(file)
reinit
'set display color white'
'xdfopen 'file

* get time limits
'set t 1 last'
'q time'; d1=subwrd(result,3); d1=substr(d1,7,9)

* get number of vertical bins
'q ctlinfo'; lin=sublin(result,7); zmax=subwrd(lin,2)
zmin=zmax-500

* calculate background and std_dev for each time
'set z 1 '; 
'bg=ave(ch355an,z='zmin',z='zmax')'
'bg2=ave(ch355an*ch355an,z='zmin',z='zmax')'
'sig=sqrt(bg2-bg*bg)'

* calculate range/background corrected signal
* arbitrarily divide by 1.e5
'set z 1 2000'
'rcs=maskout(ch355an-bg,ch355an-bg-3*sig)*lev*lev/1e5'

* plot
'clear'
'set grads off'
'set parea 1 9.7 0.8 7.4'
'set gxout grfill'
'set yaxis 0 15 1'
'set ylopts 1 1 0.17';  
'set xlopts 1 1 0.17'; 
'set tlsupp month'
'd rcs'
'cbarn 1 1 10.1'

* labels
'set string 1 c 1 90'
'set strsiz 0.20 '
'draw string 0.3 4.05 `0 Range ASL (km)'
'set string 1 c 1 0 '
'draw string 5.35 0.25 `0 Local Time (UTC-4)'
'set strsiz 0.24 '
'draw string 5.35 8.2 `0 Range and BG corrected signal [a.u.]'
'set strsiz 0.22 '
'draw string 5.35 7.7 `0 Elastic 355nm/Analog - 'd1

* output
n=strlen(file)
png=substr(file,1,n-4)
png=png'.png'
'printim 'png
*end