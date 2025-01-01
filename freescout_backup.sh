#!/bin/bash

PATH=/usr/bin:/bin:/usr/local/bin
USER=leon

# Ensure script is run as leon
if [ "$USER" != "leon" ]; then
  echo "Please run this script as leon without sudo." | tee -a backup.log
  exit 1
fi

# Variables
BACKUP_DIR="/home/leon/backups"
HTML_DIR="/var/www/html"
DB_NAME="freescout"
BACKUP_DATE=$(date +%d.%m.%Y_%Hh)
SQL_FILE="${BACKUP_DIR}/freescout-${BACKUP_DATE}.sql"
TAR_FILE="${BACKUP_DIR}/freescout_back-${BACKUP_DATE}.tar.gz"
LOG_FILE="backup.log"

# Initialize the log file
echo "Backup started at $(date)" > "$LOG_FILE"

# Create database backup
echo "Creating database backup..." | tee -a "$LOG_FILE"
if ! mysqldump "$DB_NAME" > "$SQL_FILE"; then
  echo "Database backup failed at $(date)" | tee -a "$LOG_FILE"
  exit 1
fi

# Temporarily elevate privileges where needed (commented out for now)
# sudo systemctl stop apache2
# sudo systemctl stop php7.4-fpm  # Adjust PHP version as needed

# Create HTML directory and database backup
echo "Creating tarball of HTML directory and SQL backup..." | tee -a "$LOG_FILE"
tar -czf "$TAR_FILE" "$HTML_DIR" "$SQL_FILE" >> "$LOG_FILE" 2>&1

# Restart FreeScout services (if needed, commented out for now)
# sudo systemctl start php7.4-fpm
# sudo systemctl start apache2

# Send backup file to Google Drive
echo "Uploading backup to Google Drive..." | tee -a "$LOG_FILE"
if ! rclone copy -v "$TAR_FILE" gdrive: >> "$LOG_FILE" 2>&1; then
  echo "Backup upload failed at $(date)" | tee -a "$LOG_FILE"
  exit 1
fi

echo "Backup completed successfully at $(date)" | tee -a "$LOG_FILE"

# Delete backups and directories older than 60 days from Google Drive 
echo "Cleaning old backups from Google Drive and locally..."
rclone delete gdrive: --min-age 60d -v #--dry-run
rclone rmdirs gdrive: --leave-root -v

# Clean up local backups
rm -f "$TAR_FILE" "$SQL_FILE"
