# thesis-pipeline

Implementation for the BSc thesis **"Design and implementation of CI/CD pipelines for cloud-native applications"** (GitHub Actions + Docker + Kubernetes via Kind).

All code in this folder is the author's own work.

## Sample app (`app/`)

<!-- TODO (step 1): document
  - prerequisites (Node version)
  - install: npm ci
  - run: npm start (PORT, APP_VERSION env vars and defaults)
  - test / coverage / lint commands
  - endpoint table
-->

## Pipeline steps

| # | Step | Status |
|---|---|---|
| 1 | REST API sample app with tests | in progress |
| 2 | Dockerfile (multi-stage) + docker-compose | – |
| 3 | GitHub Actions CI: lint, test, build, push to GHCR | – |
| 4 | Kind cluster in Actions + Kubernetes manifests | – |
| 5 | CD: deploy to Kind on main + smoke test | – |
| 6 | Trivy scanning + caching + matrix | – |
| 7 | Monitoring (metrics endpoint, Prometheus/Grafana) | – |
| 8 | Measurements for the evaluation chapter | – |
