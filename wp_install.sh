#!/bin/bash
#
# DESCRIPTION: 
# This script reads domain names from the 'domains.txt' file, attempting to install a default WordPress website for each domain.
# It has been tested on Ubuntu 20.04.6 LTS with Plesk Obsidian 18.0.57.5.
#
# The script checks for the presence of 'wp-cli' and 'php-mysql', installs them if needed, and proceeds to create WordPress websites.
# For each domain, it generates a random admin username, database name, and user, then creates the necessary MySQL database and user.
# Subsequently, it creates a Plesk subscription, downloads WordPress, configures wp-config.php, and installs WordPress.
# File ownership and permissions are updated, and information about the installation is displayed.
#
# NOTE: This script assumes that 'wp-cli' and 'php-mysql' are not already installed, and it uses 'domains.txt' for domain names.
# Adjustments may be needed based on specific server configurations and requirements.
#
# AUTHOR: le0np
# DATE: 30/04/2024


# Check if wp-cli is already installed
if command -v wp &> /dev/null; then
    echo -e "wp-cli is already installed.\n"
    echo 
else
    # Install wp-cli
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
    wp --info
fi

# Check if php-mysql is already installed
if ! dpkg -s php-mysql &> /dev/null; then
    # Install php-mysql
    apt install php-mysql -y
else
    echo -e "php-mysql is already installed.\n"
fi

# Add domains names in a file
domains="domains.txt"

# Assign the IP address 
ip=$(hostname -I | awk '{print $1}')

# Define the database host and root password
db_host="localhost"
#read -p "Enter root password for database: " root_password

# Loop through each domain
for domain in $(cat "$domains"); do
  # Generate random string for the admin username
  random_string=$(tr -dc 'a-z0-9' < /dev/urandom | head -c 8)  # Adjust the length as needed

  # Generate database name and user
  db_name="wp_${domain//./_}"
  db_user="user_${domain//./_}"
  db_password=$(openssl rand -base64 20)

  # Set up database and user
# OLD:  mysql -e "CREATE DATABASE IF NOT EXISTS $db_name; GRANT ALL ON $db_name.* TO '$db_user'@'$db_host' IDENTIFIED BY '$db_password'; FLUSH PRIVILEGES;"
  mysql -e "CREATE DATABASE IF NOT EXISTS \`$db_name\`; GRANT ALL ON \`$db_name\`.* TO '$db_user'@'$db_host' IDENTIFIED BY '$db_password'; FLUSH PRIVILEGES;"

  # Create website subscription
  admin_user="admin_$random_string"
  admin_pass=$(tr -dc 'a-zA-Z0-9!@#$%^&*()_+-=[]{}|;:,.<>?/' </dev/urandom | head -c 16)
  title="${domain%%.*}"
  email="admin@$domain"
  service_plan="Default Domain"
  create_output=$(plesk bin subscription --create $domain -service-plan "$service_plan" -ip "$ip" -login "$admin_user" -passwd "$admin_pass" 2>&1)

  # Check if domain creation succeeded
  if [[ "$create_output" == *"SUCCESS"* ]]; then
    subscription_id=$(plesk bin subscription --list | grep -E "$domain" | awk '{print $1}')

    if [ -n "$subscription_id" ]; then
      # Download wp-config-sample.php
      wp core download --path="/var/www/vhosts/$domain/httpdocs/" --allow-root

      # Download WordPress and build wp-config.php
      wp core download --path="/var/www/vhosts/$domain/httpdocs/" --allow-root

      sed -e 's#localhost#'"$db_host"'#; s#database_name_here#'"$db_name"'#; s#username_here#'"$db_user"'#; s#password_here#'"$db_password"'#;' /var/www/vhosts/"$domain"/httpdocs/wp-config-sample.php > /var/www/vhosts/"$domain"/httpdocs/wp-config.php


      # Install WordPress
      wp core install --path="/var/www/vhosts/$domain/httpdocs/" --url="http://$domain" --title="$title" --admin_user="$admin_user" --admin_password="$admin_pass" --admin_email="$email" --allow-root

      # Update file ownership
      chown -R $admin_user: /var/www/vhosts/$domain/httpdocs/
      chown $admin_user:psaserv /var/www/vhosts/$domain/httpdocs/
      
      # Remove index.html
      rm -f /var/www/vhosts/$domain/httpdocs/index.html

      
      # Print out info
      echo "---------------------------------------------------"
      echo "Website and WordPress installed for $domain"
      echo "File ownership updated to $admin_user"
      echo "Admin Username: $admin_user"
      echo "Admin Password: $admin_pass"
      echo "Admin Email: $email"
      echo "Admin Login: $domain/wp-login.php"
      echo -e "---------------------------------------------------\n"
    else
      echo "Failed to retrieve subscription ID for $domain"
    fi
  else
    echo -e "An error occurred during domain creation for $domain: $create_output\n"
  fi
done

