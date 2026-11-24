#!/usr/bin/env bash
# Prepare a machine for the Fashion Store workspace. Safe to run again.
#   1. install pinned tools (mise)   2. clone missing repositories (mani)
#   3. install dependencies           4. create local env files that do not exist yet
set -euo pipefail
cd "$(dirname "$0")/.."

command -v mise >/dev/null || { echo "mise is missing: https://mise.jdx.dev/getting-started.html" >&2; exit 1; }
mise install
mise exec -- mani sync

copy_if_missing() { # <repo> <example> <target>
  if [[ -f "$1/$2" && ! -f "$1/$3" ]]; then cp "$1/$2" "$1/$3"; echo "created $1/$3"; fi
}
copy_if_missing be-demo .env.example .env
copy_if_missing cms .env.example .env.local
copy_if_missing fe-ecommerce-nike-style .env.example .env.local

(cd be-demo && mise exec -- npm ci)
(cd cms && mise exec -- npm ci)
(cd fe-ecommerce-nike-style && mise exec -- pnpm install --frozen-lockfile)

cat <<'MSG'

Done. Next:
  - Create the Backend database once (see README, "PostgreSQL").
  - Run `mprocs` to start everything.
MSG
