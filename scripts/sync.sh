#!/usr/bin/env bash
# Copy the shared files from this repository into the application repositories.
#
#   scripts/sync.sh                  all three repositories
#   scripts/sync.sh be-demo cms      only these
#
# For each repository it creates the branch chore/shared-sync from origin/dev,
# installs the skills in shared/skills.txt, copies shared/agents/workspace.md to
# docs/agents/workspace.md and commits. It does not push: open the PR yourself so it
# follows that repository's own PR template and checks.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BRANCH=chore/shared-sync
MESSAGE='chore(config): sync shared workspace guidance and skills'

repos=("$@")
[[ ${#repos[@]} -gt 0 ]] || repos=(be-demo cms fe-ecommerce-nike-style)

mapfile -t skills < <(grep -Ev '^\s*(#|$)' "$ROOT/shared/skills.txt")

for repo in "${repos[@]}"; do
  dir="$ROOT/$repo"
  echo "== $repo"
  [[ -d "$dir/.git" ]] || { echo "   not cloned, run scripts/bootstrap.sh" >&2; exit 1; }
  if [[ -n "$(git -C "$dir" status --porcelain)" ]]; then
    echo "   has uncommitted changes, skipped" >&2
    continue
  fi

  git -C "$dir" fetch --quiet origin dev
  git -C "$dir" switch --quiet -C "$BRANCH" origin/dev

  for line in "${skills[@]}"; do
    read -r source skill <<<"$line"
    (cd "$dir" && npx --yes skills add "$source" --skill "$skill" --agent claude-code codex --yes >/dev/null)
    echo "   skill $skill"
  done

  # Copilot reads .github/skills. A repository with its own mirroring script (the
  # Backend's agents:sync, see its ADR 0014) keeps the mirror itself; otherwise copy.
  if grep -q '"agents:sync"' "$dir/package.json" 2>/dev/null; then
    (cd "$dir" && npm run --silent agents:sync >/dev/null)
  elif [[ -d "$dir/.github/skills" ]]; then
    for line in "${skills[@]}"; do
      read -r _ skill <<<"$line"
      rm -rf "$dir/.github/skills/$skill"
      cp -R "$dir/.agents/skills/$skill" "$dir/.github/skills/$skill"
    done
  fi

  mkdir -p "$dir/docs/agents"
  cp "$ROOT/shared/agents/workspace.md" "$dir/docs/agents/workspace.md"

  git -C "$dir" add -A
  if git -C "$dir" diff --cached --quiet; then
    echo "   already in sync"
    git -C "$dir" switch --quiet -
    git -C "$dir" branch --quiet -D "$BRANCH"
  else
    git -C "$dir" commit --quiet -m "$MESSAGE"
    echo "   committed on $BRANCH, push it and open a PR into dev"
  fi
done
