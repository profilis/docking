FROM php:8.2-cli

WORKDIR /var/www/html

RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    supervisor \
    nginx \
    wkhtmltopdf

# Install PHP extensions
RUN docker-php-ext-install pdo mbstring exif pcntl bcmath gd sockets

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy project files
COPY . .
COPY ./.docker/docking-octane.conf /etc/supervisor/conf.d/
COPY ./.docker/docking-host-octane.conf /etc/nginx/conf.d/default.conf

RUN cp .docker/entrypoint.sh /entrypoint
RUN chmod +x /entrypoint

# The bundle already built, no need to keep this to save size
RUN rm -rf ./node_modules

RUN composer install
RUN php artisan optimize
RUN php artisan storage:link

# Download RoadRunner binary directly instead of using get-binary command
# which hits GitHub API rate limits in Docker builds
RUN curl -L https://github.com/roadrunner-server/roadrunner/releases/download/v2023.3.8/roadrunner-2023.3.8-linux-amd64.tar.gz -o rr.tar.gz \
    && tar -xzf rr.tar.gz \
    && mv roadrunner-2023.3.8-linux-amd64/rr /var/www/html/rr \
    && chmod +x ./rr \
    && rm -rf roadrunner-2023.3.8-linux-amd64 rr.tar.gz

RUN chown -R www-data:www-data storage
RUN chown -R www-data:www-data storage/app
RUN chmod -R 777 storage/logs

RUN touch /var/www/html/docking.sqlite
RUN chown www-data:www-data docking.sqlite

# Nginx remove default site
RUN rm /etc/nginx/sites-enabled/default

EXPOSE 80 8080

############# Default app ENV
ENV APP_ENV="production"
ENV APP_KEY="base64:/UnGygYvVBmIh+VgNhMj6MyI/ieXTtzUJsUL4OUtZGI="
ENV DB_CONNECTION="sqlite"
ENV DATABASE_URL="sqlite:////var/www/html/docking.sqlite"

############# Storage ENV

# s3|local
ENV FILESYSTEM_DISK=public

# if select s3, these must be defined
ENV AWS_ACCESS_KEY_ID=""
ENV AWS_SECRET_ACCESS_KEY=""
ENV AWS_DEFAULT_REGION="ap-southeast-1"
ENV AWS_BUCKET="shipsaas-docking"

############# Docking Config
ENV DOCKING_PUBLIC_ACCESS_KEY=""
ENV DOCKING_CONSOLE_ENABLED=true
ENV DOCKING_CONSOLE_PASSWORD=""
ENV DOCKING_DEFAULT_PDF_DRIVER="gotenberg"
ENV DOCKING_GOTENBERG_ENDPOINT="http://127.0.0.1:9898"

# Start ALL
ENTRYPOINT ["/entrypoint"]
