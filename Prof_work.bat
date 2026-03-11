
@echo off
title Profilactic work %1
setlocal enabledelayedexpansion

rem *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*
rem *+*+*+*+* Prof_work.bat v 2.0 authored by  STARODUBCEV K.G. *+*+*+*+*
rem *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*




rem * // * ОПИСАНИЕ КОМАНДНОГО ФАЙЛА - НАЧАЛО * // *
rem *************************************************************************************************************
rem * Универсальный командный файл для проведения профилактических работ                                        *
rem * Параметр 1 - Тип профилактических работ \ метка для перехода:                                             *
rem *               1 - Disk_clean - очистка логических дисков \ DCL;                                           *
rem *               2 - Disk_defrag - дефрагментация логических дисков \ DDF;                                   * 
rem *               3 - Antivirus_check - проверка сервера на вирусы \ AVC;                                     * 
rem *               4 - Disk_check - проверка логических дисков на ошибки и исправление сбойных секторов\ DCH;  *
rem * Системные требования:                                                                                     *
rem *               Региональные параметры - Русский                                                            *
rem *               Формат времени - H:mm:ss                                                                    *
rem *************************************************************************************************************
rem * // * ОПИСАНИЕ КОМАНДНОГО ФАЙЛА - КОНЕЦ * // *




rem * // * КОНТРОЛЬ НА ВЫПОЛНЕНИЕ ДРУГИХ ПРОФИЛАКТИЧЕСКИХ РАБОТ В ДАННЫЙ МОМЕНТ - НАЧАЛО * // *
if exist run.txt exit
rem * // * КОНТРОЛЬ НА ВЫПОЛНЕНИЕ ДРУГИХ ПРОФИЛАКТИЧЕСКИХ РАБОТ В ДАННЫЙ МОМЕНТ - КОНЕЦ * // *




rem * // * КОНТРОЛЬ НА ПРИСУТСТВИЕ ВСЕХ ПАРАМЕТРОВ ПРИ ВЫЗОВЕ ДАННОГО КОММАНДНОГО ФАЙЛА - НАЧАЛО * // *
set WRONG=0
set PAR_1=%1
if not defined PAR_1 set WRONG=1
if %WRONG%==1 Ошибка выполнения профилактических работ, параметры не указан !
if %WRONG%==1 goto :EOF
rem * // * КОНТРОЛЬ НА ПРИСУТСТВИЕ ВСЕХ ПАРАМЕТРОВ ПРИ ВЫЗОВЕ ДАННОГО КОММАНДНОГО ФАЙЛА - КОНЕЦ * // *




rem * // * КОНТРОЛЬ НА ПРАВИЛЬНОСТЬ ПАРАМЕТРОВ ПРИ ВЫЗОВЕ ДАННОГО КОММАНДНОГО ФАЙЛА - НАЧАЛО * // *
set WRONG=2
for %%i in (Disk_clean Disk_defrag Antivirus_check Disk_check) do if /i %%i==%1 set WRONG=0
if !WRONG!==2 echo Ошибка выполнения профилактической работы, параметр указан неверно !
if !WRONG!==2 goto :EOF
rem * // * КОНТРОЛЬ НА ПРАВИЛЬНОСТЬ ПАРАМЕТРОВ ПРИ ВЫЗОВЕ ДАННОГО КОММАНДНОГО ФАЙЛА - КОНЕЦ * // *




rem * // * ОПРЕДЕЛЕНИЕ ЛОКАЛЬНЫХ ПЕРЕМЕННЫХ - НАЧАЛО * // *
ver > Output_prof_work.txt
set IS_2003=0
set VERSION=
for /f "tokens=4 skip=1" %%i in (Output_prof_work.txt) do (
    set VERSION=%%i
)
set VERSION=%VERSION:~0,1%
if %VERSION%==5 set IS_2003=1
if exist Output_prof_work.txt del /q Output_prof_work.txt
set DISK_LETTER=
for %%i in (C D E F G H I G K L M N O P) do (
if exist %%i:\PPR\Backup\BAT\Backup.bat set DISK_LETTER=%%i
)
set WORK_TYPE=%1
set LOG_FILE=%DISK_LETTER%:\PPR\Prof_work\LOG\%COMPUTERNAME%_%WORK_TYPE%.log
rem * // * ОПРЕДЕЛЕНИЕ ЛОКАЛЬНЫХ ПЕРЕМЕННЫХ - КОНЕЦ * // *




rem * // * ТЕЛО КОМАНДНОГО ФАЙЛА - НАЧАЛО * // *
echo Пожалуйста подождите, выполняются профилактические работы %WORK_TYPE% ...
echo. >> %LOG_FILE%
echo %DATE% %TIME% НАЧАЛО ВЫПОЛНЕНИЯ ПРОФИЛАКТИЧЕСКИХ РАБОТ ******************************************************* >> %LOG_FILE%
if /i %WORK_TYPE%==Disk_clean goto :DCL
if /i %WORK_TYPE%==Disk_defrag goto :DDF
if /i %WORK_TYPE%==Antivirus_check goto :AVC
if /i %WORK_TYPE%==Disk_check goto :DCH

:DCL
set DCL_OK=1
echo %DATE% %TIME% Производим очистку всех логических дисков >> %LOG_FILE%
cleanmgr.exe /sagerun:1 > Output_prof_work.txt 2>>&1
if not %ERRORLEVEL%==0 set DCL_OK=0
if %DCL_OK%==1 echo %DATE% %TIME% OK >> %LOG_FILE%
if %DCL_OK%==0 echo %DATE% %TIME% ОШИБКА >> %LOG_FILE%
if %DCL_OK%==0 type Output_prof_work.txt >> %LOG_FILE%
if %DCL_OK%==0 goto :ERR
goto :OK

:DDF
set DDF_OK_1=1
set DDF_OK_2=1
echo %DATE% %TIME% Производим дефрагментацию всех логических дисков >> %LOG_FILE%
for %%i in (C D E F G H I J K L M N O P) do (
    if exist %%i: echo !DATE! !TIME! Производим дефрагментацию диска %%i: >> %LOG_FILE%
    if exist %%i: defrag %%i: -f -v > Output_prof_work.txt 2>>&1
    if exist %%i: if not !ERRORLEVEL!==0 set DDF_OK_1=0
    if exist %%i: if not !ERRORLEVEL!==0 set DDF_OK_2=0
    if exist %%i: if !DDF_OK_2!==1 echo !DATE! !TIME! OK >> %LOG_FILE%
    if exist %%i: if !DDF_OK_2!==0 echo !DATE! !TIME! ОШИБКА >> %LOG_FILE%
    if exist %%i: if !DDF_OK_2!==0 type Output_prof_work.txt >> %LOG_FILE%
    if exist %%i: set !DDF_OK_2!=1
)
if %DDF_OK_1%==0 goto :ERR
goto :OK

:AVC
set AVC_OK=1
echo %DATE% %TIME% Производим проверку компьютера на наличие вирусов >> %LOG_FILE%
"%KASPERSKY_PATH%\avp.com" start scan_my_computer > Output_prof_work.txt 2>>&1
if not %ERRORLEVEL%==0 set AVC_OK=0
if %AVC_OK%==1 echo %DATE% %TIME% OK >> %LOG_FILE%
if %AVC_OK%==0 echo %DATE% %TIME% ОШИБКА >> %LOG_FILE%
if %AVC_OK%==0 type Output_prof_work.txt >> %LOG_FILE%
if %AVC_OK%==0 goto :ERR
goto :OK

rem Пока в разработке !!!
:DCH
set DCH_OK_1=1
set DCH_OK_2=1
echo %DATE% %TIME% Производим проверку всех логических дисков на ошибки >> %LOG_FILE%
if %IS_2003%==1 %for %%i in (C D E F G H I J K L M N O P) do (
    if exist %%i: echo !DATE! !TIME! Производим проверку диска %%i: >> %LOG_FILE%
    if exist %%i: chkdsk.exe c: /F /R > Output_prof_work.txt 2>>&1
    if exist %%i: if not !ERRORLEVEL!==0 set DCH_OK_1=0
    if exist %%i: if not !ERRORLEVEL!==0 set DCH_OK_2=0
    if exist %%i: if !DCH_OK_2!==1 echo !DATE! !TIME! OK >> %LOG_FILE%
    if exist %%i: if !DCH_OK_2!==0 echo !DATE! !TIME! ОШИБКА >> %LOG_FILE%
    if exist %%i: if !DCH_OK_2!==0 type Output_prof_work.txt >> %LOG_FILE%
    if exist %%i: set !DCH_OK_2!=1
)
if %IS_2003%==1 if %DCH_OK_1%==0 goto :ERR
if %IS_2003%==0 defrag -c -f -v > Output_prof_work.txt
if not %ERRORLEVEL%==0 set DCH_OK_1=0
if %DCH_OK_1%==1 echo %DATE% %TIME% OK >> %LOG_FILE%
if %DCH_OK_1%==0 echo %DATE% %TIME% ОШИБКА >> %LOG_FILE%
if %DCH_OK_1%==0 type Output_prof_work.txt >> %LOG_FILE%
if %DCH_OK_1%==0 goto :ERR
goto :OK
rem Пока в разработке !!!

:OK
echo %DATE% %TIME% Результат выполнения профилактических работ - OK >> %LOG_FILE%
goto :EXT

:ERR
echo %DATE% %TIME% Результат выполнения профилактических работ - ОШИБКА >> %LOG_FILE%
C:\Windows\Blat\blat.exe -tf C:\Windows\Blat\address.txt -subject "Ошибка выполнения профилактических работ %WORK_TYPE% на %COMPUTERNAME%" -body " " -charset UTF-32 -log C:\Windows\Blat\mail.log

:EXT
echo %DATE% %TIME% КОНЕЦ  ВЫПОЛНЕНИЯ ПРОФИЛАКТИЧЕСКИХ РАБОТ *************************************** >> %LOG_FILE%
echo. >>%LOG_FILE%
if exist %LOG_FILE% copy /v /y %LOG_FILE% \\10.167.31.8\Servers$\%COMPUTERNAME%\Prof_work_log
if %ERRORLEVEL%==0 goto :A
if exist %LOG_FILE% copy /v /y %LOG_FILE% \\10.167.31.9\Servers$\%COMPUTERNAME%\Prof_work_log
:A
if exist Output_prof_work.txt del /q Output_prof_work.txt
rem * // * ТЕЛО КОМАНДНОГО ФАЙЛА - КОНЕЦ * // *
