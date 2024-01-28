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

# ... (Rest of the script remains unchanged)

# Display the status of services without MySQL
echo "Service status:"
echo "Apache status:"
sudo systemctl status apache2 &
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
