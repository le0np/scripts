#!/bin/bash

read -p "Enter DB name:"  answer
echo "===== Checking ${answer}"

# Scan WordPress files  in the public_html directory
cd /home/master/applications/$answer/public_html/
echo -n "Moving into " &&  pwd
echo "===== Scanning $file for compromised files..."
echo "===== Creating a new file malwarescan.txt..."
touch malwarescan.txt

echo "===== Checking index.php..."
echo "============================================" > malwarescan.txt
echo "===== Checking index.php..." >> malwarescan.txt
echo "============================================" >> malwarescan.txt
cat index.php >> malwarescan.txt

echo "===== Checking index.html..."
echo "============================================" >> malwarescan.txt
echo "===== Checking index.html..." >> malwarescan.txt
echo "============================================" >> malwarescan.txt
cat index.html >> malwarescan.txt 2>/dev/null
    if [ $? -eq 1 ]; then
    # Command failed, handle the error here
    echo "index.html does not exist"
    fi

echo "===== Checking .htaccess..."
echo "============================================" >> malwarescan.txt
echo "===== Checking .htaccess" >>  malwarescan.txt
echo "============================================" >> malwarescan.txt
cat .htaccess >> malwarescan.txt

echo "===== Checking header.php..."
echo "============================================" >> malwarescan.txt
echo "===== Checking header.php..." >>  malwarescan.txt
echo "============================================" >> malwarescan.txt
cat wp-content/themes/*/header.php >> malwarescan.txt

echo "===== Checking footer.php..."
echo "============================================" >> malwarescan.txt
echo "===== Checking footer.php..." >>  malwarescan.txt
echo "============================================" >> malwarescan.txt
cat wp-content/themes/*/footer.php >> malwarescan.txt

echo "===== Checking functions.php..."
echo "============================================" >> malwarescan.txt
echo "===== Checking functions.php..." >>  malwarescan.txt
echo "============================================" >> malwarescan.txt
cat wp-content/themes/*/functions.php >> malwarescan.txt

echo "===== Content of index.php, index.html, .htaccess, header.php, footer.php, functions.php is stored in  /home/master/applications/$answer/public_html/malwarescan.txt for manual review."
# Completed checking index.*, .htaccess files
# Checking uploads folder
echo "Checking uploads folder..."

# NEEDS FIXING
# Set the flag to 0
found=0

# Use the find command to search for files in the specified directory
# that are either .js or .php files and execute the `grep` command on them
find /home/master/applications/$answer/public_html/wp-content/uploads/ -type f -name "*.js" -o -name "*.php" -exec grep -Rl 'base64_decode' {} \; | while read -r file; do
  # If the base64_decode string is found in the file, set the flag to 1 and print the file name
if grep -q 'base64_decode' "$file"; then
    found=1
    echo "$file"
fi

# Check the value of the flag
if [ $found -eq 1 ]; then
  echo "==== Potentialy Compromised files found!!!!"
else
  echo "==== No compromised files found."
fi
done
echo "Done!"
# END NEEDS FIXING
# The above will need adjusting since I am not getting "No compromised files found" if no files with base64_decode string are not found

# Check wp_users table for suspicious users and send output to malwarescan_users.txt for manual check
echo "===== Checking wp_users table for suspicious users and writing into malwarescan_users.txt file... "
echo "===== Creating a new file malwarescan_users.txt..."
wp user list  > malwarescan_users.txt
echo "Done!"

# Unusual high file count
# Check for directories with an unusual amount of files. If you find one with thousands of files, it could be compromised
echo "===== Checking for the unusual amount of files..."
find -xdev -type d -print0 | while IFS= read -d '' dir; do echo "$(find "$dir" -maxdepth 1 -print0 | grep -zc .) $dir"; done | sort -rn | head
echo "Done!"

# Check Apache logs for  “undefined constant” errors
echo "===== Checking Apache error logs for  “undefined constant” error which can point to malicious code in files and writing into malwarescan_log.txt..."
echo "===== Creating a new file malwarescan_log.txt..."
echo "===== Creating new directory malwarescan_logs..."
mkdir malwarescan_logs 2>/dev/null && cp  ../logs/apache_wordpress*error.log* malwarescan_logs/ && gunzip malwarescan_logs/* 2>/dev/null
grep "undefined constant" malware_logs/*  > malwarescan_log.txt  2>/dev/null
echo "Done!"

# Resetting file and folder permissions to default
read -p "Do you want to reset file/folder permissions? [Yes/No] " response
case $response in
    y|yes)
        echo "Reseting permissions..."
        find -type d -exec chmod 775 {} ';'
        find -type f -exec chmod 664 {} ';'
        echo "Done!"
        ;;
    n|no)
        echo "Skipping permissions reset."
        ;;
    *)
        echo "Invalid response. Please enter Yes or No."
        ;;
esac

# Offer to install core WordPress files
read -p "Do you want to install WordPress core files? (wp-content will be skipped) [Yes/No] " response
response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

case $response in
    y|yes)
        echo "Installing WordPress core..."
        wp core download --skip-content --force
        ;;
    n|no)
        echo "Skipping WordPress core installation."
        ;;
    *)
        echo "Invalid response. Please enter Yes or No."
        ;;
esac

echo -e "=====================================================================================================\n ====> Please check all malwarescan_* files in public_html of app you are scaning for more info <====\n=====================================================================================================\nBye!"