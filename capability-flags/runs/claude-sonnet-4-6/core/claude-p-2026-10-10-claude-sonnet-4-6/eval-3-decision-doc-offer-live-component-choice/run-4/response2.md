Here is the full updated HLD for Phase 1 review:

---

**`docs/high-level-design.md`**

```markdown
# TidePlot: High-Level Design

## Problem

A coastal conservation team has 24 seasonal field workers using 12 shared Android tablets
to survey 320 permanent vegetation plots. They produce about 6,000 plot-visit records per
season. Tablets can be offline for 48 hours, and workers sometimes correct the same visit
independently after comparing field notes. Today, spreadsheet imports overwrite corrections
without showing which submission was lost.

Each visit contains a plot reference, observation date, observer names, species cover
estimates, and notes. A regional science partner receives a reviewed CSV every Friday. Two
coordinators resolve questions about submitted observations.

## Approach

Provide offline capture, a server-side record store, and a review-to-export workflow.
Preserve submitted edits and make the exported state explainable. The first release handles
structured records only; photographs remain in the team's existing archive.

## Architecture

| Node | Responsibility | Design | State |
|---|---|---|---|
| site-catalog | Maintain stable plot references and distribute the field catalog | docs/intent/site-catalog/site-catalog-design.md | Drafted |
| record-store | Accept visit submissions and define how concurrent edits become a current record | docs/intent/record-store/record-store-design.md | Drafted |
| tablet-sync | Keep local drafts, submit changes, and explain server outcomes to field workers | docs/intent/tablet-sync/tablet-sync-design.md | Not written |
| review-export | Present review work and produce the partner's reviewed CSV | docs/intent/review-export/review-export-design.md | Not written |

The concurrency mechanism belongs to record-store, not this HLD. Tablet-sync and
review-export size their designs against the record-store contract: it determines the
submission envelope, the shape of review work, and which record states enter an export. See
the record-store design for those definitions.

Specific obligations each node inherits from the whole-visit revisions choice:

- **tablet-sync** must carry a base revision ID with every edit submission (identifying the
  revision the worker last fetched) and must surface the `under_review` visit status returned
  by the server without treating it as a submission error.
- **review-export** must provide a coordinator view listing visits with competing revisions,
  support side-by-side comparison of those revisions, and exclude any visit with unresolved
  competing revisions from the export set.

## Key Design Decisions

### Whole-visit revisions for concurrent edits

When two workers independently edit the same visit from the same base revision, both
submissions are stored as complete competing revisions. The visit is held out of export until
a coordinator accepts one. The alternative is field-aware three-way merge: the server
automatically combines edits to disjoint fields (e.g., one worker corrects an observer name,
another adds a missing species) and routes only overlapping fields to coordinator review,
reducing the volume of visits that need attention.

Field-aware merge was set aside because it requires maintained rules for combining scalar
fields, observer lists, and species entries. Those rules could produce scientifically plausible
but incorrect combinations when workers intended competing interpretations — for example,
different species identifications paired with different cover estimates. A merged record would
look resolved while reflecting neither worker's intent, which works against the *keep the path
from a submitted observation to an exported value inspectable* tenet.

A larger review queue is the trade-off. With 6,000 visits per season and 24 workers, if
coordinators find themselves routinely approving edits to clearly unrelated fields, review
volume could outpace two people before Friday. Field-aware merge is the natural response to
that pressure; revisit this choice then with observed queue data. Details and mechanics are in
the record-store design.

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

---

The Key Design Decisions entry names the alternative, explains why it was set aside without treating field-aware merge as a bad idea, and flags the condition that would make it worth revisiting. The architecture paragraph now names the specific obligations each downstream node inherits so tablet-sync and review-export authors know what they're sizing against before they open the record-store design.

Does this read right? If so, I'll proceed to Phase 2 — the LLD.