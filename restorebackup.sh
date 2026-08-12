#!/bin/bash

DB_USER="ubuntu"
DB_NAME="test"
DB_PASSWORD="v6gbPRlNUSyAthPxHtZC"
BACKUP_FILE="/home/ubuntu/forgottenserver/backups/main_backup_2025-12-02_16-00-01.sql"

echo "Restoring database into: $DB_NAME"
echo "Source file: $BACKUP_FILE"

# Increase packet size to avoid "Error 2013"
mysql -u "$DB_USER" -p"$DB_PASSWORD" -e "
    SET GLOBAL max_allowed_packet = 1024*1024*1024;
"
echo "Increased max_allowed_packet + timeouts."

# Restore into existing DB (NO DROP, NO CREATE)
zcat "$BACKUP_FILE" | mysql --max_allowed_packet=1024M -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME"

if [ $? -ne 0 ]; then
    echo "❌ Restore FAILED!"
else
    echo "✅ Restore completed successfully (no drop, imported into existing DB)!"
fi
