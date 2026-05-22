# Demo — Terraform AI Review Agent

This repo demonstrates the AI-powered Terraform review agent that automatically reviews PRs for security risks, policy violations, cost impact, and code quality.

## How it works

Push a PR changing any `.tf` file → GitHub Actions triggers → agent reviews security, policy, cost → AI scores and comments on the PR.

## Setup

1. **Fork or copy** this repo
2. Add secrets in `Settings > Secrets and variables > Actions`:

| Secret | Required | Description |
|--------|----------|-------------|
| `OPENAI_API_KEY` | Yes | Your OpenAI API key |
| `GCP_PROJECT_ID` | No | GCP project ID (needed for terraform plan) |
| `GCP_SA_KEY` | No | GCP service account key JSON |

3. Push a change and open a PR

## Sample terraform

`main.tf` has intentional security issues (public bucket, broad IAM role) — the agent will catch and report them.
