le@echo off

echo "Creating database volume backup..."
set BACKUP_DIR=C:\CheckMate-Backups\
set BACKUP_FILE=%BACKUP_DIR%\checkmate-docker_db_data_backup_%DATE:~10,4%-%DATE:~4,2%-%DATE:~7,2%_%TIME:~0,2%%TIME:~3,2%.tar.gz

:: Fix spaces in time variable
set BACKUP_FILE=%BACKUP_FILE: =0%

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

docker run --rm ^
  -v checkmate-docker_db_data:/data ^
  -v "%BACKUP_DIR%":/backup ^
  alpine sh -c "tar czf /backup/checkmate-docker_db_data_backup_$(date +%Y-%m-%d_%H-%M-%S).tar.gz -C /data ."

echo "Database volume backup created at %BACKUP_FILE%"

echo "Stopping and removing containers..."
docker-compose down

echo "Building and starting containers in detached mode..."
docker-compose up -d

echo "Collecting static files in container..."
docker exec checkmate-docker-django-1 python manage.py collectstatic --no-input

echo "Applying New Migrations"
docker exec checkmate-docker-django-1 python manage.py showmigrations
docker exec checkmate-docker-django-1 python manage.py migrate

echo "Done!"
pause

