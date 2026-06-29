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
- [ ] Kubernetes (K3s)
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
        │  docker compose pull
        ▼
   cloud-engineering-lab
  ┌─────────────────────────────────────┐
  │  violetboard-web   (nginx)  :8100   │
  │  violetboard-app   (PHP-FPM)        │
  │  violetboard-db    (PostgreSQL)     │
  │                                     │
  │  echoo-frontend    (nginx)  :8101   │
  │  echoo-backend     (AdonisJS) :3334 │
  │  echoo-db          (PostgreSQL)     │
  │                                     │
  │  grafana           :3000            │
  │  prometheus        :9090            │
  │  cadvisor                           │
  │  node-exporter                      │
  └─────────────────────────────────────┘
```

## Tech Stack

| Layer | Technology |
|---|---|
| Containerization | Docker |
| Orchestration | Docker Compose → Kubernetes |
| CI/CD | GitHub Actions |
| Image Registry | GitHub Container Registry (GHCR) |
| Web Server | Nginx |
| Database | PostgreSQL |
| Monitoring | Prometheus, Grafana, cAdvisor, Node Exporter |
| Infrastructure as Code | Terraform |

## Repository Structure

```
cloud-engineering-lab/
│
├── compose/                        # Docker Compose orchestration
│   ├── docker-compose.yml          # pulls images from GHCR, does not build
│   ├── violetboard.env.example     # Violet-board env template
│   ├── echoo.env.example           # Echoo env template
│   └── monitoring.env.example      # Monitoring env template
│
├── monitoring/                     # Monitoring configuration
│   ├── prometheus/
│   │   └── prometheus.yml          # Prometheus scrape config
│   └── grafana/
│       └── provisioning/
│           ├── datasources/
│           │   └── datasource.yml  # Grafana datasource (Prometheus)
│           └── dashboards/
│               └── dashboards.yml  # Grafana dashboard provisioning
│
├── kubernetes/                     # (coming soon) K8s manifests
│
├── terraform/                      # (coming soon) Infrastructure as Code
│
├── start.py                        # Setup and start script
└── README.md
```

## Getting Started

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Python 3](https://www.python.org/downloads/)
- [Git](https://git-scm.com/)

### Run locally

```bash
git clone https://github.com/VitaWeyden/cloud-engineering-lab.git
cd cloud-engineering-lab
python start.py
```

The script will automatically:
- Check prerequisites
- Create `.env` files from examples and ask for passwords
- Generate secret keys automatically
- Pull the latest images from GHCR
- Start all containers

| Service | URL | Credentials |
|---|---|---|
| Violet-board | http://localhost:8100 | – |
| Echoo | http://localhost:8101 | – |
| Grafana | http://localhost:3000 | admin / your password |
| Prometheus | http://localhost:9090 | – |

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

### Stop and remove all data

```bash
cd compose
docker compose down -v
```

### Port conflicts

If any port is already in use on your machine, edit `compose/docker-compose.yml` and change the left side of the port mapping:

```yaml
ports:
  - "8100:80"   # change 8100 to any free port on your machine
                # never change the right side (80)
```

## Monitoring

Grafana dashboards can be imported from [grafana.com/dashboards](https://grafana.com/grafana/dashboards/):

- **Node Exporter Full** (ID: `1860`) – host machine metrics (CPU, RAM, disk)
- **cAdvisor Docker** (ID: `14282`) – container metrics