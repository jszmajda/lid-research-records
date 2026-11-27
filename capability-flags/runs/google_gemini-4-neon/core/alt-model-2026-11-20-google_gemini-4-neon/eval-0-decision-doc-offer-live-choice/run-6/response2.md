Created `docs/decisions/change-delivery.md` and linked it from `## Key Design Decisions` in `docs/high-level-design.md`.

### Summary of `docs/decisions/change-delivery.md`
- **Owner:** `high-level-design`
- **Decision Elements (weighted):**
  - *Update latency beyond the 15-second floor* (**major**)
  - *Vendor independence and recurring cost* (**major**)
  - *Operational and implementation complexity* (**moderate**)
  - *Failure visibility and authoritative revision alignment* (**moderate**, grounded in the authoritative-revision and visible-connectivity-failure tenets)
  - *Read-path efficiency under steady load* (**minor**)
- **Options analyzed:** Five-Second HTTPS Polling, Self-Hosted WebSockets, and Hosted Realtime Service — each with description, per-criterion `strong`/`partial`/`weak` fit verdicts, and trade summary.
- **Selection:** Self-hosted WebSockets wins on both major criteria and steady-state read efficiency while explicitly accepting a `weak` fit on operational and implementation complexity, and spells out the downstream obligations for `change-store`, `delivery`, and `browser-sync`.

Please review `docs/decisions/change-delivery.md` and the HLD link:
1. Do the criteria, option analyses, and selection rationale accurately capture the trade-off, or would you like any adjustments?
2. Once approved, should I tidy the `"still-open change-delivery approach"` wording in `docs/intent/access/access-design.md` and then start Phase 2 with `change-store`?