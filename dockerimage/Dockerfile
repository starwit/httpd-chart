FROM httpd:2.4.66-trixie

# Build args / env defaults
ARG REPO=https://codeberg.org/ztarbug/gtp-landingpage.git
ARG BRANCH=main
ENV REPO_URL=${REPO}
ENV BRANCH=${BRANCH}
ENV CRON_SCHEDULE="*/5 * * * *"
ENV GITHUB_TOKEN=""
ENV BASE_URL=""
ENV PLACEHOLDER="{{BASE_URL}}"

# Install git, cron and ca-certificates (Debian-based httpd image)
RUN apt-get update \
    && apt-get install -y --no-install-recommends git cron ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Add update script that pulls the repo into the site root
COPY update_site.sh /usr/local/bin/update_site.sh
RUN chmod +x /usr/local/bin/update_site.sh

# Add entrypoint script that sets up cron at runtime
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose default HTTP port
EXPOSE 80

# Use entrypoint script to set up cron at runtime and start services
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]