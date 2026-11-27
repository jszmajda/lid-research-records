## Phase 1 — HLD check

The existing HLD already requires offline lookup, USB-only updates, and preservation of the last valid snapshot. The local SQLite index is consistent with those constraints, and the certificate interface remains unchanged.

I updated `docs/high-level-design.md` → **Architecture** to record the selection:

> - Registry: `docs/intent/registry/registry-design.md`, with `docs/intent/registry/registry-specs.md`. Owns snapshot validation, preparation of a private local SQLite index, and lookup.

No other HLD changes are needed. Do you approve this update so I can proceed to complete the registry LLD?