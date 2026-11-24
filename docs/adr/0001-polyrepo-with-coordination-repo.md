# Keep three repositories and coordinate them from a thin workspace repository

The Backend, CMS and Storefront stay in their own repositories with their own CI, branch rules and PR checks. This repository only holds what spans them: tool versions, the local run setup, the shared agent guidance and the list of shared skills. It never contains their code: the three checkouts sit beside it and are ignored by git, with no submodules. A monorepo (Turborepo or Nx) was rejected for now. It would mean merging npm and pnpm, three CI setups and three PR policies in the middle of the Backend architecture migration, and the three applications already meet at one narrow point: the API Contract.

## Considered Options

- **Monorepo**: the strongest cross-repo control, but the migration cost lands now and the benefit only arrives once the applications share code, which they do not.
- **Git submodules**: pin each repository to a commit, which this workspace does not need, and make every pull and branch switch heavier.
- **Thin coordination repository (chosen)**: each repository still clones, builds and ships on its own.

## Consequences

- Shared files are copied into each repository by `scripts/sync.sh` and land through that repository's normal PR, so a repository never depends on this one at build time.
- Rules that differ on purpose (commitlint scopes, PR body templates, the Backend's AI-attribution check) stay in each repository and are not synced.
