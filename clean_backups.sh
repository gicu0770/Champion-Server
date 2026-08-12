
BACKUP_DIR="/home/ubuntu/forgottenserver/backups"
DAYS_TO_KEEP=7

LOG_FILE="/home/ubuntu/forgottenserver/cleanup_backups.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting backup cleanup..." | tee -a "$LOG_FILE"
find "$BACKUP_DIR" -type f -name "*.sql.gz" -mtime +$DAYS_TO_KEEP -print -delete | tee -a "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cleanup completed." | tee -a "$LOG_FILE"
