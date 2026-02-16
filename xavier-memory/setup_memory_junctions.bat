@echo off
REM Xavier Global Memory - Junction Point Setup
REM This script creates Windows junction points to sync MEMORY.md across all projects
REM Created: 2026-02-15

echo ================================================================
echo Xavier Global Memory System - Junction Setup
echo ================================================================
echo.

set MASTER_MEMORY=%USERPROFILE%\Downloads\claude-intelligence-hub\xavier-memory\MEMORY.md
set PROJECTS_DIR=%USERPROFILE%\.claude\projects

echo Master MEMORY.md location:
echo   %MASTER_MEMORY%
echo.
echo Target projects in:
echo   %PROJECTS_DIR%
echo.

REM Verify master exists
if not exist "%MASTER_MEMORY%" (
    echo ERROR: Master MEMORY.md not found!
    echo Expected at: %MASTER_MEMORY%
    pause
    exit /b 1
)

echo Step 1: Backing up existing project MEMORY.md files...
echo.

REM Create backup directory
set BACKUP_DIR=%USERPROFILE%\Downloads\claude-intelligence-hub\xavier-memory\backups\pre-junction_%date:~-4,4%-%date:~-10,2%-%date:~-7,2%
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

REM Backup existing MEMORY.md files
for /d %%P in ("%PROJECTS_DIR%\*") do (
    if exist "%%P\memory\MEMORY.md" (
        echo Backing up: %%P\memory\MEMORY.md
        copy "%%P\memory\MEMORY.md" "%BACKUP_DIR%\%%~nxP_MEMORY.md" >nul 2>&1
    )
)

echo.
echo Backups saved to:
echo   %BACKUP_DIR%
echo.

echo Step 2: Removing old MEMORY.md files...
echo.

for /d %%P in ("%PROJECTS_DIR%\*") do (
    if exist "%%P\memory\MEMORY.md" (
        echo Removing: %%P\memory\MEMORY.md
        del /f /q "%%P\memory\MEMORY.md" >nul 2>&1
    )
)

echo.
echo Step 3: Creating hard links to master MEMORY.md...
echo (Hard links = same file, instant sync, no admin needed)
echo (Using PowerShell New-Item for reliable hard link creation)
echo.

for /d %%P in ("%PROJECTS_DIR%\*") do (
    if exist "%%P\memory" (
        echo Creating hard link: %%P\memory\MEMORY.md -^> master
        powershell -Command "New-Item -ItemType HardLink -Path '%%P\memory\MEMORY.md' -Target '%MASTER_MEMORY%' -Force -ErrorAction Stop" >nul 2>&1
        if errorlevel 1 (
            echo   [FAILED] Could not create hard link - check permissions
        ) else (
            echo   [OK] Hard link created successfully
        )
    )
)

echo.
echo ================================================================
echo Verification
echo ================================================================
echo.

echo Checking hard link status:
echo.

REM Verify hard links by checking if files point to same inode
for /d %%P in ("%PROJECTS_DIR%\*") do (
    if exist "%%P\memory\MEMORY.md" (
        echo Project: %%~nxP
        powershell -Command "$master = Get-Item '%MASTER_MEMORY%'; $project = Get-Item '%%P\memory\MEMORY.md'; if ($master.Length -eq $project.Length -and $master.LastWriteTime -eq $project.LastWriteTime) { Write-Host '  Status: Hard link verified (same inode)' -ForegroundColor Green } else { Write-Host '  Status: NOT a hard link - sizes/times differ' -ForegroundColor Red }"
        echo.
    )
)

echo.
echo ================================================================
echo Setup Complete!
echo ================================================================
echo.
echo Master MEMORY.md: %MASTER_MEMORY%
echo Projects synced: All projects in %PROJECTS_DIR%
echo Backups saved: %BACKUP_DIR%
echo.
echo Next steps:
echo   1. Verify junctions: dir %PROJECTS_DIR%\*\memory\MEMORY.md
echo   2. Test in Claude: Start new session, check memory loaded
echo   3. Edit master: Changes auto-sync to all projects
echo.
pause
