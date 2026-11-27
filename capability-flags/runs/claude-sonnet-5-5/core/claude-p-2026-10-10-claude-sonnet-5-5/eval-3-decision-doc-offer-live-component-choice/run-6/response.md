Whole-visit revisions are now drafted into the record-store design. This is the Phase 2 stop, so nothing downstream has been touched: no EARS specs, tests, or code.

## What changed

**`docs/high-level-design.md`**
- The record-store state now reads "Drafted; whole-visit revisions".
- The "must wait for its contract" paragraph now says record-store owns the concurrency mechanism. Tablet-sync and review-export link to its contract.
- The tenets, goals, and architecture are unchanged.

**`docs/intent/record-store/record-store-design.md`** (full rewrite, with the OPEN section replaced)
- **Revisions:** each accepted submission is a complete, immutable visit payload that names its base revision. A *head* is a revision that no other revision names as a base.
- **Settled vs. unresolved:** one head means settled and is the current state. More than one head means unresolved, and no head is authoritative. A late edit based on an old revision becomes an extra head, so it is reviewed rather than overwriting.
- **Submission and retrieval:** the envelope is the idempotency key, visit ID, base revision ID, and complete payload.
  - Acceptance never fails because of a competing edit, and it reports settled or unresolved.
  - Retrieval returns the single head, or all heads when unresolved.
  - The revision graph is retrievable as history.
- **Resolution:** a coordinator submits a resolution revision naming all current heads. If a new head arrives first, the resolution is still accepted and the visit stays unresolved.
- **Export eligibility:** only settled visits are eligible, and review-export links to this rule.
- **Decisions table:** the whole-visit vs. three-way merge choice and "no head is current during a dispute", with rationale.
- **Consequences:** the larger review queue is stated as the accepted cost.

## Decisions I need from you

These are forks where I did not want to pick a reading for you.

1. **Resolution shape.** Can a coordinator only pick one head, or also compose a new payload from the heads?
   - I drafted "either". If pick-only, the unchosen head's unique edits stay in history but drop out of the exported record.
   - I'd recommend allowing composition, since a pick is just the special case where the composed payload equals one head.
2. **Base revision across offline edits.** The visit may be edited several times on one tablet before it syncs.
   - **(A) Client-generated revision IDs:** successive offline edits chain, and the server must define ordering and holding rules.
   - **(B) Server-assigned IDs:** the tablet submits one complete visit per sync, based on the last revision it fetched. This is simpler, and unsubmitted intermediate drafts are not submissions.
   - I'd lean (B), but this sizes tablet-sync's storage and retry state machine, so it's your call.
3. **Identical competing heads.** If two tablets submit byte-identical payloads from the same base, is that review work?
   - Treating it as a conflict is the simplest and makes no inference.
   - Auto-settling is deterministic equality, not scientific inference. It would need a rule for who the "resolver" is, since REC-006 requires a coordinator identity.
4. **Concurrent coordinators.** Two coordinators resolving the same visit at once currently produce two resolution heads, so the visit reopens. Is that acceptable, or should the second resolution be blocked?

These four sit under Deferred in the doc until you rule.

## Edge-case probe
I ran the Phase 2 probe myself rather than through a blind reader. Beyond the four above, it found nothing needing a decision:
- Archived plots remain resolvable per the site catalog, so a late submission to an archived plot is not a gap.
- Retry, stale base, and late head are covered in the draft.

If you'd like a zero-context reader on the LLD before Phase 3, say so and I'll dispatch one.

## One offer
The concurrency choice will stay live for a cold reader, because tablet-sync and review-export are about to be sized around it. Would you like it recorded as a full decision doc in `docs/intent/record-store/decisions/`, with the options and criteria laid out? The alternative is the Decisions table row it already has. I won't write the doc unless you say yes.

## Next
Reply with answers to 1–4 (and the decision-doc call) or numbered edits to the LLD. On approval I'll move to Phase 3 and revise the EARS specs: REC-004 to REC-006 need updating, and new specs are needed for heads, resolution, and export eligibility. Tablet-sync and review-export stay unwritten until the record-store contract lands, as you said.