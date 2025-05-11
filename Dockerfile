FROM php:8.2-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Set working directory
WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./
COPY composer.json composer.lock ./

# Install dependencies
RUN composer install --no-dev --optimize-autoloader
RUN npm install --legacy-peer-deps

# Copy the rest of the application
COPY . .

# Build assets
RUN npm run build

# Verify the manifest file exists
RUN ls -la public/build || echo "Build directory not created"
RUN ls -la public/build/manifest.json || echo "Manifest not created"

# Set permissions
RUN chmod -R 777 storage bootstrap/cache

# Expose port
EXPOSE 8000

# Start application
CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=${PORT:-8000}