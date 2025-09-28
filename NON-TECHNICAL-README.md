TaskForge — Non-Technical Quick Start

Goal

This short guide explains, in plain English, what this project does and how to run the app on your computer. No deep technical knowledge required — just follow the steps.

What this project is

- A simple web app made of three parts:
  - Frontend (what you see in the browser)
  - Backend (the server that stores and serves your data)
  - Database (where data is saved)

- The project is prepared so developers can run it on a single computer for testing and demonstration.

Quick one-click start (what I did for you)

1. Make sure you have Docker Desktop installed and running.
2. Open PowerShell and run these commands from the project folder (`d:\project`):

```powershell
cd d:\project
# Build and start the app (frontend, backend, and database)
docker compose up -d --build

# Check the backend health (should return a small success message)
Invoke-WebRequest -UseBasicParsing http://localhost:3500/healthz

# Open the frontend in your browser (served on port 8080)
# Visit: http://localhost:8080
```

What to look for (how to verify it works)

- Backend: visit http://localhost:3500/healthz — you should see a small healthy message.
- Frontend: open http://localhost:8080 — the app UI should load and let you create/list tasks.
- Create a task in the UI and then check the backend API to see it saved.

Where the important files live (one-line each)

- `Application-Code/frontend/` — the website (React) source and Dockerfile used to build the production site.
- `Application-Code/backend/` — the server (Node) source and Dockerfile; provides API endpoints.
- `docker-compose.yml` — brings the three parts up locally (database, backend, frontend).
- `helm-charts/` — templates used later to deploy to Kubernetes (optional for local testing).
- `jenkins/` — an example pipeline for CI/CD automation (builds and publishes images).
- `terraform/` — cloud blueprints (not used when running locally).

Notes and safe practices

- Do not commit passwords or secrets into the repository. Use environment variables or secret managers for sensitive values.
- If you want to stop the app:

```powershell
cd d:\project
docker compose down
```

Need help?

Tell me which step you'd like me to do next and I can run it for you (for example: build & run, create a PR, deploy to a local Kubernetes cluster).