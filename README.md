# Depot CI `[skip ci]` repro

Depot CI does not honor `[skip ci]` commit message labels. GitHub Actions
supports several patterns that prevent `push` and `pull_request` workflows
from running when present in the commit message or PR title.

## Skip patterns that should be supported

**Bracket-style** (anywhere in the commit message):

- `[skip ci]`
- `[ci skip]`
- `[no ci]`
- `[skip actions]`
- `[actions skip]`

**Trailer-style** (at the end of the commit message, after two blank lines):

- `skip-checks:true`
- `skip-checks: true`

Reference: https://docs.github.com/en/actions/how-tos/manage-workflow-runs/skip-workflow-runs

## How to reproduce

```bash
./repro.sh
```

The script pushes commits with each skip pattern. Check the Depot CI
dashboard afterwards — all commits trigger workflow runs when none of them
should.

## Expected behavior

Commits containing any of the above patterns should **not** trigger `push`
or `pull_request` workflow runs, matching GitHub Actions behavior.

## Actual behavior

All commits trigger workflow runs regardless of the skip pattern in the
commit message.
