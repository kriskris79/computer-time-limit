@echo off
setlocal enabledelayedexpansion

:: Wait for 30 seconds before starting the script execution
timeout /t 30

:: Define paths for logs and script files
set logfile=%UserProfile%\Documents\usage.log
set timelog=%UserProfile%\Documents\timelog.txt
set scriptLog=%UserProfile%\Documents\script_log.txt

:: Log the start time
echo [%DATE% %TIME%] Starting script >> "%scriptLog%"

:: Check if the computer was used today
if exist %logfile% (
    set /p lastdate=<%logfile%
) else (
    set lastdate=
)

:: Compare last use date with current date
if "%lastdate%"=="%date%" (
    :: Read the total time if the same day
    set /p totaltime=<%timelog%
) else (
    :: Reset if a new day
    set /a totaltime=0
    echo %date% > %logfile%
)

echo Read total time: !totaltime! >> "%scriptLog%"

:: Set the maximum allowed time (3600 seconds for 1 hour)
set /a maxtime=3600

:: Calculate remaining time
set /a remaining=!maxtime! - !totaltime!
if !remaining! leq 0 (
    echo Daily limit reached. Triggering logoff. >> "%scriptLog%"
    PowerShell -File "%UserProfile%\Documents\ShowTimedMessage.ps1" "Daily computer usage limit reached. Logging off..." 15
    shutdown /l
    exit
)

:: Begin the timer for the current session
:timer
echo Timer check: Total time !totaltime!, Max time !maxtime! >> "%scriptLog%"
if !totaltime! geq !maxtime! goto endsession
timeout /t 1 /nobreak
set /a sessiontime+=1
set /a totaltime+=1

:: Update the timelog every minute
echo !totaltime! > %timelog%

:: Show messages at different times
if !sessiontime! equ 15 (
    echo 25 minute warning >> "%scriptLog%"
    PowerShell -File "%UserProfile%\Documents\ShowTimedMessage.ps1" "Children, you have 5 minutes left before you will have to switch the laptops." 15
)
if !sessiontime! equ 1800 (
    echo Half hour warning >> "%scriptLog%"
    PowerShell -File "%UserProfile%\Documents\ShowTimedMessage.ps1" "Children, time to switch the laptops." 15
)
if !sessiontime! equ 3300 (
    echo 55 minute warning >> "%scriptLog%"
    PowerShell -File "%UserProfile%\Documents\ShowTimedMessage.ps1" "Children, you have 5 minutes left before the computer will switch off." 15
)
if !sessiontime! geq 3600 goto endsession
goto timer

:endsession
echo Session end. Total time: !totaltime! >> "%scriptLog%"
if !totaltime! geq !maxtime! (
    shutdown /s /f /t 0
) else (
    PowerShell -File "%UserProfile%\Documents\ShowTimedMessage.ps1" "Session ended without reaching daily limit. Total time today: !totaltime! seconds." 10 >> "%UserProfile%\Documents\script_output.txt" 2>&1
)

endlocal
goto :eof
