FROM php:8.1-fpm

# Copy composer.lock and composer.json
COPY src/composer.lock src/composer.json /var/www/

# Set working directory
WORKDIR /var/www

#Add source.list

RUN printf "deb http://ftp.ru.debian.org/debian/ bullseye main contrib non-free\ndeb-src http://ftp.ru.debian.org/debian/ bullseye main contrib non-free\ndeb http://ftp.ru.debian.org/debian/ bullseye-updates main contrib non-free\ndeb-src http://ftp.ru.debian.org/debian/ bullseye-updates main contrib non-free" > /etc/apt/sources.list.d/backports.list

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    libonig-dev \
    htop \
    unzip \
    git \
    curl

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
# RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
# RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
# RUN docker-php-ext-install gd


# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
# Get latest Composer
#COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY . /var/www

# Copy existing application directory permissions
COPY --chown=www:www . /var/www

# Change current user to www
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
