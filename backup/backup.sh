#!/usr/bin/env bash
# Dumps the MongoDB database and uploads it to Google Drive as one fixed-name file.
# The Drive file is updated in place if it exists, created otherwise.
set -euo pipefail

: "${MONGO_URI:?MONGO_URI is required}"
: "${GDRIVE_TOKEN:?GDRIVE_TOKEN is required (output of: rclone authorize \"drive\")}"

BACKUP_NAME="${BACKUP_NAME:-backup_souvik_finance.gz}"
WORK_DIR="$(mktemp -d)"
ARCHIVE="${WORK_DIR}/${BACKUP_NAME}"
trap 'rm -rf "${WORK_DIR}"' EXIT

log() { echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $*"; }

# rclone remote "gdrive" configured entirely from env (nothing written to disk).
export RCLONE_CONFIG=/notfound
export RCLONE_CONFIG_GDRIVE_TYPE=drive
export RCLONE_CONFIG_GDRIVE_SCOPE=drive
export RCLONE_CONFIG_GDRIVE_TOKEN="${GDRIVE_TOKEN}"
[ -n "${GDRIVE_CLIENT_ID:-}" ] && export RCLONE_CONFIG_GDRIVE_CLIENT_ID="${GDRIVE_CLIENT_ID}"
[ -n "${GDRIVE_CLIENT_SECRET:-}" ] && export RCLONE_CONFIG_GDRIVE_CLIENT_SECRET="${GDRIVE_CLIENT_SECRET}"
[ -n "${GDRIVE_FOLDER_ID:-}" ] && export RCLONE_CONFIG_GDRIVE_ROOT_FOLDER_ID="${GDRIVE_FOLDER_ID}"

DUMP_ARGS=(--uri="${MONGO_URI}" --archive="${ARCHIVE}" --gzip)
[ -n "${MONGO_DB_NAME:-}" ] && DUMP_ARGS+=(--db="${MONGO_DB_NAME}")

log "Starting mongodump${MONGO_DB_NAME:+ (db: ${MONGO_DB_NAME})}"
mongodump "${DUMP_ARGS[@]}"

if [ ! -s "${ARCHIVE}" ]; then
  log "ERROR: dump archive is empty, not uploading"
  exit 1
fi
log "Dump complete: $(du -h "${ARCHIVE}" | cut -f1)"

# copyto updates the existing Drive file with the same name, or creates it.
log "Uploading to gdrive:${BACKUP_NAME}"
rclone copyto "${ARCHIVE}" "gdrive:${BACKUP_NAME}" --stats-one-line -v
log "Backup finished"
