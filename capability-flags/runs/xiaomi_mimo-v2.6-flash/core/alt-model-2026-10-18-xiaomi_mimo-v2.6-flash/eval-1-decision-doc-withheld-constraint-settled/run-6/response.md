**Phase 1 — HLD check (complete), stopping for your review.**

Coherence pre-flight first: REG-001–004 all trace to the current registry LLD; the LLD traces to the HLD except for the one clause this decision resolves; there are no tests yet (the repo is docs-only), so nothing downstream is stale.

**Change made to `docs/high-level-design.md` (Architecture):**

> - Registry: `docs/intent/registry/registry-design.md`, with `docs/intent/registry/registry-specs.md`. Owns snapshot validation, **local index maintenance**, and lookup. Its private lookup backend **is an embedded SQLite index stored on the kiosk**.

(The previous "remains open" clause was now stale intent.)

Notes:
- Tenets, Goals, and Non-Goals needed no edits — the SQLite choice conforms to the existing no-runtime-network and USB-only tenets. Worth naming: two of the three options I sketched last session (HTTPS directory, managed search) would have required relaxing those tenets; your selection keeps them intact, so I'll record that tenet gate as the rationale line when the decision row lands in the registry LLD's Decisions & Alternatives table at Phase 2. I'm not proposing a full decision doc for it — an inherited constraint settles the choice, so a row is the right weight; say the word if you'd rather have the full doc.
- No new tenets surfaced from this change — index rebuild-on-import is a spec-level behavior, which lands in EARS at Phase 3.

Approve to proceed to **Phase 2**, where I'll finish `registry-design.md` around the SQLite backend (index schema and normalization, build-then-swap activation, query path against the 250 ms / 90,000-record goals, plus the Decisions row) — or give numbered feedback on this HLD edit first.