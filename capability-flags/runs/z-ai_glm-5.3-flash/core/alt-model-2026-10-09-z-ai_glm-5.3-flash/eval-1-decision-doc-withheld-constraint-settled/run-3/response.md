Done — the registry LLD is finalized around the SQLite choice, and the HLD's "backend remains open" reference is updated to match. Per the workflow this is the **Phase 2 stop**: the LLD change is presented for your review before I cascade to the EARS specs.

**What changed**

- `docs/intent/registry/registry-design.md` — backend settled as a local embedded SQLite index: each kiosk builds its own index from every validated snapshot; lookup is a single indexed equality query on a normalized-serial column (250 ms goal at 90k records); index carries snapshot-date/schema metadata so even NotFound reports the snapshot date; activation is a build-beside-then-atomic-swap, so any import failure or crash leaves the last valid index active; missing/corrupt index rebuilds from the stored snapshot. A Decisions & Alternatives row records the three-way choice with rationale.
- `docs/high-level-design.md:13` — one-line coherence fix: registry now "owns snapshot validation, per-kiosk index building, and lookup over a local embedded SQLite index" (the choice stays private to the registry segment; the certificate interface is untouched).

**LLD edge-case probe** (delegated blind reader; please triage — which do I fold into the LLD now, which defer?)

1. A second snapshot import begins while the first build is still in progress.
2. Two records differ only in case/whitespace (normalize to the same serial) but uniqueness was checked on raw serials.
3. Signature verifies but the index build fails midway — which snapshot is reported active, and is the partial build file cleaned up?
4. The stored snapshot file itself is missing/unreadable at lookup time, not just the index.
5. Rebuild-from-snapshot triggered — is the signature re-verified or trusted from the original import?
6. Empty, over-long, or non-ASCII serial input at the normalization step.
7. Index metadata (snapshot date) absent or mismatched vs. the stored snapshot.
8. A lookup racing the atomic swap — which snapshot date does it report?

My quick read: 2, 3, and 6 look like genuine gaps worth closing in the LLD now; 1, 5, 8 have defensible defaults I can pin down in one sentence each; 4 and 7 are smaller and could defer to implementation testing.

**Two things before I proceed:**

1. Does the finalized LLD read right to you — anything to change before I cascade it into EARS spec updates (Phase 3)?
2. This backend choice was genuinely contested (three credible options, multiple criteria, and kiosk design sized around it), so it would stay live for a cold reader. Want it recorded as a full decision doc in `docs/intent/registry/decisions/`, or is the Decisions & Alternatives row I've added enough?