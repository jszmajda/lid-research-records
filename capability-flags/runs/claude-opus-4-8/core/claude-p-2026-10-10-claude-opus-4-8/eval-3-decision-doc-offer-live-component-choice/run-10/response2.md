Decision doc written and linked. It's at `docs/intent/record-store/decisions/concurrency-granularity.md`, built to be re-run cold: context, weighted criteria (naming the *no-inference-of-scientific-intent* non-goal and the *two-coordinator operability* tenet the choice turns on), both options in their strongest honest form, and a Selection that states plainly what's given up (review workload) and **the condition under which field-aware merge should be reconsidered** — an unsustainable queue, adopted with provenance and mandatory approval. The LLD row now points to it.

The downstream obligations are recorded in the doc's Selection section:
- **tablet-sync** — retain and send base revision IDs, keep whole visits, show pending competing revisions, and define which base to name once a held visit has forked.
- **review-export** — a revision-comparison view, coordinator designate/author of the winner with provenance, and holding unresolved visits out of the CSV.

We're still at the **Phase 2 stop** — two things from my last message are still open and are yours to decide, not mine:

**1. Edge-probe triage.** For each group, tell me *fix in the LLD now* vs. *park in Open Questions*. I'd treat the first three as load-bearing:
1. **Revision lifecycle while unresolved** — submission based on a *competing* revision; whether submissions are accepted at all while unresolved.
2. **Resolution operation semantics** — winner not in the competing set; what `contributingRevisionIds` must be; resolving an unforked/already-resolved visit; two coordinators resolving at once; whether a reconciled revision is validated and appears in history.
3. **Submission validation & lineage** — unknown `baseRevisionId`, a base from a different visit, a no-base submission for a visit that already has revisions.
4. **Idempotency semantics** — key uniqueness scope; whether the payload-match includes `baseRevisionId`/`plotId`; stale resulting-state on replay.
5. **Error shapes** — not-found / invalid-input behavior for retrieval, history, and resolution.

**2. The HLD State cell** still says *"Drafted; concurrency choice open."* Update it (e.g. to "Designed") as part of this, or leave the HLD untouched?

Once you've triaged and answered the HLD question, I'll fold the chosen fixes into the LLD and then move to **Phase 3 — EARS specs**.