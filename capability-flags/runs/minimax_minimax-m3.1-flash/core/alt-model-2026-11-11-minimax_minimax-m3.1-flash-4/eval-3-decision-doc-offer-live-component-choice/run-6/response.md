**Phase 2 — Record Store LLD rewritten for whole-visit revisions.** `docs/high-level-design.md` now records the settled choice; `docs/intent/record-store/record-store-design.md` is a complete design: revision/visit/resolution data model, the concurrency rules, validation table, four operations (submit, current-state, history, list review work, resolve) with field-level envelopes, error reasons with retryability, export-eligibility signal, and the tablet-sync / review-export contract handoff.

Key mechanics: every submission carries a base revision and a complete visit; a submission based on the current revision with no open candidates becomes current; anything else becomes a `pending-review` candidate and freezes the current revision; resolution selects at most one candidate (or dismisses all) and never authors a merged revision; revisions are immutable and retained; idempotency is author-scoped across key + visit + base + payload.

**Three judgment calls I made in the draft — please confirm or overrule:**
1. **Base eligibility** — a base may be the current or a closed revision, never a candidate. Alternative: allow branching from a candidate.
2. **Two first submissions of the same visit arriving together** — server processing order opens the visit, the second becomes a candidate. Alternative: decide by a deterministic key so the opening revision is order-independent.
3. **Comparison basis for review** — candidates are compared against the visit's frozen current revision; a candidate's own base is shown as provenance. Alternative: compare each candidate against its own base.

**Deferred to later:** whether resolutions carry a written note (and who sees it), and whether tablets receive candidate payloads or only candidate metadata.

**Two things I'd like your call on:**
- Should the whole-visit-vs-merge choice get a standalone decision doc (context, criteria, options), or is the Decisions & Alternatives row in the LLD enough?
- A wrong first submission (right visit, wrong plot) can only be corrected by a later revision, since this node has no deletion path. Acceptable, or do you want a deletion/correction route in the record store?

Next, on your approval, is Phase 3 — rewriting `record-store-specs.md` (REC-001…006 currently under-specify the new policy) and the Phase 4 edge audit.