@echo off
REM Usage: install.bat my-portfolio
set APP=%1
if "%APP%"=="" set APP=my-portfolio

call composer create-project laravel/laravel %APP%
if errorlevel 1 exit /b 1

for %%D in (app config database public resources routes) do (
  xcopy /E /I /Y "%~dp0%%D" "%APP%\%%D"
)

cd %APP%
call php artisan storage:link
call php artisan migrate --seed --force

echo.
echo Done!  cd %APP%  then  php artisan serve
echo Admin: admin@example.com / ChangeMe123!   (change it after first login)
