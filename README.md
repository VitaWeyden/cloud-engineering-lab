# cloud-engineering-lab

> Cloud-native infrastructure lab: Docker, CI/CD, Kubernetes, Terraform

## Author

[Zsófia Gergely](https://github.com/VitaWeyden)

## About

This repository contains the infrastructure and deployment configuration for two applications built as university projects. The focus is not on the applications themselves, but on building a modern, production-like platform around them using cloud-native technologies.

The goal is to learn and demonstrate real-world DevOps and Cloud Engineering practices: containerization, automated CI/CD pipelines, orchestration, monitoring, and infrastructure as code.

## Milestones

- [X] Docker Compose orchestration
- [ ] GitHub Actions CI/CD pipelines
- [ ] GitHub Container Registry image storage
- [ ] Monitoring (Prometheus + Grafana)
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
  │  violetboard-web   (nginx)  :8000   │
  │  violetboard-app   (PHP-FPM)        │
  │  violetboard-db    (PostgreSQL)     │
  │                                     │
  │  echoo-frontend    (nginx)  :8080   │
  │  echoo-backend     (AdonisJS)       │
  │  echoo-db          (PostgreSQL)     │
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
| Monitoring | Prometheus, Grafana |
| Infrastructure as Code | Terraform |

## Repository Structure

```
cloud-engineering-lab/
│
├── compose/                        # Docker Compose orchestration
│   ├── docker-compose.yml          # pulls images from GHCR, does not build
│   ├── violetboard.env.example
│   └── echoo.env.example
│
└── README.md
```

## Getting Started

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Git](https://git-scm.com/)

### Run locally

```bash
git clone https://github.com/VitaWeyden/cloud-engineering-lab.git
cd cloud-engineering-lab/compose
```

Create the .env files by copying the violetboard.env.example file to violetboard.env, the echoo.env.example to echoo.env. Also don't forget to fill in passwords and keys in both .env files. Then use:

```bash
docker compose up -d
```

| Application | URL |
|---|---|
| Violet-board | http://localhost:8000 |
| Echoo | http://localhost:8080 |

### Update to latest images

> This step will be automated via GitHub Actions deploy workflow in a later milestone.

```bash
docker compose pull
docker compose up -d
```

### Stop

```bash
docker compose down
```

### Stop and remove all data

```bash
docker compose down -v
```