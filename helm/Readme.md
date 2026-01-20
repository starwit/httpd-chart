# Apache httpd with git

Based on official httpd image, this image adds git client and a script, that pulls static web page from a git repo.

## Overview

This Helm chart deploys an Apache HTTP server that automatically pulls and serves static content from a Git repository. The container includes a cron job that periodically updates the website content.

## Installation

### From Docker Hub

```bash
helm repo add starwitorg https://hub.docker.com/r/starwitorg/httpd-git-chart
helm install my-httpd-git starwitorg/httpd-git-chart
```

### From Source

```bash
helm install my-httpd-git ./helm
```

## Configuration

### Image Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Docker image repository | `starwitorg/httpd-git` |
| `image.tag` | Docker image tag | `2.4.66` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Application Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `repoUrl` | Git repository URL to pull content from | `https://codeberg.org/ztarbug/gtp-landingpage.git` |
| `accessToken` | if set it will be used to clone code from private repos |  |
| `branch` | Git branch to checkout | `main` |
| `cronSchedule` | Cron schedule for updating content | `*/5 * * * *` (every 5 minutes) |
| `replicaCount` | Number of replicas | `1` |

### Service Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `80` |

### Ingress Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.className` | Ingress class name | `traefik` |
| `ingress.hosts` | Ingress hosts configuration | `landing.cluster.local` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.tls` | TLS configuration | `[]` |

### Resource Management

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources` | CPU/Memory resource requests/limits | `{}` |
| `nodeSelector` | Node selector for pod assignment | `{}` |
| `tolerations` | Tolerations for pod assignment | `[]` |
| `affinity` | Affinity rules for pod assignment | `{}` |

## Usage Examples

### Basic Installation

```bash
helm install my-site ./helm
```

### Custom Git Repository

```bash
helm install my-site ./helm \
  --set repoUrl=https://github.com/myuser/mysite.git \
  --set branch=production
```

### Custom Update Schedule

```bash
helm install my-site ./helm \
  --set cronSchedule="0 */2 * * *"  # Update every 2 hours
```

### With Custom Values File

Create a `custom-values.yaml`:

```yaml
repoUrl: https://github.com/myorg/website.git
branch: main
cronSchedule: "0 */1 * * *"  # Every hour

ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: mysite.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: mysite-tls
      hosts:
        - mysite.example.com

resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"
```

Then install:

```bash
helm install my-site ./helm -f custom-values.yaml
```

## Environment Variables (Container Level)

The following environment variables are automatically set by the Helm chart:

- `REPO_URL`: Git repository URL
- `BRANCH`: Git branch to checkout
- `CRON_SCHEDULE`: Cron schedule for content updates

## How It Works

1. The container starts and immediately pulls content from the specified Git repository
2. A cron job runs according to the `cronSchedule` to periodically update content
3. Apache HTTP server serves the content from `/usr/local/apache2/htdocs/`
4. Logs are written to `/var/log/update_site.log`

## Troubleshooting

### Check Update Logs

```bash
kubectl logs deployment/my-httpd-git
kubectl exec deployment/my-httpd-git -- tail -f /var/log/update_site.log
```

### Verify Environment Variables

```bash
kubectl exec deployment/my-httpd-git -- env | grep -E "REPO_URL|BRANCH|CRON_SCHEDULE"
```
