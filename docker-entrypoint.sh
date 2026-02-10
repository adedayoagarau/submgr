#!/bin/bash
set -e

# Generate config_db.php from environment variables if it doesn't exist or if INSTALLED is false
if [ ! -f /var/www/html/config_db.php ] || grep -q "INSTALLED', false" /var/www/html/config_db.php 2>/dev/null; then
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
    chown www-data:www-data /var/www/html/config_db.php
fi

# Configure Apache to listen on Railway's PORT (defaults to 80)
if [ -n "$PORT" ]; then
    sed -i "s/Listen 80/Listen $PORT/" /etc/apache2/ports.conf
    sed -i "s/:80/:$PORT/" /etc/apache2/sites-available/000-default.conf
fi

exec "$@"
