**Phase 1 — HLD check: complete. Stop for your review.**

Coherence pre-flight first: HLD, record-store LLD, and REC specs were mutually consistent before the change (all three recorded the concurrency choice as open; no tests exist yet since there is no code). The only drift introduced by your selection is in the HLD text, which I've updated. The selection lives in record-store per the HLD's own boundary — the HLD only reflects it.

Updated `docs/high-level-design.md` in full:

```markdown
# TidePlot: High-Level Design

## Problem

A coastal conservation team has 24 seasonal field workers using 12 shared Android tablets to survey 320 permanent vegetation plots. They produce about 6,000 plot-visit records per season. Tablets can be offline for 48 hours, and workers sometimes correct the same visit independently after comparing field notes. Today, spreadsheet imports overwrite corrections without showing which submission was lost.

Each visit contains a plot reference, observation date, observer names, species cover estimates, and notes. A regional science partner receives a reviewed CSV every Friday. Two coordinators resolve questions about submitted observations.

## Approach

Provide offline capture, a server-side record store, and a review-to-export workflow. Preserve submitted edits and make the exported state explainable. The first release handles structured records only; photographs remain in the team's existing archive.

## Architecture

| Node | Responsibility | Design | State |
|---|---|---|---|
| site-catalog | Maintain stable plot references and distribute the field catalog | docs/intent/site-catalog/site-catalog-design.md | Drafted |
| record-store | Accept visit submissions and define how concurrent edits become a current record | docs/intent/record-store/record-store-design.md | Drafted; whole-visit revisions selected |
| tablet-sync | Keep local drafts, submit changes, and explain server outcomes to field workers | docs/intent/tablet-sync/tablet-sync-design.md | Not written |
| review-export | Present review work and produce the partner's reviewed CSV | docs/intent/review-export/review-export-design.md | Not written |

The concurrency mechanism belongs to record-store, not this HLD: concurrent edits to a visit produce competing whole-visit revisions that a coordinator resolves. Tablet-sync and review-export depend on that node's contract: it determines submission metadata, the shape of review work, and which record states can enter an export. Those two designs must wait for the contract to be written.

## Tenets

- Do not silently discard a submitted edit.
- Let field workers continue collecting observations without connectivity.
- Keep the path from a submitted observation to an exported value inspectable.
- Prefer workflows two coordinators can operate without a dedicated systems administrator.

## Goals

- Retain drafts across tablet restarts and multi-day disconnection.
- Support independent corrections to the same visit.
- Make reviewable problems visible before the Friday export.
- Export the partner's existing columns without requiring spreadsheet cleanup.

## Non-Goals

- Photograph storage or image annotation.
- Real-time collaborative editing.
- Automated botanical validation or inference of scientific intent.
- Replacing the team's identity provider.
```

Two judgment calls for you at this stop:

1. **Decision doc offer (offered once):** whole-visit revisions vs. field-aware merge is a live trade (review queue volume vs. merge-rule maintenance vs. scientific integrity) that tablet-sync and review-export will both be sized around. I can record it as a full decision doc at `docs/intent/record-store/decisions/whole-visit-revisions.md`, or just as a row in the LLD's Decisions & Alternatives table. Which do you want?
2. **Candidate tenet:** your rationale — a bigger review queue over merge rules that can silently combine scientifically related edits — leans classes of future choices beyond this one (e.g., later proposals for automated resolution). Candidate one-liner: *"Prefer visible coordinator review over automated combination of edits."* Add it to the HLD's Tenets, or leave it as the decision's rationale only?

Reply with numbered feedback (or "approved") and I'll proceed to Phase 2 — finishing the record-store LLD's contract (submission envelope, current-state response, unresolved-work representation, resolution operation) plus an LLD-level edge-case probe.