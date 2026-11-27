Whole-visit revisions are recorded and the record-store design (LLD) is redrafted around them. This is the Phase 2 stop, so no specs, tests or code have been touched yet.

## What changed

- **`docs/intent/record-store/record-store-design.md`**: the open choice is gone, and the node now defines:
  - **Revision model**: each accepted submission is a complete visit revision, and revisions form a tree through their base revision. A visit with one head is *settled*; more than one head means *unresolved*.
  - **Submission envelope**: visit ID, base revision ID (absent for a first revision), idempotency key, and the complete visit payload.
  - **Acceptance rules**: a base that is the only head extends it; a stale base or a second first-revision adds a head; a base from another visit is rejected.
  - **Current-state response**: heads plus an explicit settled/unresolved flag, never an arrival-order pick.
  - **Resolution operation**: a coordinator settles a visit, and the outcome is retained.
  - **Decisions table**: it records the choice, the merge alternative, and your rationale.
- **`docs/high-level-design.md`**: the record-store state now reads "whole-visit revisions", and the "must wait" wording is removed.

## Questions for you (numbered so you can answer by number)

1. **Decision doc or table row?** The choice is currently one row in the LLD's Decisions table. Tablet-sync and review-export are about to be sized around it, so it may stay live for a cold reader. Want a standalone decision doc under `docs/intent/record-store/decisions/`, or is the row enough?
2. **What can a coordinator's resolution produce?** The draft says a coordinator "names the heads it settles", which leaves two readings:
   - (a) Pick one submitted revision as-is. This keeps every current state a revision a worker actually submitted.
   - (b) Also author a new revision, hand-combining fields. This is more flexible, but the resolved record is then a coordinator-built visit.

   Which do you want?
3. **Does a resolution make the chosen revision the sole head, or add a new revision on top?** Either way the unchosen revisions stay in history. A new resolution revision gives a uniform audit trail ("the exported value came from resolution R, which chose revision X"), which fits the inspectability tenet.
4. **Edits made while a visit is unresolved.** If a worker edits from one of the competing heads, the draft keeps that branch as a head, so the visit stays unresolved with the competing set growing. Is that the intent?
5. **A first-ever visit with two competing first revisions.** Two tablets create the same visit UUID offline. The draft treats this as unresolved with no base. Is that right?

## Tenet and goal tensions to check

I read the mechanism against the HLD, and these need your eye:

- **"Prefer workflows two coordinators can operate"**: with about 6,000 records a season, you've accepted a bigger queue. Do you have a sense of how many competing visits two coordinators can clear before Friday? If it's too many, the queue design (deferred to review-export) is what matters.
- **"Make reviewable problems visible before the Friday export"**: unresolved visits are held out of the CSV, so the partner's file can silently shrink. The export design should surface the count of held-out visits. I'll carry that to review-export unless you say otherwise.
- **Unrelated edits become review work.** For example, one worker fixes an observer name while another adds a species. This is the cost you chose, and the LLD says so.

## LLD edge-case probe: gaps found

I ran this probe myself, in-context, without a subagent. These are candidate gaps; tell me which to fix in the LLD and which to defer:

- A resubmission that is byte-identical to an existing revision but has a new idempotency key: new revision, or dedupe?
- A worker submits against a base revision that has since been resolved away (an unchosen branch). Does it reopen the visit?
- Plot reference validation when the plot is archived (CAT-004 keeps it resolvable): accepted?
- Two coordinators resolving the same visit concurrently: first wins, or is the second rejected?
- A resolved visit later receives a late-arriving submission based on a pre-resolution revision.

## Next

After your answers, I'll update the LLD, then draft the REC EARS specs (Phase 3). REC-004 and REC-005 will probably be sharpened there. Cross-segment work (tablet-sync, review-export) waits, as you said.