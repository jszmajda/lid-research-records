The decision is written up as a decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md`, and the LLD's Decisions row now links to it. Nothing is committed.

## What the doc contains

- **Context:** why concurrent edits are a problem here, and why the server can't tell related edits from unrelated ones.
- **Gates:** two inherited ones, both passed by either option: no submitted edit discarded, and offline capture continues.
- **Criteria**, with the tenet each turns on:
  - Major:
    - whole-visit intent preserved
    - exported value inspectable
    - coordinator review load
  - Moderate:
    - maintenance burden
    - tablet and submission complexity
    - visits export-ready by Friday
- **Both options**, each described at its strongest, with a per-criterion fit verdict.
- **Selection:** whole-visit revisions, and the doc says plainly that this is taken against the review-load side of "two coordinators can operate".

## Why the merge approach stays credible

The doc says why field-aware merge is still a live option and names two triggers for revisiting:

- the queue regularly exceeds what two coordinators clear before Friday, or
- review shows nearly all competing revisions touch clearly unrelated fields, so the queue is mostly work merging would remove.

It also notes that, because originals are kept whole, a merge could later be added as a suggestion for a coordinator to confirm without rewriting history.

## What tablet and export work must accommodate

**Tablet-sync**
- Keep the base revision ID per local draft, absent for a new visit.
- Submit the complete visit with a retry-stable idempotency key.
- Handle a "visit is now unresolved" response.
- Show pending competing revisions to the worker.
- Never silently rebase a draft onto a newer revision.

**Review-export**
- A revision comparison view.
- A resolution operation that records the coordinator and contributing revisions.
- An export set that excludes unresolved visits.
- Visibility of how many visits, and which ones, are held out before each export. The CSV can otherwise shrink silently.
- A queue sized for the volume this choice generates.

These are recorded as obligations in the record-store decision doc only. I haven't touched any tablet-sync or review-export files, since those nodes aren't written and crossing into them needs your go-ahead.

## Still open from my last message

Questions 2–5 are unanswered. The decision doc deliberately commits to none of them.

- **Q2:** can a resolution only pick a submitted revision, or can a coordinator author a new one?
- **Q3:** does a resolution make the chosen revision the sole head, or add a new revision on top?
- **Q4:** do edits made while a visit is unresolved extend that branch?
- **Q5:** are two competing first revisions of the same new visit unresolved?

The edge-case gap list also still needs triage. I'll hold Phase 3 (the REC EARS specs) until you answer. Q2 and Q3 shape the resolution specs directly.