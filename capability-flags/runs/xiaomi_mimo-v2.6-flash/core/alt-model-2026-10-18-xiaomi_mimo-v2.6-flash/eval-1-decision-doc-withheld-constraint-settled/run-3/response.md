**Phase 1 — HLD check (resuming after your selection)**

The HLD already covers the change domain; the selection of the local embedded SQLite index makes one stale line in the HLD. I updated it:

`docs/high-level-design.md` — Architecture section, Registry bullet:

> Registry: `docs/intent/registry/registry-design.md`, with `docs/intent/registry/registry-specs.md`. Owns snapshot validation and lookup. **Its private lookup backend is a local embedded SQLite index on the kiosk.** (was: "Its private lookup backend remains open.")

No other HLD section changes: the tenets (local-files-only lookup, no runtime network) already match this choice, and no tenet elicitation is needed. The choice itself will be recorded as a Decisions & Alternatives row in the registry LLD in Phase 2 — a full decision doc isn't warranted, since the HLD's no-network tenet settles it for a cold reader.

Note on scope: after this stop, the remaining work is Phase 2 (finish the registry LLD around SQLite: index build, activation, query path + edge-case probe), Phase 3 (EARS updates + consistency report), Phase 4 (edge audit), then tests/code phases if and when implementation begins.

Approve this HLD change, or give numbered feedback to revise it, and I'll proceed to Phase 2.