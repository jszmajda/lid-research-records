I recorded the selected approach in `docs/high-level-design.md`. The record-store contract still needs its detailed design; tablet sync and review/export remain for later.

## HLD review

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
| record-store | Accept visit submissions and define how concurrent edits become a current record | docs/intent/record-store/record-store-design.md | Drafted; whole-visit revision contract in design |
| tablet-sync | Keep local drafts, submit changes, and explain server outcomes to field workers | docs/intent/tablet-sync/tablet-sync-design.md | Not written |
| review-export | Present review work and produce the partner's reviewed CSV | docs/intent/review-export/review-export-design.md | Not written |

Record-store uses whole-visit revisions: each edit names its starting revision, and competing complete revisions go to coordinator review. Tablet-sync must retain base revision IDs. Review-export needs revision comparison and must hold unresolved visits out of the CSV. Their detailed designs depend on the record-store contract.

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

## Decisions for you

1. **Approve this HLD update** so I can complete the record-store design?
2. Your choice suggests a possible tenet: **“Preserve scientific context over reducing review workload.”** Would you add it, and if so where should it rank among the existing tenets?
3. This tradeoff could merit a standalone decision document because both downstream designs depend on it. Would you prefer that, or a concise decision row in the record-store design?
4. The site-catalog design still says the concurrency choice is pending. May I correct that stale sentence when cascading the change?