@echo off
setlocal

:handle_error
    echo.
    echo ***************************************************
    echo ^| An error occurred. Aborting script.
    echo ***************************************************
    echo.
    exit /b 1

echo "--- Setting up backup variables ---"
set "BACKUP_DIR=C:\CheckMate-Backups"
set "TIMESTAMP=%DATE:~10,4%-%DATE:~4,2%-%DATE:~7,2%_%TIME:~0,2%%TIME:~3,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"
set "BACKUP_FILENAME=checkmate-docker_db_data_backup_%TIMESTAMP%.tar.gz"
set "BACKUP_FILE=%BACKUP_DIR%\%BACKUP_FILENAME%"

echo "--- Creating database volume backup ---"
if not exist "%BACKUP_DIR%" (
    echo "Backup directory not found. Creating: %BACKUP_DIR%"
    mkdir "%BACKUP_DIR%"
    if %errorlevel% neq 0 (
        echo "ERROR: Failed to create backup directory."
        call :handle_error
    )
)

echo "Running backup container..."
docker run --rm ^
  -v checkmate-docker_db_data:/data ^
  -v "%BACKUP_DIR%":/backup ^
  alpine sh -c "tar czf /backup/%BACKUP_FILENAME% -C /data ."

if %errorlevel% neq 0 (
    echo "ERROR: Docker backup command failed."
    call :handle_error
)
echo "Database volume backup created at %BACKUP_FILE%"
echo.

echo "--- Stopping and removing containers ---"
docker-compose down
if %errorlevel% neq 0 (
    echo "ERROR: 'docker-compose down' failed."
    call :handle_error
)
echo.

echo "--- Building and starting containers in detached mode ---"
docker-compose up -d --build
if %errorlevel% neq 0 (
    echo "ERROR: 'docker-compose up --build' failed."
    call :handle_error
)
echo.

echo "Waiting for services to stabilize..."
timeout /t 10 /nobreak > nul

echo "--- Collecting static files in container ---"
docker exec checkmate-docker-django-1 python manage.py collectstatic --no-input
if %errorlevel% neq 0 (
    echo "ERROR: Failed to collect static files."
    call :handle_error
)
echo.

echo "--- Applying New Migrations ---"
docker exec checkmate-docker-django-1 python manage.py showmigrations
if %errorlevel% neq 0 (
    echo "WARNING: 'showmigrations' command failed. Continuing anyway."
)

docker exec checkmate-docker-django-1 python manage.py migrate
if %errorlevel% neq 0 (
    echo "ERROR: Failed to apply migrations."
    call :handle_error
)
echo.

echo "--- Done! ---"
pause
endlocal
