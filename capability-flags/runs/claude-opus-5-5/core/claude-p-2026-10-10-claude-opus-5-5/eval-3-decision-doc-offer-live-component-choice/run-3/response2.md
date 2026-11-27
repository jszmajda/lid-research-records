The decision doc is written at `docs/intent/record-store/decisions/concurrent-visit-edits.md`, and the design's Decisions row now links to it instead of carrying the full rationale.

## What it says

- **Criteria**: integrity of related fields and explainable exported values are weighted major. Maintenance burden, coordinator review workload and Friday export completeness are moderate. Tablet storage is minor.
- **Selection**: whole-visit revisions win on both major criteria and on maintenance. The doc says plainly that the choice goes against review workload and export completeness.
- **Why field-aware merge stays credible**: it is strong exactly where whole-visit revisions are weak. The doc names two things that would reopen the choice:
  - coordinators regularly cannot clear unresolved visits before Friday;
  - most competing revisions differ only in unrelated fields and coordinators are mechanically accepting both.
- **If it is reopened**: the form to weigh first is automatic combination only for field pairs the team has declared independent. Moving that way later loses nothing, because every revision already records its base; records already merged by rule could not be separated again.
- **Tablet-sync must**: keep a base revision ID per edited visit for the whole offline period, submit complete visits, treat "accepted, competing" as a normal result it can explain to a worker, and show a visit as awaiting review even if it was current at last sync.
- **Review-export must**: provide a visible queue of unresolved visits, a side-by-side comparison of complete revisions, and an export rule that holds unresolved visits out and tells coordinators which ones.

## Things to check in it

- **The weights are my reading of what you said.** You put related-field integrity above queue size; I extended that to rank export completeness as moderate too. Change any weight that is wrong.
- **The rate of independent corrections is unmeasured.** The doc says so, since that rate decides how heavy the queue is. If you have a number from past seasons, it belongs there.
- **The species examples are illustrative.** I used *Spartina* and *Salicornia* to show a harmless pair and a harmful merge; swap in species from your plots if you prefer.
- **I left out anything that depends on items 1–3.** The doc does not say whether coordinators can write a replacement revision, what an unresolved visit shows as current, or who generates revision IDs.

## Still open from the design review

Items 1–12 and 14 from my last message still need your ruling before I draft the spec updates. The three with the widest effect are whether an unresolved visit has a current revision (1), whether coordinators can replace as well as choose (2), and who is recorded as author on a shared tablet (4).