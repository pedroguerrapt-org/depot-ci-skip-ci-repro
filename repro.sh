#!/usr/bin/env bash
set -euo pipefail

# Repro script for: [skip ci] commit labels not being skipped by Depot CI
#
# GitHub Actions supports several patterns in commit messages that should
# prevent push/pull_request workflows from running. Depot CI should honor
# all of them but currently does not.
#
# Reference: https://docs.github.com/en/actions/how-tos/manage-workflow-runs/skip-workflow-runs

cd "$(dirname "$0")"

make_commit() {
  local msg="$1"
  local file="$2"
  echo "change" >> "$file"
  git add "$file"
  git commit -m "$msg"
}

# Create test files (one per skip pattern so each commit has a unique diff)
for i in $(seq 1 7); do
  echo "initial" > "test-${i}.txt"
done
git add test-*.txt
git commit -m "add test files for skip ci repro"

echo ""
echo "=== Pushing baseline commit (should trigger CI) ==="
git push

echo ""
echo "=== Testing bracket-style skip patterns ==="

make_commit "test: verify [skip ci] is honored" "test-1.txt"
make_commit "test: verify [ci skip] is honored" "test-2.txt"
make_commit "test: verify [no ci] is honored" "test-3.txt"
make_commit "test: verify [skip actions] is honored" "test-4.txt"
make_commit "test: verify [actions skip] is honored" "test-5.txt"

echo ""
echo "=== Testing trailer-style skip patterns ==="

# Trailer-style: two blank lines before the trailer
make_commit "test: verify skip-checks trailer is honored


skip-checks:true" "test-6.txt"

make_commit "test: verify skip-checks trailer (with space) is honored


skip-checks: true" "test-7.txt"

echo ""
echo "=== Pushing all skip-ci commits ==="
git push

echo ""
echo "Done. Check Depot CI dashboard — none of the above commits should have"
echo "triggered a workflow run, but currently they all do."
