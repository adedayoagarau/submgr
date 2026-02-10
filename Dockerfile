FROM php:8.2-apache

# Install PHP extensions required by submgr
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Install Tidy extension (optional, used for HTML output cleanup)
RUN apt-get update && apt-get install -y libtidy-dev && \
    docker-php-ext-install tidy && \
    rm -rf /var/lib/apt/lists/*

# Fix Apache MPM: remove ALL mpm symlinks, then add ONLY prefork
RUN rm -f /etc/apache2/mods-enabled/mpm_*.conf /etc/apache2/mods-enabled/mpm_*.load && \
    ln -sf /etc/apache2/mods-available/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf && \
    ln -sf /etc/apache2/mods-available/mpm_prefork.load /etc/apache2/mods-enabled/mpm_prefork.load

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Configure Apache to allow .htaccess overrides
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# Also configure Apache to listen on PORT from env (Railway requirement)
RUN echo 'PassEnv PORT' >> /etc/apache2/apache2.conf

# Copy app files
COPY . /var/www/html/

# Create uploads directory (stored outside web root for security)
RUN mkdir -p /var/www/uploads && \
    chown -R www-data:www-data /var/www/uploads && \
    chmod 755 /var/www/uploads

# Set proper permissions for the web root
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Copy the entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Configure PHP for file uploads
RUN echo "upload_max_filesize = 10M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "post_max_size = 12M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "max_execution_time = 60" >> /usr/local/etc/php/conf.d/uploads.ini

# Verify only one MPM is loaded (build-time check)
RUN ls -la /etc/apache2/mods-enabled/mpm_* && \
    apache2ctl -t -D DUMP_MODULES 2>&1 | grep mpm

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
