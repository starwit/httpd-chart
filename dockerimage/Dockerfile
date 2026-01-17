FROM httpd:2.4.66-trixie

# Build args / env defaults
ARG REPO=https://codeberg.org/ztarbug/gtp-landingpage.git
ARG BRANCH=main
ENV REPO_URL=${REPO}
ENV BRANCH=${BRANCH}
ENV CRON_SCHEDULE="*/5 * * * *"

# Install git, cron and ca-certificates (Debian-based httpd image)
RUN apt-get update \
    && apt-get install -y --no-install-recommends git cron ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Add update script that pulls the repo into the site root
COPY update_site.sh /usr/local/bin/update_site.sh
RUN chmod +x /usr/local/bin/update_site.sh

# Add cron job (uses env CRON_SCHEDULE)
RUN printf "%s root /usr/local/bin/update_site.sh >> /var/log/update_site.log 2>&1\n" "$CRON_SCHEDULE" > /etc/cron.d/update_site \
    && chmod 0644 /etc/cron.d/update_site \
    && touch /var/log/update_site.log

# Expose default HTTP port
EXPOSE 80

# Run an initial update (so repo is fetched on start), then start cron and httpd
CMD ["sh", "-c", "/usr/local/bin/update_site.sh >> /var/log/update_site.log 2>&1 || true; cron && exec httpd-foreground"]