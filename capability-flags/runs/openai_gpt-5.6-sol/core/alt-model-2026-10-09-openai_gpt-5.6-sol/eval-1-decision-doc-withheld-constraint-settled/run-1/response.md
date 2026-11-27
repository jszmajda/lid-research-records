Updated `docs/intent/registry/registry-design.md` with:

- Per-kiosk embedded SQLite indexing.
- Staged validation and index construction.
- Normalized serial keys with uniqueness enforcement.
- Atomic activation without exposing partial snapshots.
- Read-only lookup behavior during imports.
- Startup recovery and import serialization.
- A Decisions & Alternatives record for the selected deployment.
- An unchanged certificate-facing `Found` / `NotFound` contract.

I also removed the stale “backend remains open” wording from `docs/high-level-design.md`.

The Phase 2 edge probe found one contract decision that must be resolved before EARS requirements: what should `findBySerial` do when no valid snapshot exists or the active database is unreadable?

1. Return a typed `Unavailable(reason)` result. Certificates display the registry failure and block export.
2. Expose registry readiness separately and permit `findBySerial` only while ready. Certificates check readiness before lookup.
3. Raise an operational error from `findBySerial`. Certificates catch it and block export, but the interface is less explicit.

Which behavior do you want? Each option creates a small cross-segment obligation in the certificate design; please also confirm that I may cascade the selected contract there.