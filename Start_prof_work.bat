
@echo off
title Execute profilactic work
setlocal enabledelayedexpansion

rem *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*
rem *+*+*+*+*  Start_prof_work.bat v 2.0 authored by STARODUBCEV K.G. *+*+*+*+*
rem *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*


rem * // * ОПИСАНИЕ КОМАНДНОГО ФАЙЛА - НАЧАЛО * // *
rem ************************************************************************************************************
rem * Командный файл по порядку запускает задания по расписанию, время выполнения которых назначено на сегодня *
rem * Системные требования:                                                                                    *
rem *               Региональные параметры - Русский                                                           *
rem *               Формат времени - H:mm:ss                                                                   *
rem ************************************************************************************************************
rem * // * ОПИСАНИЕ КОМАНДНОГО ФАЙЛА - КОНЕЦ * // *


rem * // * ОПРЕДЕЛЕНИЕ ПЕРЕМЕННЫХ - НАЧАЛО * // *
ver > Output_start_prof_work.txt
set IS_2003=0
set VERSION=
for /f "tokens=4 skip=1" %%i in (Output_start_prof_work.txt) do (
    set VERSION=%%i
)
set VERSION=%VERSION:~0,1%
if %VERSION%==5 set IS_2003=1
if exist Output_start_prof_work.txt del /q Output_start_prof_work.txt
rem * // * ОПРЕДЕЛЕНИЕ ПЕРЕМЕННЫХ - КОНЕЦ * // *


rem * // * ТЕЛО КОМАНДНОГО ФАЙЛА - НАЧАЛО * // *
echo.
echo НАЧИНАЕМ ПРОФИЛАКТИЧЕСКИЕ РАБОТЫ
echo.
echo Profilactic work is runing ... > run.txt
schtasks /query /fo csv /v > Prof_work_schtasks.txt
for /f "delims=*" %%i in (Prof_work_schtasks.txt) do (
    set TEMP_1=%%i
    set TEMP_2=!TEMP_1:","","=","TERMINATOR","!
    set TEMP_2=!TEMP_2:","=*!
    echo !TEMP_2! >> Prof_work_schtasks_2.txt
)
ping 127.0.0.1 -n 120 > Output_start_prof_work.txt
if exist run.txt del /q run.txt
if exist Output_start_prof_work.txt del /q Output_start_prof_work.txt
if exist Prof_work_schtasks.txt del /q Prof_work_schtasks.txt
if /i %IS_2003%==1 goto :3ALL
if /i %IS_2003%==0 goto :8ALL
:3ALL
set CURRENT_DATE=!DATE!
for /f "delims=* tokens=2,3,10 skip=1" %%i in (Prof_work_schtasks_2.txt) do (
    set TASK_NAME=%%i
    set NEXT_RUN_DATE=%%j
    set RUN_STRING=%%k
    set TASK_NAME=!TASK_NAME:~2,10!
    set NEXT_RUN_DATE=!NEXT_RUN_DATE:~-10!
    if /i !TASK_NAME!==_Prof_work if !NEXT_RUN_DATE!==!CURRENT_DATE! cmd /c !RUN_STRING! & echo Выполняем задание !RUN_STRING!
)
goto :END
:8ALL
set CURRENT_DATE=!DATE!
for /f "delims=* tokens=2,3,9 skip=1" %%i in (Prof_work_schtasks_2.txt) do (
    set TASK_NAME=%%i
    set NEXT_RUN_DATE=%%j
    set RUN_STRING=%%k
    set TASK_NAME=!TASK_NAME:\=!
    set TASK_NAME=!TASK_NAME:~2,10!
    set NEXT_RUN_DATE=!NEXT_RUN_DATE:~0,10!
    if /i !TASK_NAME!==_Prof_work if !NEXT_RUN_DATE!==!CURRENT_DATE! cmd /c !RUN_STRING! & echo Выполняем задание !RUN_STRING!
)
goto :END
:END
if exist Prof_work_schtasks_2.txt del /q Prof_work_schtasks_2.txt
echo.
echo ПРОФИЛАКТИЧЕСКИЕ РАБОТЫ ЗАКОНЧЕНЫ
echo.
rem * // * ТЕЛО КОМАНДНОГО ФАЙЛА - КОНЕЦ * // *
