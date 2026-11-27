Added [`whole-visit-revisions.md`](docs/intent/record-store/decisions/whole-visit-revisions.md) and linked it from the record-store’s Decisions & Alternatives table.

It records:
- Why preserving scientific relationships outweighs the larger review queue.
- The strongest case for field-aware merging: fewer reviews, better Friday export coverage, and smaller change submissions.
- What tablet-sync must retain and communicate.
- What review-export must compare, trace, and withhold.
- Conditions that would justify reconsidering the choice.

`git diff --check` passed.

One design choice still needs your answer: **may coordinators author a corrected complete revision using evidence from several submissions, or only select an existing revision?**