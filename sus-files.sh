#!/bin/bash

# Directory to scan
scan_directory="/home"

# Command to run for checking suspicious files
check_command="egrep -q 'eval\(|exec\(|gzinflate\(|base64_decode\(|str_rot13\(|gzuncompress\(|rawurldecode\(|strrev\(|ini_set\(chr|chr\(rand\(|shell_exec\(|fopen\(|curl_exec\(|popen\(|x..x..'"

# Loop through directories in the scan directory
for directory in "$scan_directory"/*/; do
    user_directory="${directory%/}"

    # Check if public_html directory exists
    public_html_directory="$user_directory/public_html"
    if [ -d "$public_html_directory" ]; then
        echo "Scanning $public_html_directory"
        
        # Run the command and save output to suspected-malware.txt
        find "$public_html_directory" -type f \( -name "*.php" -o -name "*.js" \) -exec $check_command {} \; -print > "$public_html_directory/suspected-malware.txt"
    fi
done
