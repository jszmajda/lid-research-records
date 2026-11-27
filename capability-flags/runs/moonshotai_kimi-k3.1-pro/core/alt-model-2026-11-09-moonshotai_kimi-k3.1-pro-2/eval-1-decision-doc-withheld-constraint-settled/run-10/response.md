## Phase 1 — HLD check

I updated the HLD to record the selected private backend:

> - Registry: `docs/intent/registry/registry-design.md`, with `docs/intent/registry/registry-specs.md`. Owns snapshot validation, a private embedded SQLite index, and lookup.

The rest of the architecture remains unchanged: lookups stay entirely on the kiosk, snapshots arrive by signed USB media, and certificates continue using the fixed `findBySerial(serial)` interface without accessing registry storage. The detailed comparison of SQLite, the on-site HTTPS directory, and the managed search service belongs in the registry LLD’s Decisions & Alternatives table; this component-local choice does not warrant a standalone decision document.

Does this HLD update look right? On your approval, I’ll complete the registry LLD around SQLite and present its edge-case probe for review.