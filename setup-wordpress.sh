#!/bin/bash

echo "Waiting for WordPress to be ready..."
sleep 30

echo "Installing WP-CLI..."
if ! curl -L -o wp-cli.phar "https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"; then
    echo "Failed to download WP-CLI"
    exit 1
fi

if ! chmod +x wp-cli.phar; then
    echo "Failed to make WP-CLI executable"
    exit 1
fi

if ! mv wp-cli.phar /usr/local/bin/wp; then
    echo "Failed to move WP-CLI to /usr/local/bin"
    exit 1
fi

echo "Installing WordPress..."
wp core install --url=http://localhost:8000 \
    --title="WordPress Site" \
    --admin_user=admin \
    --admin_password=admin123 \
    --admin_email=admin@example.com \
    --skip-email \
    --allow-root

wp user create rade rade@example.com --role=editor --user_pass=rade123 --allow-root

echo "Setting permalink structure..."
wp option update permalink_structure '/%postname%/' --allow-root

echo "Activating custom-api plugin..."
wp plugin activate custom-api --allow-root

# Create some test posts
echo "Creating test posts..."
wp post create --post_type=post \
    --post_title='First Test Post' \
    --post_content='This is the content of the first test post.' \
    --post_status=publish \
    --post_author=1 \
    --allow-root

wp post create --post_type=post \
    --post_title='Second Test Post' \
    --post_content='This is the content of the second test post with more details.' \
    --post_status=publish \
    --post_author=2 \
    --allow-root

echo "WordPress setup completed!" 