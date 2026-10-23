@echo off
REM ============================================================================
REM DATABASE BACKUP SCRIPT (MySQL Native Tool: mysqldump)
REM Project: Hostel Maintenance and Complaint Management System
REM Authors: Pragya Agarwal (24BCI0280) & Suhani Singh (24BCI0006)
REM Course: BCSE302P Database Systems Lab | Slot: L25+L26
REM ============================================================================

set DB_NAME=hostel_maintenance_db
set DB_USER=root
set BACKUP_DIR=.\backups
set TIMESTAMP=%date:~-4,4%%date:~-7,2%%date:~-10,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set BACKUP_FILE=%BACKUP_DIR%\%DB_NAME%_backup_%TIMESTAMP%.sql

if not exist %BACKUP_DIR% (
    mkdir %BACKUP_DIR%
)

echo [PRAGYA_24BCI0280 & SUHANI_24BCI0006] Initiating MySQL Database Backup...
echo Database: %DB_NAME%
echo Destination: %BACKUP_FILE%

mysqldump -u %DB_USER% -p --routines --triggers --views %DB_NAME% > "%BACKUP_FILE%"

if %ERRORLEVEL% equ 0 (
    echo [SUCCESS] Backup completed successfully at %BACKUP_FILE%
) else (
    echo [ERROR] Backup failed. Check MySQL service and credentials.
)

pause
