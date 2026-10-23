@echo off
REM ============================================================================
REM AUTOMATED GIT SETUP & 10 PROGRESSIVE COMMITS SCRIPT
REM Course: BCSE302P Database Systems Lab | Slot: L25+L26
REM Authors: Pragya Agarwal (24BCI0280) & Suhani Singh (24BCI0006)
REM Faculty: Dr. V. SIVAKUMAR
REM ============================================================================

echo ======================================================================
echo    HOSTELCARE 360 - AUTOMATED GIT REPOSITORY INITIALIZATION
echo    Creating 10 Progressive Commits & Branches (main and dev)
echo ======================================================================
echo.

cd /d "%~dp0"

REM Step 1: Initialize Git Repository on 'main' branch
git init -b main
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Git is not installed or not in PATH.
    echo Please install Git from https://git-scm.com/downloads and rerun this script.
    pause
    exit /b 1
)

REM Configure local author info if not already set
git config user.name "Pragya Agarwal and Suhani Singh"
git config user.email "pragya.24bci0280@vitstudent.ac.in"

echo [1/10] Committing project setup & documentation...
git add .gitignore README.md package.json .env.example
git commit -m "feat(init): project setup, architecture documentation and dependencies"

echo [2/10] Committing 10 normalized 3NF database schema DDL...
git add database/01_schema_ddl.sql
git commit -m "feat(db): implement 10 normalized 3NF database tables with PK, FK and CHECK constraints"

echo [3/10] Committing analytical database views...
git add database/02_views.sql
git commit -m "feat(db): add database views for SLA tracking, technician workloads and block metrics"

echo [4/10] Committing automated database triggers...
git add database/03_triggers.sql
git commit -m "feat(db): add triggers for duplicate ticket prevention, emergency room state and audit logs"

echo [5/10] Committing ACID stored procedures...
git add database/04_stored_procedures.sql
git commit -m "feat(db): add ACID stored procedures sp_pragya24bci0280_assign_technician and sp_suhani24bci0006_resolve"

echo [6/10] Committing seed data and verification queries...
git add database/05_seed_data.sql database/06_advanced_queries.sql database/backup_db.bat database/restore_db.bat
git commit -m "feat(db): add rich seed dataset across hostel blocks and verification query suite"

echo [7/10] Committing Prisma ORM schema & database connector...
git add prisma/schema.prisma src/config/
git commit -m "feat(orm): configure Prisma ORM models and MySQL connection pool"

echo [8/10] Committing Express REST API, Single Users table RBAC & controllers...
git add src/middleware/ src/controllers/ src/routes/ src/server.js
git commit -m "feat(api): implement single users table RBAC auth, BCrypt hashing and complaint controllers"

echo [9/10] Committing frontend UI and interactive prototype...
git add public/ HostelCare_App.html
git commit -m "feat(ui): responsive hostel management dashboard with role switcher and modals"

echo [10/10] Committing Docker orchestration & GitHub Actions CI/CD...
git add Dockerfile docker-compose.yml .github/
git commit -m "ci(devops): configure Dockerfile, docker-compose and GitHub Actions CI/CD test workflow"

echo.
echo ======================================================================
echo    SUCCESS! All 10 Progressive Commits created on 'main' branch!
echo ======================================================================
echo.

REM Create and switch to 'dev' branch (Mandatory VIT requirement)
git checkout -b dev
echo [BRANCH] Created and switched to development branch 'dev'.
echo.

echo ----------------------------------------------------------------------
echo   NOW CONNECT TO YOUR GITHUB ACCOUNT:
echo   1. Go to https://github.com/new in your browser.
echo   2. Name your repository: hostel-maintenance-dbms
echo   3. Set it to Private (or Public as preferred).
echo   4. Do NOT check 'Initialize with README' (we already have one).
echo   5. Click 'Create repository' and copy the repository URL.
echo ----------------------------------------------------------------------
echo.

set /p REPO_URL="Paste your GitHub Repository URL here (e.g. https://github.com/yourname/hostel-maintenance-dbms.git): "

if "%REPO_URL%"=="" (
    echo No URL entered. You can push manually anytime!
    pause
    exit /b 0
)

echo Adding remote origin...
git remote remove origin 2>nul
git remote add origin %REPO_URL%

echo Pushing 'main' branch...
git push -u origin main

echo Pushing 'dev' branch...
git push -u origin dev

echo.
echo ======================================================================
echo    ALL DONE! Your project is live on GitHub!
echo    Share your repository URL with Dr. V. Sivakumar:
echo    %REPO_URL%
echo ======================================================================
pause
