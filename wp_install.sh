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
# AUTHOR: [Your Name]
# DATE: [Current Date]
