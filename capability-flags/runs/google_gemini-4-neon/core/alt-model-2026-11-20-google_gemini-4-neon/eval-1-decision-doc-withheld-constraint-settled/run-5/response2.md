Overkill — the row in `registry-design.md`'s **Decisions & Alternatives** table is the right level here.

A decision doc earns its place when a cold reader of the *landed* design would still see a live tradeoff and re-litigate it (not because the deliberation took back-and-forth). Here, once landed, the choice is settled:

1. **Inherited HLD constraints eliminate the alternatives** — the HLD tenets and non-goals prohibit runtime network access, remote access, and cloud services on kiosks, ruling out both the on-site HTTPS directory and the managed search service.
2. **It affects only `registry`** — `certificates` consumes only `findBySerial(serial)` and its fixed result types, so no other node is sized around the backend.

One table row gives a future reader everything they need to see why local SQLite was chosen without adding a standalone doc.

Whenever you're ready, let me know any edits to `registry-design.md` and how you'd like to triage the 7 edge-case items above before we move to Phase 3 (EARS specs).