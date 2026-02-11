#!/bin/bash
set -e

# Always generate config_db.php from environment variables
# Railway containers reset filesystem on each deploy, so this must be recreated.
# INSTALLED=true because the database tables already exist in the persistent MySQL.
cat > /var/www/html/config_db.php << DBEOF
<?php
define('DB_HOST', '${DB_HOST:-mysql.railway.internal}');
define('DB_USERNAME', '${DB_USERNAME:-root}');
define('DB_PASSWORD', '${DB_PASSWORD:-}');
define('DB_NAME', '${DB_NAME:-railway}');
define('DB_PORT', '${DB_PORT:-3306}');
define('INSTALLED', true);
define('TEST_MAIL', false);
define('TIDY', true);
?>
DBEOF

echo "Config generated with INSTALLED=true"

# Use Railway's PORT or default to 8080
PORT="${PORT:-8080}"

echo "Starting PHP built-in server on port $PORT..."
exec php -S "0.0.0.0:$PORT" -t /var/www/html
