## Just some Bash & Python scripts

**log-exploits.sh:** This script is designed to scan the access logs of websites hosted in the /home directory for potential exploits. 

**sus-files.sh:** This script scans files within public_html directories of websites in the /home directory for potential malware or suspicious content, providing a list of suspected files for further investigation.

**new_log_check.sh** This script extracts and analyzes GET and POST requests from a log file, checking for potential SQL injection. The comments provide a step-by-step explanation of each section of the script.

**wp_install.sh** This script reads domain names from the 'domains.txt' file, attempting to install a default WordPress website for each domain and providing login details in the terminal (Ubuntu and Plesk Obsidian).

**ssl_install.sh** This  script automates the installation of Let's Encrypt SSL certificates for domains specified in the 'domains.txt' file (Plesk Obsidian).

**dns.sh** This script uses the dig command to retrieve DNS records for a specified domain, displaying NS, A, MX, CNAME, TXT, SOA and CAA records. 
