# PostgreSQL Backup Script

This script automates daily and weekly backups of a PostgreSQL database, with options for logging, directory management, and error handling. The script is intended to be run on a Linux server where PostgreSQL is installed and accessible.

## Features

- **Daily Backups**: Stores a backup of the database every day in a designated "daily" directory.
- **Weekly Backups**: Stores a weekly backup (on Sundays) in a separate "weekly" directory.
- **Automatic Directory Management**: Creates necessary backup directories if they do not already exist.
- **Error Handling**: Utilizes `set -e` to halt execution on any command failure.
- **Logging**: Logs backup success and failure events for easy tracking.

## Requirements

- **PostgreSQL Client**: Ensure `pg_dump` is installed and available on the system running the script.
- **Permissions**: The script requires read and write access to the specified backup directory.
- **Cron Setup (optional)**: To automate daily execution, set up a cron job.

## Configuration

Edit the following variables at the beginning of the script to match your PostgreSQL setup:

- `DB_NAME`: The name of the database to back up.
- `DB_USER`: The PostgreSQL user with access to the database.
- `DB_HOST`: The host where the database is running (use `localhost` if it's on the same server).
- `BACKUP_DIR`: The main directory where backups will be stored.

## Usage

1. **Clone the Repository** or create the script directly on your server.

2. **Edit Configuration**: Modify `DB_NAME`, `DB_USER`, `DB_HOST`, and `BACKUP_DIR` as needed.

3. **Run the Script Manually** (for testing):
   ```bash
   ./backup_script.sh
   ```

4. **Automate with Cron (Optional)**:
   To run this script daily, set up a cron job:
   ```bash
   crontab -e
   ```
   Add the following line to run the backup at midnight every day:
   ```bash
   0 0 * * * /path/to/backup_script.sh
   ```

## Example Script

```bash
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
```

## Logging

- The script logs all backup events in `backup_log.txt` in the `BACKUP_DIR`.
- Each entry includes a timestamp and specifies whether the backup was successful or failed.

## Error Handling

- The `set -e` command stops the script from any error, preventing partial backups.
- Logging provides detailed error information in case of failure.

## License

This project is licensed under the MIT License.

---
