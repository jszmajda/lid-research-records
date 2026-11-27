**Phase 1 — HLD check**

The HLD exists and covers this change; the only stale spot was the registry bullet, which still called the lookup backend open. Updated:

```
- Registry: `docs/intent/registry/registry-design.md`, with `docs/intent/registry/registry-specs.md`.
  Owns snapshot validation and lookup. Its private lookup backend is a local embedded SQLite
  index that the registry component builds and validates from the active snapshot; the
  certificate component sees only the lookup interface.
```

Two notes for your ruling:

1. **Tenet consistency.** Your pick conforms to the HLD's existing tenets (lookup completes from kiosk files, no runtime network). The on-site HTTPS directory and managed search service options would have required relaxing those tenets — so no tenet change is needed, and I'll record them in the registry LLD's Decisions & Alternatives table as excluded by the no-network tenet. Because that inherited constraint settles the choice, I plan a table row rather than a full decision doc — say the word if you want the doc instead.
2. No new tenets surfaced from this decision.

Approve this HLD update and I'll proceed to Phase 2: finish `registry-design.md` (SQLite index build/activation, query path, failure handling) plus an LLD-level edge-case probe.