The record-store design is redrafted around whole-visit revisions and is ready for your review. I have not touched the specs; they come after you approve this.

## What the draft says

The full text is in `docs/intent/record-store/record-store-design.md`.

- **Revisions**: every submission is a complete, immutable copy of the visit. It carries a revision ID, the visit ID, the base revision it was edited from, the fields, the author and the receipt time.
- **Visit state**: a revision is superseded when another names it as base or a resolution closes it. One unsuperseded revision means the visit is `settled` and that revision is current. Two or more means it is `unresolved` and they are the competing revisions.
- **Arrival order never decides**: an edit against an already-superseded base is accepted as competing, not rejected. An edit on top of a competing revision replaces it in the competing set.
- **Submission outcomes**: accepted as `current` or `competing`, or rejected as `invalid`, `unknown_base`, `key_reused` or `unauthenticated`. A rejection stores nothing.
- **Retrieval**: a settled visit returns its current revision; an unresolved visit returns all competing revisions. History returns every revision and resolution.
- **Resolution**: coordinator only. It names the competing revisions reviewed and is rejected as `stale` if that set has changed. A later edit against a superseded revision reopens the visit.

## Choices I made that are yours to rule on

1. **An unresolved visit has no current revision.** The alternative is to keep the last settled revision as current until resolution. My choice keeps a disputed value out of the CSV, but a visit the partner already received drops out of Friday's export if a stale tablet syncs on Thursday.
2. **Coordinators can choose a competing revision or replace it with their own complete revision.** The alternative is choose-only. I allowed replace because when two workers each fixed a different real error, neither revision is right.
3. **Tablets generate revision IDs.** The alternative is server-assigned IDs. A tablet offline for 48 hours can then chain several edits to one visit before any server contact.

## Gaps from an independent probe of the draft

For each, tell me whether to fix it in the design now or defer it; my recommendation is in brackets.

4. **Author on shared tablets**: if worker A's queued edit syncs under worker B's login, the draft records B as author. [Fix: the envelope should carry the editing worker separately from the submitter.]
5. **Simultaneous arrivals**: the draft does not say submissions and resolutions for one visit are processed one at a time. [Fix: state it as an invariant.]
6. **Replace revision envelope**: the draft does not say what base a coordinator's replacement names, who creates its ID, or what happens if it fails validation. [Fix.]
7. **Resolution retries and errors**: there is no idempotency for a resolution whose response was lost, and no outcomes for a non-coordinator caller, a choice outside the named set or an already-settled visit. [Fix.]
8. **Can a revision change the visit's plot?** The draft lists the plot UUID among revisable fields but does not say so deliberately. [Your call: fixed per visit, or correctable like any other field.]
9. **Idempotency key versus revision ID**: both come from the tablet, and the draft does not say what happens when a stored revision ID arrives under a new key. [Fix: reuse one as the other, or define the scope.]
10. **Mid-chain rejection**: if a middle edit in an offline chain is rejected, the later ones fail as `unknown_base` with no stated way forward. [Fix the server side here; the tablet side belongs to tablet-sync.]
11. **Replayed result after state change**: a retry returns the original `current` outcome even if the visit has since become unresolved. [Fix: return the original outcome plus the visit's present state.]
12. **Listing and read access**: the draft assumes callers can list visits by state but defines no such operation, and does not say who may read which visits. [Fix listing; defer read access unless you have a rule in mind.]

## Other things to decide

13. **Decision record**: the whole-visit versus field-merge choice is recorded as a row in the design's Decisions table. Because tablet-sync and review-export are both sized around it and someone feeling the review queue may want to reopen it, I can also write it up as a standalone decision doc in `docs/intent/record-store/decisions/`. Do you want that, or is the row enough?
14. **Site catalog wording**: `site-catalog-design.md` still says tablet-sync's submission behaviour "remains pending that choice". It is a different node, so I left it. May I update that sentence?

I also made one edit outside the node: `docs/high-level-design.md` no longer describes the record-store concurrency choice as open, and says the two downstream designs build on its contract.

The design defers two things as open questions: duplicate visits recorded under different visit UUIDs, and withdrawing a visit recorded in error.

Once you approve the design with your answers to the numbered items, I'll draft the spec updates. REC-004 and REC-005 need rewording, and there will be new specs for revision state, submission outcomes and resolution.