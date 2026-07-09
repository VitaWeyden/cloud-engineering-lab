# cloud-engineering-lab

> Cloud-native infrastructure lab: Docker, CI/CD, Kubernetes, Terraform

## Author

[Zsófia Gergely](https://github.com/VitaWeyden)

## About

This repository contains the infrastructure and deployment configuration for two applications built as university projects. The focus is not on the applications themselves, but on building a modern, production-like platform around them using cloud-native technologies.

The goal is to learn and demonstrate real-world DevOps and Cloud Engineering practices: containerization, automated CI/CD pipelines, orchestration, monitoring, and infrastructure as code.

## Milestones

- [x] Docker Compose orchestration
- [x] GitHub Actions CI/CD pipelines
- [x] GitHub Container Registry image storage
- [x] Monitoring (Prometheus + Grafana)
- [x] Kubernetes (K3s via k3d)
- [ ] Terraform
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
├── terraform/                      # (coming soon) Infrastructure as Code
│
├── start.py                        # Docker Compose setup and start script
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
python start.py
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
| Violet-board | http://localhost:8100 |
| Echoo | http://localhost:8101 |
| Grafana | http://localhost:3000 |
| Prometheus | http://localhost:9090 |

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

**cAdvisor** – intentionally excluded from the local k3d setup. cAdvisor requires access to the Docker socket which is not available inside k3d on Windows/macOS (Docker Desktop runs containers inside a Linux VM). It will be added when deploying to Oracle Cloud where a real Linux host is available.

**Monitoring** – Node Exporter (host metrics) and kube-state-metrics (Kubernetes object metrics) are included and work locally. The Node Exporter Full dashboard is provisioned automatically via ConfigMap.

---

## Monitoring

### Grafana dashboards

The Node Exporter Full dashboard is provisioned automatically. To import additional dashboards manually, use their ID at [grafana.com/dashboards](https://grafana.com/grafana/dashboards/):

- **Node Exporter Full** (ID: `1860`) – already provisioned automatically

### Prometheus targets

Available at http://localhost:9090/targets:
- `prometheus` – Prometheus itself
- `node-exporter` – host machine metrics
- `kube-state-metrics` – Kubernetes object metrics (Kubernetes mode only)