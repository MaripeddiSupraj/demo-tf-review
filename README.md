# Terraform AI Review Agent — Demo

AI-powered PR review for Terraform: catches security risks, policy violations, cost surprises, and scores every change with GPT-4o.

**See it live →** this repo has the agent pre-configured. Just fork, add a secret, and open a PR.

---

## How to use this solution in your own repo

### 1. Copy the workflow

Add `.github/workflows/pr-review.yml` to your repo:

```yaml
name: Terraform Review Agent
on: pull_request
jobs:
  review:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
      issues: write
    steps:
      - uses: actions/checkout@v4
      - uses: actions/checkout@v4
        with:
          repository: MaripeddiSupraj/ai-agents
          path: ai-agents
          fetch-depth: 1
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.9.0
      - uses: open-policy-agent/setup-opa@v2
        with:
          version: 1.0.0
      - name: Install agent
        working-directory: ai-agents/terraform-review-agent
        run: pip install -r requirements.txt
      - name: Run review
        working-directory: ai-agents/terraform-review-agent
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
          GITHUB_REPOSITORY: ${{ github.repository }}
          TERRAFORM_DIR: ${{ github.workspace }}
        run: python -c "
          import asyncio, os, sys; sys.path.insert(0, os.getcwd())
          from app.models.state import make_initial_state
          from app.workflows.graph import create_review_graph
          async def main():
              initial = make_initial_state()
              initial['pr_number'] = ${{ github.event.pull_request.number }}
              initial['repository'] = '${{ github.repository }}'
              result = await create_review_graph().ainvoke(dict(initial))
              print('Status:', result.get('status'))
          asyncio.run(main())
          "
```

### 2. Add one secret

Go to **Settings → Secrets and variables → Actions** and add:

| Secret | Required | Description |
|--------|----------|-------------|
| `OPENAI_API_KEY` | ✅ Yes | OpenAI API key (GPT-4o) |

Optional: `GCP_SA_KEY` + `GCP_PROJECT_ID` for terraform plan to execute (otherwise plan is skipped).

### 3. Open a PR

Push a branch that changes `.tf` files → the agent automatically reviews and posts results inline.

---

## What the agent checks

| Check | What it finds |
|-------|---------------|
| **Security scan** | Public buckets, open IAM, missing encryption, exposed networks |
| **OPA policy** | Missing labels, cost controls, naming conventions (configurable) |
| **Cost estimate** | Monthly cost breakdown per resource (~$95 for this demo) |
| **AI review** | GPT-4o scores the change (40/100 = reject, 75/100 = needs work) |

## Example: before vs after

| Scenario | Security | OPA | Cost | AI Score |
|----------|----------|-----|------|----------|
| Public bucket + owner role | 5 issues | 21 violations | $95/mo | 40/100 ❌ |
| Fixed (labels, least-privilege) | 3 issues | 0 violations | $32/mo | 75/100 ❌ |

## Try it now

1. Fork this repo
2. Add `OPENAI_API_KEY` as a secret
3. Create a branch, edit `main.tf`, open a PR
4. Watch the agent comment with results
