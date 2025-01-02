@echo off
setlocal enabledelayedexpansion

:: Wait for 30 seconds before starting the script execution
timeout /t 30

:: Define paths for logs and script files using a generic placeholder
set logfile=%UserProfile%\Documents\usage.log
set timelog=%UserProfile%\Documents\timelog.txt

echo [%DATE% %TIME%] Starting script >> "%UserProfile%\Documents\script_log.txt"

:: Initialize or update the timelog if it exists
if exist %timelog% (
    set /p totaltime=<%timelog%
    echo Read total time: !totaltime! >> "%UserProfile%\Documents\script_log.txt"
) else (
    set /a totaltime=0
    echo !totaltime! > %timelog%
    echo Set total time to 0 >> "%UserProfile%\Documents\script_log.txt"
)

:: Set the maximum allowed time (3600 seconds for 1 hour)
set /a maxtime=3600

:: Check if the computer was used today and calculate remaining time
if exist %logfile% (
    for /f "tokens=*" %%a in (%logfile%) do set lastdate=%%a
    echo Last use date: %%lastdate%% >> "%UserProfile%\Documents\script_log.txt"
    if "%date%"=="%lastdate%" (
        set /a remaining=!maxtime!-!totaltime!
        echo Remaining time today: !remaining! >> "%UserProfile%\Documents\script_log.txt"
        if !remaining! leq 0 (
            echo Triggering time limit reached message >> "%UserProfile%\Documents\script_log.txt"
            PowerShell -File "%UserProfile%\Documents\ShowTimedMessage.ps1" "Daily computer usage limit reached. Logging off..." 15
            shutdown /l
            exit
        )
    )
) else (
    echo No previous log found or new day detected >> "%UserProfile%\Documents\script_log.txt"
    echo 0 > %timelog%
    set /a totaltime=0
    echo %date% > %logfile%
)

:: Begin the timer for the current session
:timer
echo Timer check: Total time !totaltime!, Max time !maxtime! >> "%UserProfile%\Documents\script_log.txt"
if !totaltime! geq !maxtime! goto endsession
timeout /t 1 /nobreak
set /a sessiontime+=1
set /a totaltime+=1

:: Show messages at different times
if !sessiontime! equ 1500 (
    echo 25 minute warning >> "%UserProfile%\Documents\script_log.txt"
    PowerShell -File "%UserProfile%\Documents\ShowTimedMessage.ps1" "Children, you have 5 minutes left before you will have to switch the laptops." 15
)
if !sessiontime! equ 1800 (
    echo Half hour warning >> "%UserProfile%\Documents\script_log.txt"
    PowerShell -File "%UserProfile%\Documents\ShowTimedMessage.ps1" "Children, time to switch the laptops." 15
)
if !sessiontime! equ 3300 (
    echo 55 minute warning >> "%UserProfile%\Documents\script_log.txt"
    PowerShell -File "%UserProfile%\Documents\ShowTimedMessage.ps1" "Children, you have 5 minutes left before the computer will switch off." 15
)
if !sessiontime! geq 3600 goto endsession
goto timer

:endsession
echo Session end. Total time: !totaltime! >> "%UserProfile%\Documents\script_log.txt"
echo !totaltime! > %timelog%
if !totaltime! geq !maxtime! (
    echo %date% > %logfile%
    shutdown /s /f /t 0
) else (
    PowerShell -File "%UserProfile%\Documents\ShowTimedMessage.ps1" "Session ended without reaching daily limit. Total time today: !totaltime! seconds." 10 >> "%UserProfile%\Documents\script_output.txt" 2>&1
)

endlocal
goto :eof
