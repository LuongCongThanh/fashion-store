# Version the API Contract automatically and let Renovate carry it to the CMS and Storefront

When a push to the Backend's `dev` branch changes `docs/openapi/openapi.json`, CI compares it with the latest Contract Version using `oasdiff`. A Breaking Change bumps the minor number (0.7.0 → 0.8.0, since the contract is still below 1.0); anything else bumps the patch number. The same workflow tags `openapi-vX.Y.Z` and publishes the release. Renovate in the CMS and Storefront watches those tags and opens a PR that moves the pinned Contract Version. Patch bumps merge on green CI; minor bumps wait for review under the `breaking-contract` label.

## Considered Options

- **Manual tagging**: a person decides each version. This gives exact semver judgement, but releases get forgotten. The CMS (0.7.0) and the Storefront (0.5.0) had already drifted apart this way.
- **Backend pushes PRs into the other repositories (`repository_dispatch`)**: this needs a personal access token stored in the Backend and custom workflows in three places.
- **oasdiff + Renovate (chosen)**: a machine detects Breaking Changes, and the consumers pull changes on their own schedule without sharing a secret.

## Consequences

- Tags come from `dev`, not `main`, because every PR lands on `dev` and nothing is deployed yet. Revisit this when deployment starts.
- A tag pushed with `GITHUB_TOKEN` does not trigger other workflows, so the release step must run inside the tagging workflow (the existing `openapi-release.yml` becomes a reusable workflow).
- The Contract Version is not the Backend's URI version (`/api/v1`): a Breaking Change bumps the Contract Version without creating `/v2`.
- Each consumer must pin its Contract Version in a committed file (the CMS used to read it from an uncommitted `.env.local`).
