#!/usr/bin/env bash
# Usage:  bash install.sh my-portfolio
# Creates a fresh Laravel app and copies this package's code into it.
set -euo pipefail

APP="${1:-my-portfolio}"
HERE="$(cd "$(dirname "$0")" && pwd)"

command -v composer >/dev/null || { echo "Composer is required: https://getcomposer.org"; exit 1; }
command -v php >/dev/null || { echo "PHP 8.2+ is required"; exit 1; }

composer create-project laravel/laravel "$APP"

for d in app config database public resources routes; do
  cp -R "$HERE/$d/." "$APP/$d/"
done

cd "$APP"
php artisan storage:link
php artisan migrate --seed --force

echo
echo "Done!  cd $APP && php artisan serve"
echo "Admin:  admin@example.com / ChangeMe123!   (change it after the first login)"
