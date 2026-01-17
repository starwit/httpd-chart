## httpd with auto-update from GitHub

This image extends the official `httpd` image, installs `git` and `cron`, and runs a cron job that updates site content from a Git repository into the httpd DocumentRoot.

Files:
- `Dockerfile` — image definition
- `update_site.sh` — script the cron job runs to clone/pull and copy site files

Build (override repo/branch at build time if you like):

```bash
docker build --build-arg REPO=https://github.com/your/repo.git \
	--build-arg BRANCH=main -t httpd-git .
```

Run (map host port 8080 to container port 80):

```bash
docker run --rm -p 8080:80 httpd-git
```

Override repository or branch at runtime by passing environment variables:

```bash
docker run --rm -e REPO_URL=https://github.com/your/repo.git -e BRANCH=main -p 8080:80 httpd-git
```

Manual update (run the update script directly inside the image):

```bash
docker run --rm --entrypoint /usr/local/bin/update_site.sh httpd-git
```

Cron schedule:
- Default schedule is every 5 minutes (set in the `Dockerfile` via `CRON_SCHEDULE`). To change the schedule, edit the Dockerfile before building or modify `/etc/cron.d/update_site` in a running container.

Notes:
- The default DocumentRoot for the official `httpd` image is `/usr/local/apache2/htdocs`.
- The `update_site.sh` script will remove existing files in the DocumentRoot before copying the repo contents. Adjust the script if you want merge behavior instead.
