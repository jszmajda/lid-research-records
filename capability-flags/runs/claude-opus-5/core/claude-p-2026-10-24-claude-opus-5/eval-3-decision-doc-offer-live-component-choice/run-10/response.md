Phase 2 complete — `record-store` LLD revised around whole-visit revisions. Stopping for your review.

## What the LLD now says (`docs/intent/record-store/record-store-design.md`)

**Revision model.** A visit is an append-only chain of revisions, each a complete field set with author and receipt time. A *field revision* names the `base` it was edited from; a *resolution revision* names the set it `supersedes`. Revisions not superseded are **live**. One live revision ⇒ that is the **current revision** and the visit is **resolved**; two or more ⇒ **competing revisions** and the visit is **unresolved**, with no current revision and a **last agreed revision** alongside.

**Submission** carries visit ID, base revision ID, complete field set, idempotency key. Four outcomes: **create**, **advance** (base is current — the ordinary path, no review work), **compete** (base superseded, or visit already unresolved), **reject** (duplicate create, unknown base, validation/auth failure, idempotency-key reuse with a different payload). A stale base is explicitly never grounds for rejection — the 48-hour offline window makes it normal, and rejecting would discard recorded observations. Editing an unresolved visit is allowed against any revision, so pending office work never blocks field capture.

**Retrieval** returns either the current revision + resolved state, or the unresolved state with the full competing revisions and the last agreed revision — never a provisional current, so nothing downstream can mistake one branch for agreement.

**Resolution.** A coordinator submits a complete field set plus the competing revision IDs it supersedes (may reproduce one verbatim or carry a corrected combination); stored with coordinator identity and superseded IDs. It must enumerate *every* live revision — a set made incomplete by a worker submitting mid-comparison is rejected as stale. Resolution is not terminal: a later submission off a pre-resolution revision re-opens the visit.

Seven Decisions & Alternatives rows, including the concurrency choice itself with field-aware merge and last-write-wins as the named alternatives. Downstream contract work is recorded as cascade notes to tablet-sync and review-export, not as work owned here.

**Upstream coherence edits to `docs/high-level-design.md`:** record-store's State is now "Drafted", and the paragraph that said the two downstream designs "must wait for its contract" now says they are designed against it. No architecture change.

## Edge-case probe (delegated, read only the LLD + HLD; gaps surfaced, not resolved)

Ten gaps came back. My recommended triage — tell me where you disagree:

**Fix in the LLD now (they change the contract tablet-sync and review-export will be built against):**
1. **Resolutions have no idempotency key.** A resolution that applies but loses its response retries as a now-incomplete set and is rejected as stale — indistinguishable from a real race.
2. **Ancestry across a resolution is undefined,** so "last agreed revision" isn't computable in the re-opened case: does `supersedes` count as ancestry, or only `base`? The two give different review views of the same visit.
3. **No atomicity/serialization rule** for outcome determination — as written, two simultaneous submissions off the same current revision could both be classified *advance*.
4. **"Compete" is overloaded:** extending one branch of an already-unresolved visit adds no new competition, but the literal rule reports *compete*, which tablet-sync would show as needing coordinator attention for routine follow-up work.
5. **Resolution's rejection shapes are unnamed** — stale isn't one of the four submission outcomes, "coordinator" is never defined as a role this node checks, and a named set with unknown/duplicate/already-superseded IDs has no stated outcome.

**Probably fix, lower cost:** idempotent-replay return value (replay the original outcome vs. recompute — recomputing can report *compete* for an edit that advanced cleanly) and the key's scope/lifetime; whether a resolution is validated like a submission and whether it may change the plot reference or observation date.

**Defer:** whether a resolution may be applied to an already-*resolved* visit (i.e. how coordinators correct an uncontested visit) — that may belong to review-export's design; retrieval details for an unknown visit ID and the ordering of competing revisions.

## Two things I need from you

1. **Recording the concurrency choice.** It's captured as a Decisions row now. This one would stay live for a cold reader — two credible options traded against review volume, implementation burden, and silent-combination risk, with two nodes about to be sized around the result — so I can instead write it up as a decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and link it from the row. Row only, or row plus doc?
2. **A sibling-segment line.** `site-catalog-design.md` ends with "Tablet-sync's visit submission and reconciliation behavior remains pending that choice," which is now stale. That's across a segment boundary, so I haven't touched it — want me to update it?

On your approval of the LLD (with whichever gaps you want folded in), Phase 3 updates `record-store-specs.md`: REC-004/005/006 get retextured off their policy-agnostic wording, plus new REC specs for the four outcomes, the two retrieval shapes, and resolution with its stale-set rejection. IDs stay stable.