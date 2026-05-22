# Terraform AI Review Agent Demo

AI-powered Terraform PR review — security scanning, policy compliance (OPA), cost estimation, and AI review (GPT-4o).

## How it works

Push a PR with `.tf` changes → GitHub Actions triggers → agent reviews and posts results.

## Setup

1. Fork this repo
2. Add secrets in `Settings > Secrets and variables > Actions`:

| Secret | Required | Description |
|--------|----------|-------------|
| `OPENAI_API_KEY` | ✅ Yes | OpenAI API key (the agent uses GPT-4o) |
| `GCP_SA_KEY` | ❌ No | GCP service account key JSON (for terraform plan) |
| `GCP_PROJECT_ID` | ❌ No | GCP project ID (needed with GCP_SA_KEY) |

With only `OPENAI_API_KEY`, the agent runs security/OPA/cost/AI analysis on plan output. Add GCP credentials for full terraform plan execution.

## Example results

| Scenario | Security | OPA | Cost | AI Score |
|----------|----------|-----|------|----------|
| Public bucket + owner role | 5 issues | 21 violations | $95/mo | 40/100 ❌ |
| Fixed code | 3 issues | 0 violations | $32/mo | 75/100 ❌ |

## Test it

Create a branch, change `main.tf`, open a PR — the agent reviews it automatically.
