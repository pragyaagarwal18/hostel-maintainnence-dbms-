@echo off
REM ============================================================================
REM DATABASE RESTORE SCRIPT (MySQL Native Tool: mysql CLI)
REM Project: Hostel Maintenance and Complaint Management System
REM Authors: Pragya Agarwal (24BCI0280) & Suhani Singh (24BCI0006)
REM Course: BCSE302P Database Systems Lab | Slot: L25+L26
REM ============================================================================

set DB_NAME=hostel_maintenance_db
set DB_USER=root

echo [PRAGYA_24BCI0280 & SUHANI_24BCI0006] Database Recovery Tool
echo -------------------------------------------------------------
set /p BACKUP_PATH="Enter full path of SQL backup file to restore: "

if not exist "%BACKUP_PATH%" (
    echo [ERROR] Backup file does not exist at: %BACKUP_PATH%
    pause
    exit /b 1
)

echo Restoring %DB_NAME% from %BACKUP_PATH%...

mysql -u %DB_USER% -p %DB_NAME% < "%BACKUP_PATH%"

if %ERRORLEVEL% equ 0 (
    echo [SUCCESS] Database %DB_NAME% successfully restored from backup!
) else (
    echo [ERROR] Restoration failed. Please check MySQL server logs.
)

pause
