# Terraform AI Review Agent — Demo

AI-powered PR review for Terraform: catches security risks, policy violations, cost surprises, and scores changes with GPT-4o.

## How to use in any repo

Add this single block to `.github/workflows/pr-review.yml`:

```yaml
- uses: actions/checkout@v4
- uses: MaripeddiSupraj/ai-agents/terraform-review-agent/action@v1
  with:
    openai_api_key: ${{ secrets.OPENAI_API_KEY }}
```

Then add `OPENAI_API_KEY` under **Settings → Secrets and variables → Actions**.

That's it. Every PR with `.tf` changes gets reviewed automatically.

## What the agent checks

| Check | What it finds |
|-------|---------------|
| **Security scan** | Public buckets, open IAM, missing encryption |
| **OPA policy** | Missing labels, cost controls, naming rules |
| **Cost estimate** | Monthly spend per resource |
| **AI review** | GPT-4o scores the change (40 = reject, 75 = needs work) |

## Try it

1. Fork this repo
2. Add `OPENAI_API_KEY` as a secret
3. Create a branch, edit `main.tf`, open a PR
4. Agent comments with results automatically
