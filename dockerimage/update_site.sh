#!/bin/sh
set -e

# Environment defaults
REPO_URL="${REPO_URL:-https://github.com/example/repo.git}"
BRANCH="${BRANCH:-main}"
DEST=/usr/local/apache2/htdocs
TMP_DIR=/tmp/site_repo
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
PLACEHOLDER="${PLACEHOLDER:-{{BASE_URL}}}"
BASE_URL="${BASE_URL:-}"

log() { printf "%s\n" "$*"; }

# Prepare the repository URL with authentication token if available
prepare_git_url() {
  local url="$1"
  local token="$2"
  
  if [ -n "$token" ]; then
    # Insert token into the GitHub HTTPS URL
    # Convert https://github.com/user/repo.git to https://token@github.com/user/repo.git
    echo "$url" | sed "s|https://|https://${token}@|g"
  else
    echo "$url"
  fi
}

GIT_URL=$(prepare_git_url "$REPO_URL" "$GITHUB_TOKEN")

log "Updating site from ${REPO_URL} (branch ${BRANCH})"

# Clone or update the repo in a temp location
if [ -d "$TMP_DIR/.git" ]; then
  cd "$TMP_DIR"
  git fetch --all --prune
  git reset --hard "origin/${BRANCH}"
else
  rm -rf "$TMP_DIR"
  git clone --depth 1 --branch "$BRANCH" "$GIT_URL" "$TMP_DIR"
fi

# Sync to DocumentRoot
rm -rf "$DEST"/*
cp -a "$TMP_DIR"/. "$DEST"/

# Replace URLs if specified
if [ -n "$BASE_URL" ]; then
  log "Replacing placeholder $PLACEHOLDER with $BASE_URL"
  find "$DEST" -type f -exec sed -i "s|$PLACEHOLDER|$BASE_URL|g" {} \;
fi

# Ensure permissions (best-effort; UID/GID in base image may vary)
chown -R www-data:www-data "$DEST" 2>/dev/null || true

log "Update complete"
