#!/bin/bash

DB_USER="ubuntu"
DB_NAME="test"
DB_NAME_TO="main"
PLAYER_ID="2206"
DB_PASSWORD="v6gbPRlNUSyAthPxHtZC"
ERROR_LOG="restore_${PLAYER_ID}_errors.log"

echo "Restoring Player into: $DB_NAME"

# Dump the player row
mysqldump -u "$DB_USER" -p"$DB_PASSWORD" \
    --no-create-info --skip-triggers --replace \
    --where="id=$PLAYER_ID" "$DB_NAME" players > player_$PLAYER_ID.sql

echo "Importing player data into $DB_NAME_TO"

# Import safely, redirect stdout to /dev/null, stderr to ERROR_LOG
mysql -u "$DB_USER" -p"$DB_PASSWORD" \
      --force \
      --show-warnings \
      --execute="source player_$PLAYER_ID.sql" \
      "$DB_NAME_TO" >/dev/null 2> "$ERROR_LOG"

# Check for errors
if [ -s "$ERROR_LOG" ]; then
    echo "❌ Restore FAILED! Check errors in $ERROR_LOG"
else
    echo "✅ Restore completed successfully!"
    # Optionally remove empty log
    rm -f "$ERROR_LOG"
fi
