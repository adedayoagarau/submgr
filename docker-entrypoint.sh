#!/bin/bash
set -e

# Only generate config_db.php if it doesn't already exist
# (The installer creates/updates this file, we don't want to overwrite it on redeploys)
if [ ! -f /var/www/html/config_db.php ]; then
    cat > /var/www/html/config_db.php << DBEOF
<?php
define('DB_HOST', '${DB_HOST:-mysql.railway.internal}');
define('DB_USERNAME', '${DB_USERNAME:-root}');
define('DB_PASSWORD', '${DB_PASSWORD:-}');
define('DB_NAME', '${DB_NAME:-railway}');
define('DB_PORT', '${DB_PORT:-3306}');
define('INSTALLED', false);
define('TEST_MAIL', false);
define('TIDY', true);
?>
DBEOF
    echo "Generated initial config_db.php"
else
    echo "Using existing config_db.php"
fi

# Use Railway's PORT or default to 8080
PORT="${PORT:-8080}"

echo "Starting PHP built-in server on port $PORT..."
exec php -S "0.0.0.0:$PORT" -t /var/www/html
