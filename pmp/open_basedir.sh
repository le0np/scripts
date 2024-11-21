#!/bin/bash

# Step 1: Extract domain names and save to /root/domain-list.txt
echo "Extracting domain names..."
MYSQL_PWD=$(cat /etc/psa/.psa.shadow)
mysql psa -uadmin -Ne "SELECT name FROM domains WHERE htype='vrt_hst'" > /root/domain-list.txt
echo "Domain list saved to /root/domain-list.txt"

# Step 2: Create php.txt file with open_basedir configuration
echo "Creating /root/php.txt with open_basedir configuration..."
cat <<EOF > /root/php.txt
open_basedir = {WEBSPACEROOT}{/}{:}{TMP}{/}:/var/www/tmp/
EOF
echo "PHP settings file created: /root/php.txt"

# Step 3: Apply PHP settings to each domain
echo "Applying PHP settings to domains..."
while IFS= read -r DOMAIN; do
  if [[ -n "$DOMAIN" ]]; then
    /usr/local/psa/bin/site --update-php-settings "$DOMAIN" -settings /root/php.txt
    echo "Updated PHP settings for $DOMAIN"
  fi
done < /root/domain-list.txt

echo "All PHP settings applied successfully."
