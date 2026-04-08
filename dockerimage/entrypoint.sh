#!/bin/sh
set -e

# Set crontab from environment variable
CRON_SCHEDULE="${CRON_SCHEDULE:-*/5 * * * *}"

# Generate crontab entry with environment variables
cat > /tmp/crontab.tmp << EOF
# /etc/cron.d/update_site: crontab entries for update_site
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

$CRON_SCHEDULE root env REPO_URL="$REPO_URL" BRANCH="$BRANCH" GITHUB_TOKEN="$GITHUB_TOKEN" BASE_URL="$BASE_URL" PLACEHOLDER="$PLACEHOLDER" /usr/local/bin/update_site.sh >> /var/log/update_site.log 2>&1
EOF

# Install the crontab
cp /tmp/crontab.tmp /etc/cron.d/update_site
chmod 0644 /etc/cron.d/update_site
rm /tmp/crontab.tmp

# Ensure log file exists
touch /var/log/update_site.log

# Run initial update
/usr/local/bin/update_site.sh >> /var/log/update_site.log 2>&1 || true

# Start cron daemon and httpd
cron
exec httpd-foreground