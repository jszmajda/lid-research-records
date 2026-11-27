## Phase 1: HLD Review

Updated `docs/high-level-design.md` to select the local embedded SQLite index:

- Each kiosk validates signed USB snapshots and builds its own local SQLite lookup index.
- Registry owns validation, index construction, and lookup.
- Certificate lookup interface remains unchanged.
- The decision records the rejected HTTPS-directory and managed-search alternatives and their operational trade-offs.

Please review and approve this HLD update before I draft the registry’s detailed design.

One tenet needs your judgment: should the HLD add **“Kiosk autonomy over centralized operational convenience”** as a tie-breaker for future design choices, or should the existing offline/USB constraints remain sufficient?