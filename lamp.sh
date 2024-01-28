#!/bin/bash

# Function to prompt for user input with a default value
prompt_user() {
    read -p "$1 ($2): " input
    echo "${input:-$2}"
}

# Function to display a loading bar
loading_bar() {
    local duration=$1
    local delay=0.2
    local chars=("▏" "▎" "▍" "▌" "▋" "▊" "▉" "█")
    local total_ticks=$((duration / delay))

    for ((i = 0; i < total_ticks; i++)); do
        sleep "$delay"
        printf "%s" "${chars[i % 8]}"
    done
}

# Update package lists
echo "Updating package lists..."
sudo apt update

# Install Apache web server
echo "Installing Apache web server..."
sudo apt install -y apache2

# Install MySQL server
echo "Installing MySQL server..."
sudo apt install -y mysql-server

# Secure MySQL installation (set root password and remove anonymous users)
echo "Securing MySQL installation..."
sudo mysql_secure_installation

# Install PHP and necessary modules
echo "Installing PHP and necessary modules..."
sudo apt install -y php libapache2-mod-php php-mysql php-cli php-pear php-dev php-zip php-curl php-xmlrpc php-gd php-mbstring php-xml unzip

# Restart Apache for changes to take effect
echo "Restarting Apache..."
sudo systemctl restart apache2

# Install Composer (PHP dependency manager)
echo "Installing Composer..."
sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
sudo php -r "unlink('composer-setup.php');"

# Provide instructions to the user
echo "Please enter your desired domain name for Laravel installation."

# Prompt the user for a domain name
domain=$(prompt_user "Domain name" "example.com")

# Prompt the user for the MySQL root password
mysql_root_password=$(prompt_user "Enter your MySQL root password" "your_mysql_root_password")

# Create the default MySQL database for Laravel
echo "Creating default MySQL database..."
mysql -u"root" -p"$mysql_root_password" <<EOF
CREATE DATABASE IF NOT EXISTS $domain;
EOF

# Check if the database creation was successful
if [ $? -eq 0 ]; then
    echo "Default database '$domain' created successfully."
else
    echo "Error creating default database '$domain'."
    exit 1
fi

# Install Laravel using Composer
echo "Installing Laravel using Composer..."
sudo composer create-project --prefer-dist laravel/laravel /var/www/html/"$domain"

# Set proper permissions for Laravel
echo "Setting permissions for Laravel..."
sudo chown -R www-data:www-data /var/www/html/"$domain"
sudo chmod -R 755 /var/www/html/"$domain"/storage

# Install Node.js and npm
echo "Installing Node.js and npm..."
sudo apt install -y nodejs npm

# Install Certbot for Let's Encrypt
echo "Installing Certbot for Let's Encrypt..."
sudo apt install -y certbot python3-certbot-apache

# Obtain and install SSL certificate
echo "Obtaining and installing SSL certificate..."
loading_bar 10 &  # Show a loading bar for 10 seconds
sudo certbot --apache -d "$domain"

# Display information about the installed components
echo "LAMP stack with Laravel, Node.js, and SSL certificate installation complete!"
# Inform the user about the script on GitHub
echo "You can download or contribute to the development of the script on GitHub:"
echo "GitHub Repository: https://github.com/bo3bdo/lamp"
echo ""

echo "Apache version:"
apache2 -v
echo "MySQL version:"
mysql --version
echo "PHP version:"
php --version
echo "Composer version:"
composer --version
echo "Laravel version:"
php /var/www/html/"$domain"/artisan --version
echo "Node.js version:"
node -v
echo "npm version:"
npm -v

# Display MySQL root password for reference (customize as needed)
echo "MySQL root password: $mysql_root_password"
