#!/bin/bash

# Function to display a simple loading bar
function loading_bar() {
    local duration=$1
    local size=$2
    local done_char="▇"
    local empty_char="."

    for ((i=0; i<=$duration; i++)); do
        printf "\r"
        for ((j=0; j<=$size; j++)); do
            if [ $j -lt $i ]; then
                printf "%s" "$done_char"
            else
                printf "%s" "$empty_char"
            fi
        done
        sleep 1
    done
    printf "\n"
}

# Display an explanatory message
echo "Welcome! This script installs Laravel on an Ubuntu server and configures Apache, MySQL, and even SSL certificate using Certbot."
echo "Please follow the instructions and provide the required information to complete the process."
echo ""

# Update the package database
echo "Updating the package database..."
sudo apt-get update > /dev/null 2>&1
loading_bar 5 10
echo "Update successful."

# Install essential packages
echo "Installing essential packages..."
sudo apt-get install -y git curl unzip > /dev/null 2>&1
loading_bar 5 10
echo "Essential packages installed successfully."

# Install PHP and required extensions
echo "Installing PHP and required extensions..."
sudo apt-get install -y php php-cli php-mbstring php-zip php-curl php-xmlrpc php-gd php-mysql php-xml libapache2-mod-php php-pear php-dev > /dev/null 2>&1
loading_bar 5 10
echo "PHP and required extensions installed successfully."

# Install Composer
echo "Installing Composer..."
sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" > /dev/null 2>&1
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer > /dev/null 2>&1
sudo rm composer-setup.php
loading_bar 5 10
echo "Composer installed successfully."

# Install Apache
echo "Installing Apache..."
sudo apt-get install -y apache2 > /dev/null 2>&1
loading_bar 5 10
echo "Apache installed successfully."

# Install MySQL
echo "Installing MySQL..."
sudo apt-get install -y mysql-server > /dev/null 2>&1
loading_bar 5 10
echo "MySQL installed successfully."

# Install Node.js and npm
echo "Installing Node.js and npm..."
sudo apt-get install -y nodejs npm > /dev/null 2>&1
loading_bar 5 10
echo "Node.js and npm installed successfully."

# Install Certbot for SSL certificate management
echo "Installing Certbot..."
sudo apt-get install -y certbot python3-certbot-apache > /dev/null 2>&1
loading_bar 5 10
echo "Certbot installed successfully."

# Prompt the user to enter the domain name
read -p "Please enter the domain name you want to use with Laravel (e.g., example.com): " domain_name

# Install Laravel
echo "Installing Laravel..."
sudo mkdir -p /var/www/$domain_name
sudo chown -R $USER:$USER /var/www/$domain_name
composer create-project --prefer-dist laravel/laravel /var/www/$domain_name > /dev/null 2>&1
sudo chmod -R 755 /var/www/$domain_name  # Set permissions
loading_bar 5 10
echo "Laravel installed successfully."

# Configure VirtualHost file for Apache
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/$domain_name.conf > /dev/null 2>&1
sudo sed -i "s/ServerAdmin webmaster@localhost/ServerAdmin webmaster@$domain_name/g" /etc/apache2/sites-available/$domain_name.conf
sudo sed -i "s/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/$domain_name\/public/g" /etc/apache2/sites-available/$domain_name.conf

# Enable the new Apache configuration
sudo a2ensite $domain_name.conf > /dev/null 2>&1

# Restart Apache
sudo service apache2 restart > /dev/null 2>&1
loading_bar 5 10
echo "Apache configured successfully."

# Obtain a free SSL certificate
sudo certbot --apache -d $domain_name > /dev/null 2>&1
loading_bar 5 10
echo "SSL certificate obtained successfully."

# Display the status of services
echo "Service status:"
echo "Apache status:"
sudo systemctl status apache2 &
loading_bar 5 10

echo "MySQL status:"
sudo systemctl status mysql &
loading_bar 5 10

echo "Node.js status:"
node --version &
loading_bar 5 10

echo "npm status:"
npm --version &
loading_bar 5 10

# Print a message to the user about what happened
echo "Laravel has been successfully installed on the domain $domain_name with an SSL certificate. You can now access the site via https://$domain_name"
echo "Thank you for using the script."
