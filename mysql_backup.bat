@echo off
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set DATE=%%i
set BACKUP_FILE=C:\backups\mydb-%DATE%.sql
echo %BACKUP_FILE%

docker exec db mysqldump -uroot -pMySQL_PASS CheckMate > %BACKUP_FILE%
