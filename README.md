# deploy-pipeline-demo

A small Django app with a full CI/CD pipeline: push to `main` → build → test →
containerize → deploy to an Azure VM → Slack notification. Terraform manages
the one Azure resource this project touches (a network security rule).

## Stack

| Layer | Tool |
|---|---|
| App | Django |
| Container | Docker |
| Registry | GitHub Container Registry (GHCR) |
| CI/CD | GitHub Actions |
| IaC | Terraform (azurerm) |
| Compute | Azure VM (existing, unmanaged by Terraform) |
| Notifications | Slack incoming webhook |

## How it works

1. Push to `main`.
2. GitHub Actions runs `python manage.py check`, then builds the Docker image
   and pushes it to `ghcr.io/<your-repo>`.
3. Actions SSHes into your Azure VM, pulls the new image, stops the old
   container, and starts the new one on port 80.
4. It polls `/health` until the container responds.
5. Slack gets a ✅ or ❌ message.

## One-time setup

**On the Azure VM**
```bash
# install docker if not already present
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```
Make sure the SSH user you'll deploy with is in the `docker` group, and that
you have an SSH key pair for GitHub Actions to use (not your personal key).

**Terraform (opens the port on your NSG)**
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your actual resource group + NSG name
terraform init
terraform plan
terraform apply
```

**GitHub repo secrets** (Settings → Secrets and variables → Actions)

| Secret | Value |
|---|---|
| `AZURE_VM_HOST` | Public IP or DNS name of your VM |
| `AZURE_VM_USER` | SSH username on the VM |
| `AZURE_VM_SSH_KEY` | Private key for that user (deploy-only key, not your personal one) |
| `SLACK_WEBHOOK_URL` | Incoming webhook URL from your Slack app |

`GITHUB_TOKEN` is provided automatically — no setup needed for GHCR push.

**Slack webhook**
Create a Slack app → enable Incoming Webhooks → add one to the channel you
want deploy notifications in → copy the URL into `SLACK_WEBHOOK_URL`.

## Local development

```bash
cd app
pip install -r requirements.txt
python manage.py runserver
```
Visit `http://localhost:8000`.

## Local Docker test

```bash
cd app
docker build -t deploy-demo .
docker run -p 8000:8000 deploy-demo
```

## Routes

| Path | Returns |
|---|---|
| `/` | Landing page showing build version, commit, deploy time |
| `/health` | `{"status": "ok"}` — used by the pipeline to confirm the deploy worked |

## What Terraform manages vs. what it doesn't

Terraform here only manages **one NSG rule** opening port 80 on your existing
VM's network security group. It does not create or manage the VM itself —
that's assumed to already exist. This keeps the IaC footprint small while
still being real, version-controlled infrastructure.
