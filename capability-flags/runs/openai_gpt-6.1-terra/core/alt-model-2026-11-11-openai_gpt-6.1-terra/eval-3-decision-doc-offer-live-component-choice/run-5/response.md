I updated `docs/high-level-design.md` to reflect the selected approach. The existing record-store design still describes the choice as open; its update is the next phase. The generic record-store specs do not yet express the selected policy, and there are no tests or implementation in the repository.

## HLD for review

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

The concurrency mechanism belongs to record-store. Whole-visit revisions preserve each submitted visit as a unit and send competing revisions to review. Tablet-sync will track base revision IDs; review-export will compare revisions and hold unresolved visits out of the CSV. Both designs depend on the record-store contract.

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

## Questions

1. Do you approve this HLD update so I can proceed to the record-store design?
2. Should your preference also be a general tenet: **prefer preserving the scientific meaning of submitted observations over reducing review workload**?
3. This choice has credible alternatives and affects later designs. Would you like a standalone decision document explaining the tradeoffs, or a concise decision row in the record-store design?
4. The site-catalog design has one sentence saying the concurrency choice is pending. May I update that stale sentence across the segment boundary?