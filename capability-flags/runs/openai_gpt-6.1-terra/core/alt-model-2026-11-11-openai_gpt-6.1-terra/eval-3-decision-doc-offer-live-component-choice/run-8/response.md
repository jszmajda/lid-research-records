I updated `docs/high-level-design.md` to reflect the whole-visit revision choice. The record-store LLD and its generic specs still describe the choice as open; I’ll revise them after this HLD review. The site-catalog LLD also has a stale reference to the pending choice, which needs a separate cross-segment review.

## HLD for review

### Problem

A coastal conservation team has 24 seasonal field workers using 12 shared Android tablets to survey 320 permanent vegetation plots. They produce about 6,000 plot-visit records per season. Tablets can be offline for 48 hours, and workers sometimes correct the same visit independently after comparing field notes. Today, spreadsheet imports overwrite corrections without showing which submission was lost.

Each visit contains a plot reference, observation date, observer names, species cover estimates, and notes. A regional science partner receives a reviewed CSV every Friday. Two coordinators resolve questions about submitted observations.

### Approach

Provide offline capture, a server-side record store, and a review-to-export workflow. Preserve submitted edits and make the exported state explainable. The first release handles structured records only; photographs remain in the team’s existing archive.

### Architecture

| Node | Responsibility | Design | State |
|---|---|---|---|
| site-catalog | Maintain stable plot references and distribute the field catalog | `docs/intent/site-catalog/site-catalog-design.md` | Drafted |
| record-store | Accept visit submissions and define how concurrent edits become a current record | `docs/intent/record-store/record-store-design.md` | Drafted; whole-visit revision contract in design |
| tablet-sync | Keep local drafts, submit changes, and explain server outcomes to field workers | `docs/intent/tablet-sync/tablet-sync-design.md` | Not written |
| review-export | Present review work and produce the partner’s reviewed CSV | `docs/intent/review-export/review-export-design.md` | Not written |

The record-store concurrency mechanism uses whole-visit revisions: competing revisions go to coordinator review rather than being automatically merged. Tablet-sync must track base revision IDs; review-export must support comparison and hold unresolved visits out of the CSV. Their detailed contracts depend on the record-store design.

### Tenets

- Do not silently discard a submitted edit.
- Let field workers continue collecting observations without connectivity.
- Keep the path from a submitted observation to an exported value inspectable.
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

## Decisions for this stop

1. **Approve this HLD update** so I can finish the record-store design?
2. Should I capture the concurrency tradeoff in a **full decision document**, or is a concise record-store decisions-table row enough? The full document would preserve the competing options and criteria for future reconsideration.
3. Would you add a broader tenet such as **“Prefer preserving scientific context over reducing review workload”**, or are the existing tenets sufficient?