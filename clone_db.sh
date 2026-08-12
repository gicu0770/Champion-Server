#!/bin/bash

# Configuration
DB_USER="ubuntu"
DB_NAME="main"
DB_PASSWORD="v6gbPRlNUSyAthPxHtZC"
TARGET_DB="test"

mysql -u "$DB_USER" -p"$DB_PASSWORD" -e "
    SET GLOBAL max_allowed_packet = 1024*1024*1024;
"

# Clone the DB directly (no file)
mysqldump --max_allowed_packet=1024M \
          -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" \
| mysql -u "$DB_USER" -p"$DB_PASSWORD" "$TARGET_DB"

# Print success message
echo "Finished cloning database"