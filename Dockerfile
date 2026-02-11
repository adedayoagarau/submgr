FROM php:8.2-cli

# Install PHP extensions required by submgr
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Install Tidy extension (used for HTML output cleanup)
RUN apt-get update && apt-get install -y libtidy-dev && \
    docker-php-ext-install tidy && \
    rm -rf /var/lib/apt/lists/*

# Configure PHP for file uploads
RUN echo "upload_max_filesize = 10M" > /usr/local/etc/php/conf.d/uploads.ini && \
    echo "post_max_size = 12M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "max_execution_time = 60" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "session.save_path = /tmp" >> /usr/local/etc/php/conf.d/uploads.ini

# Copy app files
COPY . /var/www/html/

# Create uploads directory
RUN mkdir -p /var/www/uploads && \
    chmod 777 /var/www/uploads

# Set permissions
RUN chown -R www-data:www-data /var/www/html /var/www/uploads && \
    chmod -R 755 /var/www/html

# Copy entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["docker-entrypoint.sh"]
