#!/bin/sh
set -e

# Environment defaults
REPO_URL="${REPO_URL:-https://github.com/example/repo.git}"
BRANCH="${BRANCH:-main}"
DEST=/usr/local/apache2/htdocs
TMP_DIR=/tmp/site_repo

log() { printf "%s\n" "$*"; }

log "Updating site from ${REPO_URL} (branch ${BRANCH})"

# Clone or update the repo in a temp location
if [ -d "$TMP_DIR/.git" ]; then
  cd "$TMP_DIR"
  git fetch --all --prune
  git reset --hard "origin/${BRANCH}"
else
  rm -rf "$TMP_DIR"
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMP_DIR"
fi

# Sync to DocumentRoot
rm -rf "$DEST"/*
cp -a "$TMP_DIR"/. "$DEST"/

# Ensure permissions (best-effort; UID/GID in base image may vary)
chown -R www-data:www-data "$DEST" 2>/dev/null || true

log "Update complete"
