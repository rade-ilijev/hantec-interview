#!/bin/bash
echo "[INFO] Waiting for MariaDB to be ready..."
sleep 30

# Function to handle errors
handle_error() {
    echo "[ERROR] $1"
    exit 1
}

# Function to show success
show_success() {
    echo "[SUCCESS] $1"
}

# Function to show info
show_info() {
    echo "[INFO] $1"
}

echo "[START] Starting WordPress setup..."

# Install WP-CLI
echo "[STEP] Installing WP-CLI..."
if ! curl -L -o wp-cli.phar "https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar" --silent; then
    handle_error "Failed to download WP-CLI"
fi

if ! chmod +x wp-cli.phar; then
    handle_error "Failed to make WP-CLI executable"
fi

if ! mv wp-cli.phar /usr/local/bin/wp; then
    handle_error "Failed to move WP-CLI to /usr/local/bin"
fi
show_success "WP-CLI installed successfully"

# Set up uploads directory
echo "[STEP] Setting up uploads directory..."
mkdir -p /var/www/html/wp-content/uploads
chown -R www-data:www-data /var/www/html/wp-content/uploads
chmod -R 755 /var/www/html/wp-content/uploads
show_success "Uploads directory configured"

# Install WordPress
echo "[STEP] Installing WordPress..."
if wp core is-installed --allow-root; then
    show_info "WordPress is already installed"
else
    wp core install --url=http://localhost:8000 \
        --title="WordPress Site" \
        --admin_user=admin \
        --admin_password=admin123 \
        --admin_email=admin@example.com \
        --skip-email \
        --allow-root || handle_error "Failed to install WordPress"
    show_success "WordPress installed successfully"
fi

# Create editor user
echo "[STEP] Creating editor user..."
if wp user get rade --allow-root &>/dev/null; then
    show_info "User 'rade' already exists"
else
    wp user create rade rade@example.com --role=editor --user_pass=rade123 --allow-root || handle_error "Failed to create editor user"
    show_success "Editor user created successfully"
fi

# Set permalink structure
echo "[STEP] Setting permalink structure..."
wp option update permalink_structure '/%postname%/' --allow-root || handle_error "Failed to set permalink structure"
show_success "Permalink structure updated"

# Activate plugin
echo "[STEP] Activating custom-api plugin..."
if wp plugin is-active custom-api --allow-root; then
    show_info "Plugin 'custom-api' is already active"
else
    wp plugin activate custom-api --allow-root || handle_error "Failed to activate custom-api plugin"
    show_success "Plugin activated successfully"
fi

# Create test posts
echo "[STEP] Creating test posts..."
wp post create --post_type=post \
    --post_title='First Test Post' \
    --post_content='This is the content of the first test post.' \
    --post_status=publish \
    --post_author=1 \
    --allow-root || handle_error "Failed to create first test post"

wp post create --post_type=post \
    --post_title='Second Test Post' \
    --post_content='This is the content of the second test post with more details.' \
    --post_status=publish \
    --post_author=2 \
    --allow-root || handle_error "Failed to create second test post"
show_success "Test posts created successfully"

echo "[DONE] WordPress setup completed successfully!" 