FROM php:8.3-fpm-alpine

WORKDIR /var/www/html

# Install dependencies
RUN apk add --no-cache \
    bash git curl unzip zip \
    libzip-dev oniguruma-dev \
    build-base nodejs npm \
    sqlite sqlite-dev

# Enable Yarn v4
RUN npm install -g corepack && \
    corepack enable && \
    corepack prepare yarn@4.5.1 --activate

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql pdo_sqlite mbstring zip exif pcntl bcmath

# Copy Composer from official image
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy Laravel source
COPY . .

# Fix permissions
RUN chown -R www-data:www-data /var/www/html && chmod -R 775 storage bootstrap/cache

# Trust dir
RUN git config --global --add safe.directory /var/www/html

# Install PHP dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader --ignore-platform-reqs

# Build frontend
RUN yarn install --immutable && yarn build && rm -rf node_modules

EXPOSE 9000
CMD ["php-fpm"]
