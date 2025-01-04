@echo off
setlocal enabledelayedexpansion

:: Wait for 30 seconds before starting the script execution
timeout /t 30

:: Define paths for logs and script files
set logfile=%UserProfile%\Documents\usage.log
set timelog=%UserProfile%\Documents\timelog.txt
set scriptLog=%UserProfile%\Documents\script_log.txt

:: Normalize the current date to YYYYMMDD format for comparison
for /f "tokens=2 delims==" %%A in ('"wmic os get LocalDateTime /value"') do set ldt=%%A
set "currentdate=!ldt:~0,8!"

:: Convert YYYYMMDD to DD/MM/YYYY for logging
set "logdate=!ldt:~6,2!/!ldt:~4,2!/!ldt:~0,4!"

:: Log the start time with formatted date
echo [%logdate% %TIME%] Starting script >> "%scriptLog%"

:: Check if the computer was used today
if exist "%logfile%" (
    set /p lastdate=<%logfile%
    :: Remove any carriage return and newline characters
    set "lastdate=!lastdate:~0,-1!"
    echo Last use date read from file: !lastdate! >> "%scriptLog%"
) else (
    echo No last use date found. Assuming new installation. >> "%scriptLog%"
    set "lastdate=00000000"
)

:: Compare last use date with current normalized date
echo Comparing date !lastdate! with !currentdate! >> "%scriptLog%"
if "!lastdate!"=="!currentdate!" (
    echo Same day detected, reading total time from file. >> "%scriptLog%"
    set /p totaltime=<%timelog%
    if not defined totaltime set "totaltime=0"
    echo Resuming with total time: !totaltime! seconds from file >> "%scriptLog%"
) else (
    echo New day detected. Resetting total time. >> "%scriptLog%"
    set "totaltime=0"
    echo !currentdate! > %logfile%
    echo 0 > %timelog%
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
echo !totaltime! > %timelog%

:: Show messages at different times
if !sessiontime! equ 1500 (
    echo 25 minute warning >> "%scriptLog%"
    PowerShell -File "%UserProfile%\Documents\ShowTimedMessage.ps1" "You have 5 minutes left before you will have to switch the laptops." 15
)
if !sessiontime! equ 1800 (
    echo Half hour warning >> "%scriptLog%"
    PowerShell -File "%UserProfile%\Documents\ShowTimedMessage.ps1" "It's time to switch the laptops." 15
)
if !sessiontime! equ 3300 (
    echo 55 minute warning >> "%scriptLog%"
    PowerShell -File "%UserProfile%\Documents\ShowTimedMessage.ps1" "You have 5 minutes left before the computer will switch off." 15
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
