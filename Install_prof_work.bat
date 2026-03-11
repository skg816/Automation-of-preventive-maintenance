
@echo off
title Install profilactic work
setlocal enabledelayedexpansion

rem *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*
rem *+*+*+*+* Install_prof_work.bat v 1.0 authored by STARODUBCEV K.G.  *+*+*+*+*
rem *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*

echo.
echo КОМАНДНЫЙ ФАЙЛ ДЛЯ РАЗВЕРТЫВАНИЯ СИСТЕМЫ ПРОФИЛАКТИЧЕСКИХ РАБОТ
echo.
echo.

rem ********** ОПРЕДЕЛЯЕМ ВЕРСИЮ ОПЕРАЦИОННОЙ СИСТЕМЫ **********
ver > Output.txt
set IS_2003=0
set VERSION=
for /f "tokens=4 skip=1" %%i in (Output.txt) do (
    set VERSION=%%i
)
set VERSION=%VERSION:~0,1%
if %VERSION%==5 set IS_2003=1
if exist Output.txt del /q Output.txt
rem ********** ОПРЕДЕЛЯЕМ ВЕРСИЮ ОПЕРАЦИОННОЙ СИСТЕМЫ **********



rem ********** ОПРЕДЕЛЯЕМ НАСТРОЕНА ЛИ ОБВЯЗКА **********
schtasks > Output.txt
set IS_BASIC_EXIST=0
for /f "skip=3" %%i in (Output.txt) do (
    if /i %%i==01_Start_prof_work set IS_BASIC_EXIST=1
)
if exist Output.txt del /q Output.txt
rem ********** ОПРЕДЕЛЯЕМ НАСТРОЕНА ЛИ ОБВЯЗКА **********



rem ********** ЧИТАЕМ ЛИБО ЗАПРАШИВАЕМ ПАРАМЕТРЫ ОБВЯЗКИ **********
echo 1. НАЧИНАЕМ СБОР ПЕРВОНАЧАЛЬНЫХ ДАННЫХ
echo.
if %IS_BASIC_EXIST%==1 goto :A
if %IS_BASIC_EXIST%==0 goto :B
:A
set DISK_LETTER=
set START_TIME=
set USER_NAME=
schtasks /query /fo csv /v > Output.txt
set TEMP_1=
set TEMP_2=
for /f "delims=*" %%i in (Output.txt) do (
    set TEMP_1=%%i
    set TEMP_2=!TEMP_1:","","=","TERMINATOR","!
    set TEMP_2=!TEMP_2:","=*!
    echo !TEMP_2! >> Output_2.txt
)
if %IS_2003%==1 goto :C
if %IS_2003%==0 goto :E
:C
for /f "delims=* tokens=2,10,15,20" %%i in (Output_2.txt) do (
    if /i %%i==01_Start_prof_work set DISK_LETTER=%%j
    if /i %%i==01_Start_prof_work set START_TIME=%%k
    if /i %%i==01_Start_prof_work set USER_NAME=%%l
)
goto :F
:E
for /f "delims=* tokens=2,9,15,20" %%i in (Output_2.txt) do (
    if /i %%i==\01_Start_prof_work set DISK_LETTER=%%j
    if /i %%i==\01_Start_prof_work set START_TIME=%%l
    if /i %%i==\01_Start_prof_work set USER_NAME=%%k
)
:F
set DISK_LETTER=%DISK_LETTER:~0,1%
set TEMP_1=%START_TIME:~1,1%
if %TEMP_1%==: set START_TIME=0%START_TIME%
if exist Output.txt del /q Output.txt
if exist Output_2.txt del /q Output_2.txt
:G
set USER_PASS_OK=0
set USER_PASS=
set TASK_NAME=%RANDOM%
set PROC=%PROCESSOR_ARCHITECTURE:~-2%
cd Other
if %PROC%==86 editv32 -m -p "*     Введите пароль пользователя %USER_NAME%: " USER_PASS
if %PROC%==64 editv64 -m -p "*     Введите пароль пользователя %USER_NAME%: " USER_PASS
cd ..
if not defined USER_PASS echo *     ОШИБКА. Неверный пароль & goto :G
schtasks /create /ru %USER_NAME% /rp %USER_PASS% /sc daily /st 23:00 /tn %TASK_NAME% /tr %DISK_LETTER%:\PPR\Prof_work\BAT\Prof_work.bat /f > Output.txt 2>>&1
for /f %%i in (Output.txt) do (
    if /i %%i==УСПЕХ. set USER_PASS_OK=1
    if /i %%i==SUCCESS: set USER_PASS_OK=1
    if /i %%i==ПРЕДУПРЕЖДЕНИЕ. set USER_PASS_OK=0
    if /i %%i==WARNING: set USER_PASS_OK=0
)
schtasks /delete /tn %TASK_NAME% /f > Output.txt 2>>&1
if %USER_PASS_OK%==0 echo *     ОШИБКА. Неверный пароль & goto :G
if %USER_PASS_OK%==1 echo *     OK
if exist Output.txt del /q Output.txt
goto :END1
:B
set DISK_LETTER=
set /p DISK_LETTER=*     Введите букву диска, где будет находиться папка PPR (пример D): 
if not defined DISK_LETTER echo *     ОШИБКА. Неверная буква диска & goto :B
if not exist %DISK_LETTER%: echo *     ОШИБКА. Неверная буква диска & goto :B
if exist %DISK_LETTER%: echo *     OK
:H
set ACCOUNT_TYPE=
set ACCOUNT_TYPE_OK=0
echo *     Укажите тип учетной записи, которая будет использоваться в задании по
set /p ACCOUNT_TYPE=*     расписанию: 1 - локальная учетная запись, 2 - доменная учетная запись: 
if not defined ACCOUNT_TYPE echo *     ОШИБКА. Неверное значение & goto :H
for %%i in (1 2) do (if !ACCOUNT_TYPE!==%%i set ACCOUNT_TYPE_OK=1)
if %ACCOUNT_TYPE_OK%==0 echo *     ОШИБКА. Неверное значение & goto :H
if %ACCOUNT_TYPE_OK%==1 echo *     OK
:I
set USER_NAME=
set USER_NAME_OK=0
set /p USER_NAME=*     Введите имя учетной записи: 
if not defined USER_NAME echo *     ОШИБКА. Неверное имя учетной записи & goto :I
if %ACCOUNT_TYPE%==1 goto :J
if %ACCOUNT_TYPE%==2 goto :K
:J
net user > Output.txt
for /f "tokens=1,2,3 skip=4" %%i in (Output.txt) do (
    if /i !USER_NAME!==%%i set USER_NAME_OK=1
    if /i !USER_NAME!==%%j set USER_NAME_OK=1
    if /i !USER_NAME!==%%k set USER_NAME_OK=1
)
if %USER_NAME_OK%==0 echo *     ОШИБКА. Неверное имя учетной записи & goto :I
if %USER_NAME_OK%==1 echo *     OK
set USER_NAME=%COMPUTERNAME%\%USER_NAME%
if exist Output.txt del /q Output.txt
goto :L
:K
if %IS_2003%==0 servermanagercmd -install RSAT-ADDC -allsubfeatures > Output.txt 2>>&1
if exist Output.txt del /q Output.txt
dsquery user -samid %USER_NAME% -o samid > Output.txt
for /f %%i in (Output.txt) do (if /i "!USER_NAME!"==%%i set USER_NAME_OK=1)
if %USER_NAME_OK%==0 echo *     ОШИБКА. Неверное имя учетной записи & goto :I
if %USER_NAME_OK%==1 echo *     OK
set USER_NAME=KAS\%USER_NAME%
if exist Output.txt del /q Output.txt
:L
set USER_PASS=
set USER_PASS_OK=0
set TASK_NAME=%RANDOM%
set PROC=%PROCESSOR_ARCHITECTURE:~-2%
cd Other
if %PROC%==86 editv32 -m -p "*     Введите пароль пользователя %USER_NAME%: " USER_PASS
if %PROC%==64 editv64 -m -p "*     Введите пароль пользователя %USER_NAME%: " USER_PASS
cd ..
if not defined USER_PASS echo *     ОШИБКА. Неверный пароль & goto :L
schtasks /create /ru %USER_NAME% /rp %USER_PASS% /sc daily /st 23:00 /tn %TASK_NAME% /tr %DISK_LETTER%:\PPR\Prof_work\BAT\Prof_work.bat > Output.txt 2>>&1
for /f %%i in (Output.txt) do (
    if /i %%i==УСПЕХ. set USER_PASS_OK=1
    if /i %%i==SUCCESS: set USER_PASS_OK=1
    if /i %%i==ПРЕДУПРЕЖДЕНИЕ. set USER_PASS_OK=0
    if /i %%i==WARNING: set USER_PASS_OK=0
)
schtasks /delete /tn %TASK_NAME% /f > Output.txt 2>>&1
if %USER_PASS_OK%==0 echo *     ОШИБКА. Неверный пароль & goto :L
if %USER_PASS_OK%==1 echo *     OK
if exist Output.txt del /Q Output.txt
:M
set START_TIME=
set START_TIME_OK=0
set /p START_TIME=*     Введите время старта профилактических работ (пример ЧЧ:ММ): 
set START_TIME=%START_TIME:~0,5%
set FIRST=%START_TIME:~0,1%
set SECOND=%START_TIME:~1,1%
set THIRD=%START_TIME:~2,1%
set FOURTH=%START_TIME:~3,1%
set FIFTH=%START_TIME:~4,1%
set HH=%START_TIME:~0,2%
set MM=%START_TIME:~3,2%
if not defined FIRST echo *     ОШИБКА. Неверное значение & goto :M
if not defined SECOND echo *     ОШИБКА. Неверное значение & goto :M
if not defined THIRD echo *     ОШИБКА. Неверное значение & goto :M
if not defined FOURTH echo *     ОШИБКА. Неверное значение & goto :M
if not defined FIFTH echo *     ОШИБКА. Неверное значение & goto :M
for %%i in (0 1 2) do (if !FIRST!==%%i set START_TIME_OK=1)
if %START_TIME_OK%==0 echo *     ОШИБКА. Неверное значение & goto :M
set START_TIME_OK=0
for %%i in (0 1 2 3 4 5 6 7 8 9) do (if !SECOND!==%%i set START_TIME_OK=1)
if %START_TIME_OK%==0 echo *     ОШИБКА. Неверное значение & goto :M
set START_TIME_OK=0
if not %THIRD%==: echo *     ОШИБКА. Неверное значение & goto :M
for %%i in (0 1 2 3 4 5) do (if !FOURTH!==%%i set START_TIME_OK=1)
if %START_TIME_OK%==0 echo *     ОШИБКА. Неверное значение & goto :M
set START_TIME_OK=0
for %%i in (0 1 2 3 4 5 6 7 8 9) do (if !FIFTH!==%%i set START_TIME_OK=1)
if %START_TIME_OK%==0 echo *     ОШИБКА. Неверное значение & goto :M
if %HH% GTR 23 echo *     ОШИБКА. Неверное значение & goto :M
if %MM% GTR 59 echo *     ОШИБКА. Неверное значение & goto :M
echo *     OK
:END1
echo.
echo *     РЕЗЮМЕ:
echo *     Местоположение папки PPR - Диск %DISK_LETTER%
echo *     Запускать профилактические работы от имени пользователя - %USER_NAME%
echo *     Запускать профилактические работы в - %START_TIME%
echo.
rem ********** ЧИТАЕМ ЛИБО ЗАПРАШИВАЕМ ПАРАМЕТРЫ ОБВЯЗКИ **********



rem ********** ПЕРВОНАЧАЛЬНАЯ НАСТРОЙКА **********
echo.
echo 2. НАЧИНАЕМ ПЕРВОНАЧАЛЬНУЮ НАСТРОЙКУ
echo.
if not exist %DISK_LETTER%:\PPR mkdir %DISK_LETTER%:\PPR > Output.txt 2>>&1
if exist %DISK_LETTER%:\PPR echo *     Папка %DISK_LETTER%:\PPR - OK
if not exist %DISK_LETTER%:\PPR echo *     Папка %DISK_LETTER%:\PPR - ОШИБКА. Папка не создана & type Output.txt
if not exist %DISK_LETTER%:\PPR\Prof_work mkdir %DISK_LETTER%:\PPR\Prof_work > Output.txt 2>>&1
if exist %DISK_LETTER%:\PPR\Prof_work echo *     Папка %DISK_LETTER%:\PPR\Prof_work - OK
if not exist %DISK_LETTER%:\PPR\Prof_work echo *     Папка %DISK_LETTER%:\PPR\Prof_work - ОШИБКА. Папка не создана & type Output.txt
if not exist %DISK_LETTER%:\PPR\Prof_work\BAT mkdir %DISK_LETTER%:\PPR\Prof_work\BAT > Output.txt 2>>&1
if exist %DISK_LETTER%:\PPR\Prof_work\BAT echo *     Папка %DISK_LETTER%:\PPR\Prof_work\BAT - OK
if not exist %DISK_LETTER%:\PPR\Prof_work\BAT echo *     Папка %DISK_LETTER%:\PPR\Prof_work\BAT - ОШИБКА. Папка не создана & type Output.txt
if exist Output.txt del /q Output.txt
cd BAT
if not exist %DISK_LETTER%:\PPR\Prof_work\BAT\Prof_work.bat copy /v /y Prof_work.bat %DISK_LETTER%:\PPR\Prof_work\BAT > Output.txt 2>>&1
if exist %DISK_LETTER%:\PPR\Prof_work\BAT\Prof_work.bat echo *     Файл %DISK_LETTER%:\PPR\Prof_work\BAT\Prof_work.bat - OK
if not exist %DISK_LETTER%:\PPR\Prof_work\BAT\Prof_work.bat echo *     Файл %DISK_LETTER%:\PPR\Prof_work\BAT\Prof_work.bat - ОШИБКА. Файл не скопирован & type Output.txt
if not exist %DISK_LETTER%:\PPR\Prof_work\BAT\Start_prof_work.bat copy /v /y Start_prof_work.bat %DISK_LETTER%:\PPR\Prof_work\BAT > Output.txt 2>>&1
if exist %DISK_LETTER%:\PPR\Prof_work\BAT\Start_prof_work.bat echo *     Файл %DISK_LETTER%:\PPR\Prof_work\BAT\Start_prof_work.bat - OK
if not exist %DISK_LETTER%:\PPR\Prof_work\BAT\Start_prof_work.bat echo *     Файл %DISK_LETTER%:\PPR\Prof_work\BAT\Start_prof_work.bat - ОШИБКА. Файл не скопирован & type Output.txt
if exist Output.txt del /q Output.txt
cd ..
if not exist %DISK_LETTER%:\PPR\Prof_work\LOG mkdir %DISK_LETTER%:\PPR\Prof_work\LOG > Output.txt 2>>&1
if exist %DISK_LETTER%:\PPR\Prof_work\LOG echo *     Папка %DISK_LETTER%:\PPR\Prof_work\LOG - OK
if not exist %DISK_LETTER%:\PPR\Prof_work\LOG echo *     Папка %DISK_LETTER%:\PPR\Prof_work\LOG - ОШИБКА. Папка не создана & type Output.txt
if exist Output.txt del /q Output.txt
cd Blat
if not exist C:\Windows\Blat mkdir C:\Windows\Blat > Output.txt 2>>&1
if exist C:\Windows\Blat echo *     Папка C:\Windows\Blat - OK
if not exist C:\Windows\Blat echo *     Папка C:\Windows\Blat - ОШИБКА. Папка не создана & type Output.txt
if not exist C:\Windows\Blat\address.txt copy /V /Y address.txt C:\Windows\Blat > Output.txt 2>>&1
if exist C:\Windows\Blat\address.txt echo *     Файл C:\Windows\Blat\Address.txt - OK
if not exist C:\Windows\Blat\address.txt echo *     Файл C:\Windows\Blat\Address.txt - ОШИБКА. Файл не создан & type Output.txt
if not exist C:\Windows\Blat\blat.dll copy /V /Y blat.dll C:\Windows\Blat > Output.txt 2>>&1
if exist C:\Windows\Blat\blat.dll echo *     Файл C:\Windows\Blat\Blat.dll - OK
if not exist C:\Windows\Blat\blat.dll echo *     Файл C:\Windows\Blat\Blat.dll - ОШИБКА. Файл не создан & type Output.txt
if not exist C:\Windows\Blat\blat.exe copy /V /Y blat.exe C:\Windows\Blat > Output.txt 2>>&1
if exist C:\Windows\Blat\blat.exe echo *     Файл C:\Windows\Blat\Blat.exe - OK
if not exist C:\Windows\Blat\blat.exe echo *     Файл C:\Windows\Blat\Blat.exe - ОШИБКА. Файл не создан & type Output.txt
if not exist C:\Windows\Blat\blat.lib copy /V /Y blat.lib C:\Windows\Blat > Output.txt 2>>&1
if exist C:\Windows\Blat\blat.lib echo *     Файл C:\Windows\Blat\Blat.lib - OK
if not exist C:\Windows\Blat\blat.lib echo *     Файл C:\Windows\Blat\Blat.lib - ОШИБКА. Файл не создан & type Output.txt
if not exist C:\Windows\Blat\mail.log copy /V /Y mail.log C:\Windows\Blat > Output.txt 2>>&1
if exist C:\Windows\Blat\mail.log echo *     Файл C:\Windows\Blat\Mail.log - OK
if not exist C:\Windows\Blat\mail.log echo *     Файл C:\Windows\Blat\Mail.log - ОШИБКА. Файл не создан & type Output.txt
if exist Output.txt del /q Output.txt
set MAIL_OK=0
C:\Windows\Blat\Blat.exe -install 10.167.31.1 PPR@%COMPUTERNAME%.message 5 25 > Output.txt 2>>&1
if not %ERRORLEVEL%==0 set MAIL_OK=1
if %MAIL_OK%==0 echo *     Настройки почты - ОК
if %MAIL_OK%==1 echo *     Настройки почты - ОШИБКА. & type Output.txt
if exist Output.txt del /q Output.txt
cd ..
if %IS_BASIC_EXIST%==1 goto :END2
if %IS_2003%==1 schtasks /create /ru %USER_NAME% /rp %USER_PASS% /sc daily /st %START_TIME% /tn 01_Start_prof_work /tr "%DISK_LETTER%:\PPR\Prof_work\BAT\Start_prof_work.bat" > Output.txt 2>>&1
if %IS_2003%==0 schtasks /create /ru %USER_NAME% /rp %USER_PASS% /sc daily /st %START_TIME% /tn 01_Start_prof_work /tr "%DISK_LETTER%:\PPR\Prof_work\BAT\Start_prof_work.bat" /rl highest > Output.txt 2>>&1
set IS_BASIC_EXIST=0
for /f %%i in (Output.txt) do (
    if /i %%i==УСПЕХ. set IS_BASIC_EXIST=1
    if /i %%i==SUCCESS: set IS_BASIC_EXIST=1
    if /i %%i==ПРЕДУПРЕЖДЕНИЕ. set IS_BASIC_EXIST=0
    if /i %%i==WARNING: set IS_BASIC_EXIST=0
)
:END2
if %IS_BASIC_EXIST%==1 echo *     Задание по расписанию 01_Start_prof_work - OK
if %IS_BASIC_EXIST%==0 echo *     Задание по расписанию 01_Start_prof_work - ОШИБКА. & type Output.txt
if exist Output.txt del /q Output.txt
echo.
rem ********** ПЕРВОНАЧАЛЬНАЯ НАСТРОЙКА **********



rem ********** ОКОНЧАТЕЛЬНАЯ НАСТРОЙКА **********
echo.
echo 3. НАЧИНАЕМ ОКОНЧАТЕЛЬНУЮ НАСТРОЙКУ
echo.
:N
set WORK_TYPE=
set WORK_TYPE_OK=0
echo *     Выберите тип профилактических работ: 
echo *     1  - Очистка логических дисков
echo *     2  - Дефрагментация логических дисков
echo *     3  - Проверка логических дисков на наличие вирусов
echo *     4  - Проверка логических дисков на наличие ошибок
set /p WORK_TYPE=*     
if not defined WORK_TYPE echo *     ОШИБКА. Неверный тип профилактических работ & goto :N
for %%i in (1 2 3 4) do (if !WORK_TYPE!==%%i set WORK_TYPE_OK=1)
if %WORK_TYPE_OK%==0 echo *     ОШИБКА. Неверный тип профилактических работ & goto :N
schtasks > Output.txt
set TASK_NAME=
set WORK_TYPE_OK=1
for /f "skip=3" %%i in (Output.txt) do (
    set TASK_NAME=%%i
    set TASK_NAME=!TASK_NAME:~2!
    if !WORK_TYPE!==1 if /i !TASK_NAME!==_Prof_work_Disk_clean set WORK_TYPE_OK=0
    if !WORK_TYPE!==2 if /i !TASK_NAME!==_Prof_work_Disk_defrag set WORK_TYPE_OK=0
    if !WORK_TYPE!==3 if /i !TASK_NAME!==_Prof_work_Antivirus_check set WORK_TYPE_OK=0
    if !WORK_TYPE!==4 if /i !TASK_NAME!==_Prof_work_Disk_check set WORK_TYPE_OK=0
)
if %WORK_TYPE_OK%==0 echo *     ОШИБКА. Задание по расписанию для данного типа профилактических работ уже существует & goto :N
if %IS_2003%==0 if %WORK_TYPE%==1 if not exist C:\Windows\System32\Cleanmgr.exe echo *     ОШИБКА. Для очистки диска необходимо предварительно установить компонент "Возможности рабочего стола" & goto :N
if %WORK_TYPE_OK%==1 echo *     OK
if exist Output.txt del /q Output.txt
if exist \\10.167.31.8\Servers$ set SERVER_FOLDER=\\10.167.31.8\Servers$
if exist \\10.167.31.8\Servers$ goto :U
if exist \\10.167.31.9\Servers$ set SERVER_FOLDER=\\10.167.31.9\Servers$
:U
if %WORK_TYPE%==1 set WORK_TYPE=Disk_clean& goto :R
if %WORK_TYPE%==2 set WORK_TYPE=Disk_defrag& goto :END3
if %WORK_TYPE%==3 set WORK_TYPE=Antivirus_check& goto :O
if %WORK_TYPE%==4 set WORK_TYPE=Disk_check& goto :END3
:O
set KASPERSKY=
set TEMP_1=
set TEMP_2=
set /p KASPERSKY=*     Введите полный путь к файлу Avp.com: 
if not defined KASPERSKY echo *     ОШИБКА. Неправильный путь && goto :O
set TEMP_1="%KASPERSKY%"
if not exist %TEMP_1% echo *     ОШИБКА. Неправильный путь && goto :O
set TEMP_2=%KASPERSKY:~-1%
if /i %TEMP_2%==\ set KASPERSKY=%KASPERSKY:~,-1%
cd Other
setenv -m KASPERSKY_PATH "%KASPERSKY%" > Output.txt 2>>&1
if not defined KASPERSKY echo *     Переменная окружения KASPERSKY_PATH - ОШИБКА. & type Output.txt
if exist Output.txt del /q Output.txt
if defined KASPERSKY echo *     OK
cd ..
goto :END3
:R
cleanmgr /sageset: 1
:END3
set PERIOD_TYPE=
if /i %WORK_TYPE%==Disk_clean set PERIOD_TYPE=monthly /d 2
if /i %WORK_TYPE%==Disk_defrag set PERIOD_TYPE=monthly /d 2
if /i %WORK_TYPE%==Antivirus_check set PERIOD_TYPE=weekly /d sun
if /i %WORK_TYPE%==Disk_check set PERIOD_TYPE=monthly /d 2
if %IS_BASIC_EXIST%==1 set START_TIME=%START_TIME:~0,5%
set START_TIME_OK=0
set FIRST=%START_TIME:~0,1%
set SECOND=%START_TIME:~1,1%
set THIRD=%START_TIME:~3,1%
set FOURTH=%START_TIME:~4,1%
for %%i in (8 7 6 5 4 3 2 1 0) do (
    if %%i==!FOURTH! set START_TIME_OK=1
    if %%i==!FOURTH! set /a FOURTH=!FOURTH!+1
)
if %START_TIME_OK%==1 goto :P
if %FOURTH%==9 set FOURTH=0
for %%i in (4 3 2 1 0) do (
    if %%i==!THIRD! set START_TIME_OK=1
    if %%i==!THIRD! set /a THIRD=!THIRD!+1
)
if %START_TIME_OK%==1 goto :P
if %THIRD%==5 set THIRD=0
for %%i in (2 1 0) do (
    if %%i==!SECOND! set START_TIME_OK=1
    if %%i==!SECOND! set /a SECOND=!SECOND!+1
)
if %START_TIME_OK%==1 goto :P
if %SECOND%==3 set SECOND=0
for %%i in (1 0) do (
    if %%i==!FIRST! set START_TIME_OK=1
    if %%i==!FIRST! set /a FIRST=!FIRST!+1
)
if %START_TIME_OK%==1 goto :P
if %FIRST%==2 set FIRST=0
:P
set START_TIME=%FIRST%%SECOND%:%THIRD%%FOURTH%
if not exist %SERVER_FOLDER%\%COMPUTERNAME%\Prof_work_log mkdir %SERVER_FOLDER%\%COMPUTERNAME%\Prof_work_log > Output.txt 2>>&1
if exist %SERVER_FOLDER%\%COMPUTERNAME%\Prof_work_log echo *     Папка Prof_work_log на сервере резервного копирования - OK
if not exist %SERVER_FOLDER%\%COMPUTERNAME%\Prof_work_log echo *     Папка Prof_work_log на сервере резервного копирования - ОШИБКА. & type Output.txt
set TASK_NAME=
set TEMP_1=
set TEMP_2=
set TEMP_3=
set TEMP_4=
set TEMP_5=
set TEMP_6=
schtasks > Output.txt
for /f "skip=3" %%i in (Output.txt) do (
    set TEMP_1=%%i
    set TEMP_2=!TEMP_1:~2,1!
    if !TEMP_2!==_ set TEMP_3=!TEMP_1:~0,2!
    if !TEMP_2!==_ set TEMP_4=!TEMP_1:~2,10!
    if !TEMP_2!==_ set TEMP_5=!TEMP_1:~0,1!
    if !TEMP_2!==_ set TEMP_6=!TEMP_1:~1,1!
    if !TEMP_2!==_ if /i !TEMP_4!==_Prof_work if !TEMP_5!==0 set /a TEMP_6=!TEMP_6!+1
    if !TEMP_2!==_ if /i !TEMP_4!==_Prof_work if !TEMP_5!==0 if not !TEMP_6!==10 set TASK_NAME=0!TEMP_6!!TEMP_4!_!WORK_TYPE!
    if !TEMP_2!==_ if /i !TEMP_4!==_Prof_work if !TEMP_5!==0 if !TEMP_6!==10 set TASK_NAME=!TEMP_6!!TEMP_4!_!WORK_TYPE!
    if !TEMP_2!==_ if /i !TEMP_4!==_Prof_work if not !TEMP_5!==0 set /a TEMP_3=!TEMP_3!+1
    if !TEMP_2!==_ if /i !TEMP_4!==_Prof_work if not !TEMP_5!==0 set TASK_NAME=!TEMP_3!!TEMP_4!_!WORK_TYPE!
)
if not defined TASK_NAME set TASK_NAME=02_Prof_work_%WORK_TYPE%
if exist Output.txt del /q Output.txt
set TASK_CREATE_OK=0
if %IS_2003%==1 schtasks /create /ru %USER_NAME% /rp %USER_PASS% /sc %PERIOD_TYPE% /st %START_TIME% /tn %TASK_NAME% /tr "%DISK_LETTER%:\PPR\Prof_work\BAT\Prof_work.bat %WORK_TYPE%" > Output.txt 2>>&1
if %IS_2003%==0 schtasks /create /ru %USER_NAME% /rp %USER_PASS% /sc %PERIOD_TYPE% /st %START_TIME% /tn %TASK_NAME% /tr "%DISK_LETTER%:\PPR\Prof_work\BAT\Prof_work.bat %WORK_TYPE%" /rl highest > Output.txt 2>>&1
for /f %%i in (Output.txt) do (
    if /i %%i==УСПЕХ. set TASK_CREATE_OK=1
    if /i %%i==SUCCESS: set TASK_CREATE_OK=1
    if /i %%i==ПРЕДУПРЕЖДЕНИЕ. set TASK_CREATE_OK=0
    if /i %%i==WARNING: set TASK_CREATE_OK=0
)
if %TASK_CREATE_OK%==0 echo *     Задание по расписанию %TASK_NAME% - ОШИБКА. Задание не создано & type Output.txt
if %TASK_CREATE_OK%==1 echo *     Задание по расписанию %TASK_NAME% - OK
if exist Output.txt del /q Output.txt
echo *     НЕ ЗАБУДЬТЕ ВЫСТАВИТЬ НУЖНОЕ РАСПИСАНИЕ ДЛЯ АВТОМАТОВ ...
echo.
echo ОКОНЧАТЕЛЬНАЯ НАСТРОЙКА ЗАКОНЧЕНА
echo.
rem ********** ОКОНЧАТЕЛЬНАЯ НАСТРОЙКА **********
pause
