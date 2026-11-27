Done. The decision doc is written and the LLD now carries the A1–A3 precision fixes plus a link to it.

## Where things stand (still Phase 2)

- **`docs/intent/record-store/decisions/concurrency-policy.md`** — full decision doc. Context, decision elements (scientific-relationship safety as the major criterion, with review workload / maintenance burden / inspectability / size), both options in their strongest honest form, and a Selection that spells out *why field-aware merge stays worth considering* (it genuinely wins the review-workload criterion against a weekly deadline and two coordinators) and *what tablet-sync and review-export must accommodate* under the chosen policy — plus the contrasting obligations the merge option would have imposed, so a future reader weighing a reversal sees the cost.
- **LLD** — branch rule now states processing order never picks a winner; added the head/tree/atomicity invariants; "the others" → "the other competing revisions"; Decisions row links the doc.

## Still open — your call (unchanged from the last stop)

These are genuine forks I shouldn't settle for you; the decision doc and LLD stand without them, but Phase 3 (EARS) needs them pinned:

- **Q1.** Is resolution reversible? *Lean: yes, as a new recorded resolution with the prior retained.*
- **Q2.** Idempotency-key scope + "identical payload" definition. *Lean: per (visit, author); identical = field payload + base, excluding server-assigned fields.*
- **Q3.** Interim policy for a submission based on an already-superseded revision. *Lean: reject as stale for now.*
- **Q4.** Confirm no cap on competing heads in v1 (the deferred item is only about an optional later threshold).
- **Q5.** Plot re-validation at resolution time. *Lean: validate at submission only.*
- **A4** (folded in, since it overlaps Q2/Q3): once Q2/Q3 land I'll pin the retrieval shape (null-vs-omitted current revision; never-submitted vs existing visit) and give the three rejections distinct shapes.

Answer by number (or take my leans). Once these are settled I'll move to **Phase 3 — EARS**: refine REC-005/006 and add specs for the revision model, branch detection, resolution, and the invariants.