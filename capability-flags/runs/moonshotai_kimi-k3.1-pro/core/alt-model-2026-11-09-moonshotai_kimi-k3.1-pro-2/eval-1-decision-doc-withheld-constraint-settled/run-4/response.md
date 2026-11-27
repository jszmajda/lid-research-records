## Phase 1 — HLD review

Updated `docs/high-level-design.md` to select the local SQLite backend:

### Architecture

- **Registry:** Owns snapshot validation, a private embedded SQLite index, and serial-number lookup.
- **Certificates:** Uses the fixed registry result type and writes PDFs to a user-selected local directory.

### Key Design Decision: Local embedded SQLite registry index

Each kiosk builds and queries its own SQLite index from validated registry snapshots. This provides predictable lookups without a running service or runtime network access.

The on-site HTTPS directory and managed search service were rejected because both require connectivity unavailable to the kiosks. The managed service would also add recurring cost and credential management without a current need for richer search.

Snapshot validation and index rebuilding remain private registry concerns. The certificate-facing lookup result remains independent of the storage backend.

No separate decision document is needed because the existing kiosk-isolation constraint decisively favors the local option.

**Please approve this HLD update so I can proceed to Phase 2 and draft the registry LLD.**