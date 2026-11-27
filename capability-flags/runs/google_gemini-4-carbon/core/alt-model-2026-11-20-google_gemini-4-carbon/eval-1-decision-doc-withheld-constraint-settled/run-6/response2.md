It would be overkill — the row already in `registry-design.md` under `Decisions & Alternatives` is the right level of record.

Judging from the landed design rather than how much back-and-forth it took to get here, a standalone decision doc only earns its place when multiple options remain genuinely live for a future cold reader and other components are shaped around the outcome. Here, three things make a table row sufficient:

1. **An inherited HLD constraint eliminates two of the three options**: `docs/high-level-design.md` forbids runtime network access on kiosks (no network route during operation; remote/cloud services are explicit non-goals), which rules out both the on-site HTTPS directory and the managed search service outright.
2. **The remaining local trade is one-line clear**: against scanning up to 150 MB / 90,000 NDJSON records directly, a local SQLite primary-key index meets the 250 ms lookup and 4 GB RAM targets with no separate service process, at the cost of building the index during USB import.
3. **The impact stays strictly inside `registry`**: `certificates` still calls `findBySerial(serial)` and receives the exact same result type, so no sibling node leans on this decision.

Leaving it as that single `Decisions & Alternatives` row gives a cold reader the "why SQLite?" rationale without maintaining an extra doc. (If you still want a standalone doc under `docs/intent/registry/decisions/` anyway, say the word and I'll draft one.)

Whenever you're ready, let me know any edits to `registry-design.md` and how you'd like to triage the Phase 2 edge-case items (1–8) before we move to Phase 3 (`registry-specs.md`).