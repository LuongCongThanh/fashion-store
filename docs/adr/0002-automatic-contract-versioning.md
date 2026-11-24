# Version the API Contract automatically and let each consumer pull it in

When a push to the Backend's `dev` branch changes `docs/openapi/openapi.json`, CI compares it with the latest Contract Version using `oasdiff`. A Breaking Change bumps the minor number (0.7.0 → 0.8.0, since the contract is still below 1.0); anything else bumps the patch number. The same workflow tags `openapi-vX.Y.Z` and publishes the release. A workflow in the CMS and in the Storefront (`contract-bump.yml`) checks those tags every day, moves the pinned Contract Version, regenerates the API types and opens a PR. Patch bumps merge on green CI; minor bumps wait for review under the `breaking-contract` label.

## Considered Options

- **Manual tagging**: a person decides each version. This gives exact semver judgement, but releases get forgotten. The CMS (0.7.0) and the Storefront (0.5.0) had already drifted apart this way.
- **Backend pushes PRs into the other repositories (`repository_dispatch`)**: this needs a personal access token stored in the Backend and custom workflows in three places.
- **oasdiff + Renovate**: rejected after the first attempt. The hosted Renovate app only edits the pinned tag; it cannot run the type generator, so every bump PR fails the contract check and nothing merges on its own.
- **oasdiff + a bump workflow in each consumer (chosen)**: a machine detects Breaking Changes, and each consumer pulls changes on its own schedule and regenerates its types in the same PR. The Backend holds no secret about the consumers.

## Consequences

- Tags come from `dev`, not `main`, because every PR lands on `dev` and nothing is deployed yet. Revisit this when deployment starts.
- A tag pushed with `GITHUB_TOKEN` does not trigger other workflows, so the release step must run inside the tagging workflow (the existing `openapi-release.yml` becomes a reusable workflow).
- The Contract Version is not the Backend's URI version (`/api/v1`): a Breaking Change bumps the Contract Version without creating `/v2`.
- Each consumer must pin its Contract Version in a committed file (the CMS uses `.env.development`).
- Each consumer stores a fine-grained personal access token (`CONTRACT_BUMP_TOKEN`, that repository only, Contents and Pull requests read/write). A PR opened with `GITHUB_TOKEN` would not trigger CI. Without the secret, the workflow skips.
- Only one bump PR is open per consumer at a time, so a patch never lands on top of an unfixed Breaking Change.
