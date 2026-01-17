# Docker image & Helm chart for Apache's httpd
This repo contains a Dockerfile to run an httpd instance, that pulls a static web page from a (public) git repository.

## Docker image
Based on official httpd image, this image adds git client and a script, that pulls static web page from a git repo.

## Helm chart
Deploys Docker image to a Kubernetes cluster.

# License
TODO