The decision doc is written and linked from the LLD's Decisions row:

**`docs/intent/record-store/decisions/concurrency-policy.md`**
- **Context** — why the policy decides the shape of submission, review, and export; the two invariants both options honor (nothing discarded, arrival order ≠ authority).
- **Decision Elements** — five weighted criteria, each tied to its tenet: safety against silently combining coupled edits (*major*), review workload, maintenance burden, inspectability (*moderate*), footprint (*minor*).
- **Options** — whole-visit and field-aware merge, each with a worked demonstration and a verdict per criterion. Field-aware gets its strongest honest case: it genuinely wins on review workload.
- **Selection** — whole-visit wins on the one major criterion, taken knowingly *against* the low-workload lean. It states **why field-aware stays on the table**: the concrete conditions that would flip it (an unsustainable queue driving rubber-stamping) and the documented fallback (auto-combine only reliably-independent fields like observer-name fixes). And **what it obligates downstream** — tablet-sync (retain + send base revision ID, resend whole payload, surface "went unresolved" to the worker) and review-export (compare competing revisions, call resolve with selected+competing IDs, hold unresolved visits out of the CSV, carry resolution provenance).

That covers both things you asked for. **Phase 2 is still at its stop** — two things remain before I move to Phase 3 (EARS):

- **Edge-probe triage (the 10 gaps).** Which do you want pinned in the LLD now vs. deferred? Several are genuinely your call — especially #4 (is the idempotency key scoped to the whole envelope incl. base revision, or just the payload?), #6 (the fast-forward serialization point), #7 (two different authors submit identical payloads — collapse or review?), and #9 (a base-absent "initial" submission arriving for a visit that already has revisions). I won't resolve those for you.
- **LLD approval** — as-is, or with whichever edge resolutions you give me.

Once you settle those, I'll fold them in, then move to Phase 3 (reconcile REC-001…006 and add specs for base-revision / fast-forward / conflict / resolution) with its own stop. tablet-sync and review-export stay deferred as you asked, and I'll update the HLD's stale status cell on your approval.