@echo off
setlocal

rem -----------------------------
rem Configuration
rem -----------------------------
set "VOLUME_NAME=checkmate-docker_db_data"
set "BACKUP_DIR=C:\CheckMate-Backups"

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%" >nul 2>&1

rem -----------------------------
rem Check if volume exists
rem -----------------------------
docker volume inspect %VOLUME_NAME% >nul 2>&1
if %errorlevel% neq 0 (
    echo =============================================================
    echo Performing FIRST INSTALLATION
    echo =============================================================
    docker compose up -d
    docker exec -it checkmate-docker-django-1 python manage.py collectstatic
    docker exec -it checkmate-docker-django-1 python manage.py showmigrations
    docker exec -it checkmate-docker-django-1 python manage.py migrate
    docker exec -it checkmate-docker-django-1 python manage.py createsuperuser
    if %errorlevel% neq 0 (
        echo ERROR: Docker compose up failed.
        pause
        exit /b 1
    )
    echo Installation completed successfully.
    pause
    exit /b 0
)

rem -----------------------------
rem UPDATE
rem -----------------------------
echo =============================================================
echo Performing UPDATE
echo =============================================================

rem --- Backup database volume ---
for /f "tokens=1-4 delims=/:. " %%a in ("%DATE% %TIME%") do (
    set TIMESTAMP=%%d%%b%%c_%%a%%b
)
set "BACKUP_FILE=%BACKUP_DIR%\%VOLUME_NAME%_backup_%TIMESTAMP%.tar.gz"

echo Backing up DB volume to %BACKUP_FILE% ...
docker run --rm -v %VOLUME_NAME%:/data -v "%BACKUP_DIR%":/backup alpine sh -c "tar czf /backup/%VOLUME_NAME%_backup_%TIMESTAMP%.tar.gz -C /data ."
if %errorlevel% neq 0 (
    echo ERROR: Backup failed.
    pause
    exit /b 1
)
echo Backup completed.

rem --- Shutdown containers and remove images ---
docker compose down --rmi all
if %errorlevel% neq 0 (
    echo ERROR: Docker compose down failed.
    pause
    exit /b 1
)

rem --- Start containers ---
docker compose up -d
docker exec -it checkmate-docker-django-1 python manage.py collectstatic
docker exec -it checkmate-docker-django-1 python manage.py showmigrations
docker exec -it checkmate-docker-django-1 python manage.py migrate
if %errorlevel% neq 0 (
    echo ERROR: Docker compose up failed.
    pause
    exit /b 1
)

echo Update completed successfully.
pause
exit /b 0
