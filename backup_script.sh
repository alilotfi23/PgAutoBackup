#!/bin/bash
set -e

# Configuration
DB_NAME="postgres"
DB_USER="postgres"
DB_HOST="localhost"
BACKUP_DIR="/home/user/backup"
DAILY_BACKUP_DIR="$BACKUP_DIR/daily"
WEEKLY_BACKUP_DIR="$BACKUP_DIR/weekly"
DATE=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$BACKUP_DIR/backup_log.txt"

# Create directories if they don't exist
mkdir -p "$DAILY_BACKUP_DIR"
mkdir -p "$WEEKLY_BACKUP_DIR"

# Function to perform a backup with logging
perform_backup() {
    local backup_file="$1"
    if pg_dump -U "$DB_USER" -h "$DB_HOST" "$DB_NAME" > "$backup_file"; then
        echo "$DATE: Backup successful: $backup_file" >> "$LOG_FILE"
    else
        echo "$DATE: Backup failed: $backup_file" >> "$LOG_FILE"
    fi
}

# Daily backup
DAILY_BACKUP_FILE="$DAILY_BACKUP_DIR/${DB_NAME}_$DATE.sql"
perform_backup "$DAILY_BACKUP_FILE"

# Weekly backup (only on Sundays)
if [ "$(date +%u)" -eq 7 ]; then
    WEEKLY_BACKUP_FILE="$WEEKLY_BACKUP_DIR/${DB_NAME}_$DATE.sql"
    perform_backup "$WEEKLY_BACKUP_FILE"
fi

echo "Backup completed at $DATE"
