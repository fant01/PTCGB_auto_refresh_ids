@echo off
setlocal enabledelayedexpansion
rem ==============================
rem DEFAULT CONFIGURATION
rem ==============================
set DEST=%~dp0

rem Leave blank URL / WAIT values to prompt the user input
set URL=
set WAIT=

rem If the values are not set, prompt the user for input
if "%URL%"=="" set /p URL=Enter the URL of the file to download:  
if "%WAIT%"=="" set /p WAIT=Enter the wait time in seconds before repeating the download: 

set DEST_IDS=%DEST%ids.txt
set DEST_DISCORD_IDS=%DEST%discord.txt
set DEST_DISCORD_NAMES_TEMP=%DEST%refresher_discord_name_temp.txt
set DEST_DISCORD_TOTALINSTANCES_TEMP=%DEST%refresher_total_instances_temp.txt
set DEST_TEMP=%DEST%refresher_temp.txt

rem Print the recognized folder
echo =============================================================
echo The batch file is located in: %DEST%
echo Default URL: %URL% 
echo Default Wait Time: %WAIT% 
echo (edit this file to change URL / Wait Time)
echo =============================================================

:loop
rem Download the file using curl
curl -L -o "%DEST_TEMP%" "%URL%" --insecure --crlf

rem Check if the content contains the necessary sections
findstr /i "DiscordNames" "%DEST_TEMP%" > nul
if errorlevel 1 (
    echo ERROR: Missing DiscordNames in the response, api expired?
    del "%DEST_TEMP%"
    goto wait_and_retry
)

findstr /i "FriendCodes" "%DEST_TEMP%" > nul
if errorlevel 1 (
    echo ERROR: Missing FriendCodes in the response    
    del "%DEST_TEMP%"
    goto wait_and_retry
)

findstr /i "DiscordIDs" "%DEST_TEMP%" > nul
if errorlevel 1 (
    echo ERROR: Missing DiscordIDs in the response
    del "%DEST_TEMP%"
    goto wait_and_retry
)

findstr /i "TotalInstances" "%DEST_TEMP%" > nul
if errorlevel 1 (
    echo ERROR: Missing TotalInstances in the response
    del "%DEST_TEMP%"
    goto wait_and_retry
)

rem Reset output files (without empty lines at the beginning)
type nul > "%DEST_IDS%"
type nul > "%DEST_DISCORD_IDS%"

rem Variable to track the current section
set "MODE="

rem Read the temp file line by line
for /f "usebackq delims=" %%A in ("%DEST_TEMP%") do (
    if "%%A"=="DiscordNames" (
        echo Found DiscordNames
        set "MODE=DISCORDNAME"
    ) else if "%%A"=="FriendCodes" (
        echo Found FriendCodes
        set "MODE=FRIENDCODE"
    ) else if "%%A"=="DiscordIDs" (
        echo Found DiscordIDs
        set "MODE=DISCORDID"
    ) else if "%%A"=="TotalInstances" (
        echo Found TotalInstances
        set "MODE=TOTAILINSTANCES"
    ) else if defined MODE (
        echo !MODE! : %%A
        if "!MODE!"=="DISCORDNAME" echo %%A>>"%DEST_DISCORD_NAMES_TEMP%"
        if "!MODE!"=="FRIENDCODE" echo %%A>>"%DEST_IDS%"
        if "!MODE!"=="DISCORDID" echo %%A>>"%DEST_DISCORD_IDS%"
        if "!MODE!"=="TOTAILINSTANCES" echo TotalInstances %%A>>"%DEST_DISCORD_TOTALINSTANCES_TEMP%"
    )
)

rem Debug output
echo Friend Codes saved to: %DEST_IDS%

rem Print a separator line
echo ================
echo --Friend--List--
echo ================

rem Print the content of the file ids.txt
type "%DEST_IDS%"

rem Print another separator line
echo ================

echo Discord IDs saved to: %DEST_DISCORD_IDS%

rem Print a separator line
echo ===================
echo ---Discord---Ids---
echo ===================

rem Print the content of the file ids.txt
type "%DEST_DISCORD_IDS%"

rem Print another separator line
echo ===================

rem Print a separator line
echo =================
echo --Online--List--
echo =================

rem Print the content of the file ids.txt
type "%DEST_DISCORD_NAMES_TEMP%"

rem Print another separator line
echo -----------------

rem Print the content of the file ids.txt
type "%DEST_DISCORD_TOTALINSTANCES_TEMP%"

rem Print another separator line
echo =================

rem Delete the temporary file
del "%DEST_TEMP%"
del "%DEST_DISCORD_NAMES_TEMP%"
del "%DEST_DISCORD_TOTALINSTANCES_TEMP%"

rem Wait before the next loop
timeout /t %WAIT%

rem Repeat the process
goto loop

:wait_and_retry
rem Wait before retrying
timeout /t %WAIT%
goto loop
