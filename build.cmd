@echo off
cd /d %~dp0

cd review-starter

:: init
if exist techbookfest7-pdf rd /s/q techbookfest7-pdf
if exist techbookfest7.pdf del techbookfest7.pdf

:: build
:: wsl docker run --rm -v $PWD:/work kauplan/review2.5 /bin/bash -c "cd /work; rake pdf"
for /f %%A in ('wsl wslpath -a '%CD%'') do set WSLCD=%%A
set BASHCD=%WSLCD:/mnt/=/%

:: ebook
docker run --rm -v %BASHCD%:/work kauplan/review2.5 /bin/bash -c "export STARTER_TARGET=ebook; cd /work; mv config.yml _config.yml; mv _config_openany.yml config.yml; rake pdf; mv config.yml _config_openany.yml; mv _config.yml config.yml"
move /y techbookfest7.pdf ..\techbookfest7.ebook.pdf

:: pbook
REM docker run --rm -v %BASHCD%:/work kauplan/review2.5 /bin/bash -c "export STARTER_TARGET=pbook; cd /work; mv images _images; mv _images_gray images; rake pdf; mv images _images_gray; mv _images images"
docker run --rm -v %BASHCD%:/work kauplan/review2.5 /bin/bash -c "export STARTER_TARGET=pbook; cd /work; mv images _images; mv _images_gray images; rake pdf; rake pdf:nombre; mv images _images_gray; mv _images images"
move /y techbookfest7.pdf ..\techbookfest7.pbook.pdf

:: open
start %~dp0techbookfest7.ebook.pdf

pause
