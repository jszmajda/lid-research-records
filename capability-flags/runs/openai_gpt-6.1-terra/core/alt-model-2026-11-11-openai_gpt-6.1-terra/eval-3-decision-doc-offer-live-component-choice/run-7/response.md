I’ve updated the HLD to reflect the selected approach. The record-store design and specs still need their next-phase update.

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
| record-store | Accept visit submissions and define how concurrent edits become a current record | docs/intent/record-store/record-store-design.md | Drafted |
| tablet-sync | Keep local drafts, submit changes, and explain server outcomes to field workers | docs/intent/tablet-sync/tablet-sync-design.md | Not written |
| review-export | Present review work and produce the partner's reviewed CSV | docs/intent/review-export/review-export-design.md | Not written |

Record-store uses whole-visit revisions: competing revisions go to review, and unresolved visits are held out of the CSV. Tablet-sync and review-export depend on the record-store contract for submission metadata, the shape of review work, and export eligibility.

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

## Pre-flight findings

- The record-store design calls for field-type and plot-reference validation, but its current specs do not explicitly cover those checks. There are no implementation or test files in the repository.
- The site-catalog design still says the concurrency choice is pending. Correcting that sentence crosses into a sibling segment.

The whole-visit choice has a lasting tradeoff and shapes both downstream designs. Would you prefer a **standalone decision document** explaining the alternatives and criteria, or a **decision row** in the record-store design?

Do you approve the HLD as shown, including its existing tenets? May I also correct the stale sentence in the site-catalog design when I continue?