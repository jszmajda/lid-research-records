Record-store design is drafted against whole-visit revisions. No code or tests exist in this repo, so this stop covers the intent rungs only.

**What changed**
- `docs/high-level-design.md` — record-store marked drafted; architecture now states the whole-visit revision contract and its downstream dependencies.
- `docs/intent/record-store/record-store-design.md` — completed: revision tree, immutable revisions with server-assigned IDs, frozen head during review, branch-tip competing set, coordinator resolution, retrieval/current-state/history contracts, downstream notes.
- `docs/intent/record-store/record-store-specs.md` — REC-001–006 revised (IDs stable), REC-007–019 added.

**LLD edge-case probe (triage these)**
Resolved in the draft: missing base on an existing visit (reject), base from another visit (reject), resolving an already-resolved visit (reject), concurrent submit/resolve race (per-visit serialization), in-branch pending revisions (show branch tips only). Deferred: resolution note field, revision retention beyond release one, pending branch depth/count limits. Say if any should be decided now rather than deferred.

**Phase 3 consistency report**
- Coverage: every behavior in the LLD has a REC spec; no orphan specs.
- Contradiction: none found; REC-007 (linear advance) and REC-011 (frozen while unresolved) are explicitly scoped to disjoint conditions.
- Implicit scoping: REC-011 and REC-014 carry their unresolved-visit scope in the clause rather than relying on section context.
- Context-free reading: each line stands alone under grep.

**Rulings I need before Phase 4**
1. Resolution semantics — I chose "coordinator selects one retained revision" (including selecting the current head to dismiss competitors), not "coordinator authors a combined revision." Confirm or redirect; this is the one call that would change the LLD and specs most.
2. Competing set — I chose to present only the tips of pending branches, not every pending revision. Confirm or redirect.
3. The concurrency choice itself (whole-visit vs field-aware merge) will stay live for a cold reader and sizes tablet-sync and review-export. Do you want it recorded as a full decision doc in `docs/intent/record-store/decisions/`, or is the Decisions table row enough?

Approve the design and specs (or give numbered feedback), and I'll run the intent-narrowing edge audit for the record-store segment. Tablet-sync and review-export remain untouched until after that.