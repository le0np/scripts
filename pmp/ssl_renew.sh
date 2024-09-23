#!/bin/bash

# Prompt for email address for SSL renewal 
read -p "Enter email address for SSL renewal: " email
# Loop through each directory in /var/www/vhosts
for domain in /var/www/vhosts/*; do
    # Extract just the domain name from the full path
    domain=$(basename "$domain")

    # Run the Plesk Let's Encrypt command for the domain and its www subdomain
    plesk bin extension --exec letsencrypt cli.php -d "$domain" -d "www.$domain" -m "$email" --renew;
done
