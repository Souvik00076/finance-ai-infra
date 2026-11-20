#!/usr/bin/env bash
set -euo pipefail

# Default: every 24 hours, at midnight (00:00 in TZ).
CRON_SCHEDULE="${CRON_SCHEDULE:-0 0 * * *}"

if [ "${RUN_ON_STARTUP:-true}" = "true" ]; then
  echo "Running initial backup on startup..."
  /usr/local/bin/backup.sh || echo "Initial backup failed; cron will retry on schedule"
fi

echo "${CRON_SCHEDULE} /usr/local/bin/backup.sh" > /tmp/crontab
echo "Scheduling backups: ${CRON_SCHEDULE}"
exec /usr/local/bin/supercronic /tmp/crontab
