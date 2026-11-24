# Fashion Store workspace: agent instructions

This is the coordination repository for three separate application repositories. Read [GLOSSARY.md](GLOSSARY.md) for the names used here and [docs/adr/](docs/adr/) for why the workspace is shaped this way.

## Layout

| Application | Folder (its own git repository) | Stack | Package manager | Local port |
|---|---|---|---|---|
| Backend | `be-demo/` | NestJS, Prisma, PostgreSQL, Redis | npm | 8080 |
| CMS | `cms/` | Vue, Vite, Nuxt UI | npm | 3001 |
| Storefront | `fe-ecommerce-nike-style/` | Next.js | pnpm | 3000 |

- This repository never contains application code. The three folders are ignored here. Commit application changes inside the application's own repository.
- Each application repository has its own `AGENTS.md` / `CLAUDE.md`, commit rules and PR template. **Once you work inside an application folder, its rules win over this file.**
- Every application PR targets `dev` and merges with a squash.
- The Backend rejects commit messages that name AI tools or carry AI attribution lines. Write "every agent" instead of a tool name.

## Running locally

- `mise install`: pinned tools (Node, pnpm, mani, mprocs). Each application still uses its own `.nvmrc`.
- `mprocs`: starts Redis and Mailpit (`docker compose`) and all three applications.
- PostgreSQL runs natively on the machine, not in Docker. Do not start `be-demo/docker-compose.yml` alongside this workspace's compose file: both bind Redis on 6379.
- Mailpit shows every email the Backend sends: http://localhost:8025.

## Working across repositories

- `mani run status --all`, `mani run pull --all`, `mani run dev --all` (see `mani.yaml`).
- Before a change that touches more than one application, check every affected repository is clean (`mani run status --all`), and give each one its own branch and PR.
- The API Contract flow (Contract Versions, Breaking Changes, merge order for a feature that spans the Backend and a consumer) is in [shared/agents/workspace.md](shared/agents/workspace.md). Follow it exactly.

## Shared files

- `shared/skills.txt` lists the skills every repository gets. `shared/agents/workspace.md` is copied to `docs/agents/workspace.md` in each repository.
- To change them, edit this repository, then run `scripts/sync.sh`. It commits on `chore/shared-sync` in each repository without pushing. Then open one PR per repository using that repository's template.
- Commitlint configs and PR templates differ on purpose between the repositories and are **not** synced.
