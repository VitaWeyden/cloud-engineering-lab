# cloud-engineering-lab

> Cloud-native infrastructure lab: Docker, CI/CD, Kubernetes, Terraform

## Author

[Zsófia Gergely](https://github.com/VitaWeyden)

## About

This repository contains the infrastructure and deployment configuration for two applications built as university projects. The focus is not on the applications themselves, but on building a modern, production-like platform around them using cloud-native technologies.

The goal is to learn and demonstrate real-world DevOps and Cloud Engineering practices: containerization, automated CI/CD pipelines, orchestration, monitoring, and infrastructure as code.

See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for real issues hit while building this (Terraform gotchas, Kubernetes scheduling deadlocks, and how they were diagnosed and fixed).

## Milestones

- [x] Docker Compose orchestration
- [x] GitHub Actions CI/CD pipelines
- [x] GitHub Container Registry image storage
- [x] Monitoring (Prometheus + Grafana)
- [x] Kubernetes (K3s via k3d)
- [x] Terraform
- [ ] Cloud deployment (Oracle Cloud)

## Applications

| Application | Repository | Description |
|---|---|---|
| Violet-board | [VitaWeyden/Violet-board](https://github.com/VitaWeyden/Violet-board) | E-commerce webshop – Laravel, PostgreSQL |
| Echoo | [VitaWeyden/Echoo](https://github.com/VitaWeyden/Echoo) | Chat application – AdonisJS, Vue, PostgreSQL |

## Architecture

```
GitHub (Violet-board / Echoo)
        │
        │  git push → GitHub Actions
        │
        ▼
GitHub Container Registry (GHCR)
  ghcr.io/vitaweyden/violet-board-app
  ghcr.io/vitaweyden/violet-board-web
  ghcr.io/vitaweyden/echoo-backend
  ghcr.io/vitaweyden/echoo-frontend
        │
        ├── Docker Compose mode
        │     docker compose pull && docker compose up -d
        │
        └── Kubernetes mode
              kubectl apply -f kubernetes/
              (or python kubernetes/setup.py)
```

## Tech Stack

| Layer | Technology |
|---|---|
| Containerization | Docker |
| Orchestration | Docker Compose / Kubernetes (K3s) |
| CI/CD | GitHub Actions |
| Image Registry | GitHub Container Registry (GHCR) |
| Web Server | Nginx |
| Database | PostgreSQL |
| Monitoring | Prometheus, Grafana, Node Exporter, kube-state-metrics |
| Infrastructure as Code | Terraform |

## Repository Structure

```
cloud-engineering-lab/
│
├── compose/                        # Docker Compose orchestration
│   ├── docker-compose.yml
│   ├── start.py                    # One-command setup and start script
│   ├── violetboard.env.example
│   ├── echoo.env.example
│   └── monitoring.env.example
│
├── monitoring/                     # Monitoring config (Docker Compose mode)
│   ├── prometheus/
│   │   └── prometheus.yml
│   └── grafana/
│       └── provisioning/
│           ├── datasources/
│           │   └── datasource.yml
│           └── dashboards/
│               └── dashboards.yml
│
├── kubernetes/                     # Kubernetes manifests (k3d)
│   ├── setup.py                    # One-command setup script
│   ├── violetboard/
│   │   ├── db.yaml
│   │   ├── app.yaml
│   │   └── web.yaml
│   ├── echoo/
│   │   ├── db.yaml
│   │   ├── backend.yaml
│   │   └── frontend.yaml
│   └── monitoring/
│       ├── prometheus.yaml
│       ├── grafana.yaml
│       ├── exporters.yaml
│       └── dashboards/
│           └── node-exporter.json
│
├── terraform/                      # Infrastructure as Code
│
├── TROUBLESHOOTING.md               # Real issues hit, causes, and fixes
└── README.md
```

---

## Option A – Docker Compose

The simpler option. No Kubernetes.

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Python 3](https://www.python.org/downloads/)
- [Git](https://git-scm.com/)

### Run

```bash
git clone https://github.com/VitaWeyden/cloud-engineering-lab.git   # If you haven't downloaded it yet
cd cloud-engineering-lab
python compose/start.py
```

The script automatically creates `.env` files, generates secret keys, pulls images from GHCR, and starts all containers.

| Service | URL |
|---|---|
| Violet-board | http://localhost:8100 |
| Echoo | http://localhost:8101 |
| Grafana | http://localhost:3000 |
| Prometheus | http://localhost:9090 |

### Update to latest images

```bash
cd compose
docker compose pull
docker compose up -d
```

### Stop

```bash
cd compose
docker compose down
```

### Full reset (including database)

```bash
cd compose
docker compose down -v
```

### Port conflicts

If any port is already in use, edit `compose/docker-compose.yml` and change the left side of the port mapping:

```yaml
ports:
  - "8100:80"   # change 8100 to any free port
                # never change the right side (80)
```

---

## Option B – Kubernetes (k3d)

A production-like setup using K3s inside Docker via k3d.

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Python 3](https://www.python.org/downloads/)
- [Git](https://git-scm.com/)
- kubectl and k3d

### Run

```bash
git clone https://github.com/VitaWeyden/cloud-engineering-lab.git   # If you haven't downloaded it yet
cd cloud-engineering-lab
python kubernetes/setup.py
```

The script automatically:
- Creates a k3d cluster with all required ports
- Creates namespaces (`violetboard`, `echoo`, `monitoring`)
- Creates Secrets from existing `compose/*.env` files (or asks for passwords)
- Creates the Grafana dashboard ConfigMap
- Applies all Kubernetes manifests

| Service | URL |
|---|---|
| Violet-board | http://localhost:8110 |
| Echoo | http://localhost:8111 |
| Grafana | http://localhost:3010 |
| Prometheus | http://localhost:9099 |

Note: these ports are intentionally different from the Docker Compose mode's ports (8100/8101/3000/9090) so that both modes can run at the same time without a port conflict.

### Check pod status

```bash
kubectl get pods --all-namespaces
```

### Stop cluster (keeps data)

```bash
k3d cluster stop cloud-engineering-lab
```

### Start cluster again

```bash
k3d cluster start cloud-engineering-lab
```

### Delete cluster (removes all data)

```bash
k3d cluster delete cloud-engineering-lab
```

### Kubernetes design notes

**Namespaces** – the cluster is divided into three namespaces (`violetboard`, `echoo`, `monitoring`) to logically separate the two applications and the monitoring stack.

**Secrets** – passwords and secret keys are stored as Kubernetes Secrets, not in files. The `setup.py` script reads from `compose/*.env` if available so you don't have to retype them.

**PersistentVolumeClaims** – each database and the seed marker use a PVC so data survives pod restarts. A full reset requires deleting the cluster with `k3d cluster delete`.

**Terraform** – an experimental `terraform/` path exists that recreates the cluster/namespace/secret setup declaratively, as an alternative to `kubernetes/setup.py`. Important: don't run `kubernetes/setup.py` and `terraform apply` against the same cluster — pick one or the other, since both try to create the same secrets and namespaces.

**cAdvisor** – intentionally excluded from the local k3d setup. cAdvisor requires access to the Docker socket which is not available inside k3d on Windows/macOS (Docker Desktop runs containers inside a Linux VM). It will be added when deploying to Oracle Cloud where a real Linux host is available.

**Monitoring** – Node Exporter (host metrics) and kube-state-metrics (Kubernetes object metrics) are included and work locally. The Node Exporter Full dashboard is provisioned automatically via ConfigMap.

---

## Option C – Terraform

A declarative alternative to `kubernetes/setup.py`: the same k3d cluster, namespaces, secrets, and deployments, but described in HCL instead of built with kubectl commands one by one. Builds on the same k3d cluster as Option B — don't run `kubernetes/setup.py` and `terraform apply` against the same cluster.

### Prerequisites

- Everything from Option B (Docker Desktop, kubectl, k3d)
- [Terraform](https://developer.hashicorp.com/terraform/install) (>= 1.5.0)

### Run

```bash
cd terraform
terraform init      # only needed once, or after changing versions.tf
```

**If the cluster doesn't exist yet** (first run, or after `k3d cluster delete`), the Kubernetes provider can't connect until the cluster exists — so create it first, then apply everything else:

```bash
terraform apply -target=null_resource.k3d_cluster
terraform apply
```

**If the cluster already exists** (you're just changing something), a single `terraform apply` is enough.

| Service | URL |
|---|---|
| Violet-board | http://localhost:8110 |
| Echoo | http://localhost:8111 |
| Grafana | http://localhost:3010 |
| Prometheus | http://localhost:9099 |

Grafana's generated admin password isn't printed by default (it's marked `sensitive`):
```bash
terraform output grafana_password
```

### Destroy everything (including the cluster)

```bash
terraform destroy
```

### Notes

- `terraform.tfstate` contains generated passwords and keys in plain text — it's git-ignored, never commit it.
- The `null_resource.k3d_cluster` provisioner (`cluster.tf`) currently assumes **Windows + PowerShell**. On macOS/Linux the `interpreter` line and the command would need to be rewritten in plain `sh`.
- Images are pulled with the `:latest` tag, same as in Option B. Terraform won't notice when a new image is pushed to GHCR (the tag string in the `.tf` file doesn't change) — after a new push, restart the deployments manually: `kubectl rollout restart deployment/<name> -n <namespace>`.

---

## Monitoring

### Grafana dashboards

The Node Exporter Full dashboard is provisioned automatically. To import additional dashboards manually, use their ID at [grafana.com/dashboards](https://grafana.com/grafana/dashboards/):

- **Node Exporter Full** (ID: `1860`) – already provisioned automatically

### Prometheus targets

Available at http://localhost:9090/targets (Docker Compose mode) or http://localhost:9099/targets (Kubernetes mode):
- `prometheus` – Prometheus itself
- `node-exporter` – host machine metrics
- `kube-state-metrics` – Kubernetes object metrics (Kubernetes mode only)