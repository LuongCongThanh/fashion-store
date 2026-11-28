# Keep the full-stack E2E suite in the workspace repository

The full-stack journeys (`docs/testing/critical-journeys.md`) run the Storefront or the CMS against a real Backend, PostgreSQL, Redis and signed provider stubs. They live in an `e2e/` folder of this repository: a Playwright project, its start-up script and the fixtures that create test data through the Backend API. This is a narrow exception to ADR 0001, which keeps application code out of this repository. The suite tests how the applications work together, so no single application repository owns it, and it needs the same three checkouts side by side that this repository already assumes. It never imports application source: it talks to the running applications over HTTP and the browser only.

## Considered Options

- **Suite in the Backend repository**: the Backend owns the data and the rules, but every journey also needs a Storefront or CMS build, and a Storefront-only change would then need a Backend PR to adjust its journey.
- **Suite in each frontend repository**: J5, J7 and J9 run through the CMS and J1–J4 through the Storefront, so the stubs, fixtures and start-up would be duplicated and drift.
- **Suite in this repository (chosen)**: one place for the journeys and fixtures; each application keeps its own mocked browser tests.

## Consequences

- `e2e/` gets its own `package.json` and lockfile; its dependencies are tools only (Playwright), never an application package.
- The suite runs nightly from this repository's CI, checking out the three applications at the branches under test.
- The VNPay, MoMo and GHN stubs live in the Backend repository as a test-only tool, because the Backend's own API tests use them too and they must sign with the Backend's real signing code. The suite starts them through a Backend npm script, so this repository never copies or imports Backend code.
