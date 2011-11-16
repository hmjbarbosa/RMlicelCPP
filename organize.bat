echo off
cls
setlocal ENABLEEXTENSIONS
setlocal ENABLEDELAYEDEXPANSION

set DATA=d:\ftproot\lidar\data

for %%I IN (%DATA%\RM*) DO (
    @echo =====
    @echo %%I

    set arq=%%~nxI
    set yy=!arq:~2,2!
    set mm=!arq:~4,1!
    set dd=!arq:~5,2!

    if "!mm!" == "A"  set mm=10
    if "!mm!" == "B"  set mm=11
    if "!mm!" == "C"  set mm=12

    set dir=%DATA%\!yy!\!mm!\!dd!

    @echo !yy! !mm! !dd! !dir!

    if NOT EXIST !dir! mkdir !dir!
    move /Y %%I !dir!
)

set dir=
set arq=
set yy=
set mm=
set dd=
set h=
set m=
set dir=
echo on
