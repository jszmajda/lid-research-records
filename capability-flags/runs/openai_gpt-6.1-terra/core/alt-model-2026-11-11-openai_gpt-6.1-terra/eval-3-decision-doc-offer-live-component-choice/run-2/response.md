I’ve updated the HLD to reflect whole-visit revisions. The record-store design and specs still describe the concurrency choice as open; I’ll update that segment after the HLD review.

## HLD draft

### Problem

A coastal conservation team has 24 seasonal field workers using 12 shared Android tablets to survey 320 permanent vegetation plots. They produce about 6,000 plot-visit records per season. Tablets can be offline for 48 hours, and workers sometimes correct the same visit independently after comparing field notes. Today, spreadsheet imports overwrite corrections without showing which submission was lost.

Each visit contains a plot reference, observation date, observer names, species cover estimates, and notes. A regional science partner receives a reviewed CSV every Friday. Two coordinators resolve questions about submitted observations.

### Approach

Provide offline capture, a server-side record store, and a review-to-export workflow. Preserve submitted edits and make the exported state explainable. The first release handles structured records only; photographs remain in the team’s existing archive.

### Architecture

| Node | Responsibility | Design | State |
|---|---|---|---|
| site-catalog | Maintain stable plot references and distribute the field catalog | `docs/intent/site-catalog/site-catalog-design.md` | Drafted |
| record-store | Accept visit submissions and define how concurrent edits become a current record | `docs/intent/record-store/record-store-design.md` | Drafted; concurrency policy selected |
| tablet-sync | Keep local drafts, submit changes, and explain server outcomes to field workers | `docs/intent/tablet-sync/tablet-sync-design.md` | Not written |
| review-export | Present review work and produce the partner’s reviewed CSV | `docs/intent/review-export/review-export-design.md` | Not written |

The record store uses whole-visit revisions: competing edits are preserved for coordinator review. Tablet-sync must track base revision IDs; review-export must support revision comparison and hold unresolved visits out of CSV exports. Those designs depend on the record store’s contract.

### Tenets

- Do not silently discard a submitted edit.
- Let field workers continue collecting observations without connectivity.
- Keep the path from a submitted observation to an exported value inspectable.
- **Prefer human judgment over automation when scientific meaning is uncertain, even at the cost of review workload.**
- Prefer workflows two coordinators can operate without a dedicated systems administrator.

### Goals

- Retain drafts across tablet restarts and multi-day disconnection.
- Support independent corrections to the same visit.
- Make reviewable problems visible before the Friday export.
- Export the partner’s existing columns without requiring spreadsheet cleanup.

### Non-Goals

- Photograph storage or image annotation.
- Real-time collaborative editing.
- Automated botanical validation or inference of scientific intent.
- Replacing the team’s identity provider.

## Review

1. Does the new tenet accurately express your preference, and are there other tenets you want to add? **Do you approve the HLD as drafted?**
2. The concurrency choice has lasting tradeoffs and will shape both downstream designs. Would you like a standalone decision document preserving those tradeoffs, or a concise decision row in the record-store design?