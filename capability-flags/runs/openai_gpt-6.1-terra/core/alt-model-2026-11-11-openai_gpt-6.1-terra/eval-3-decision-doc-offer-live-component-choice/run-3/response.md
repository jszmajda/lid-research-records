Whole-visit revisions fit the existing architecture: the concurrency policy belongs to record-store. I updated the HLD’s status and dependency description to reflect your selection.

**HLD for review** (`docs/high-level-design.md`):

> # TidePlot: High-Level Design
>
> ## Problem
>
> A coastal conservation team has 24 seasonal field workers using 12 shared Android tablets to survey 320 permanent vegetation plots. They produce about 6,000 plot-visit records per season. Tablets can be offline for 48 hours, and workers sometimes correct the same visit independently after comparing field notes. Today, spreadsheet imports overwrite corrections without showing which submission was lost.
>
> Each visit contains a plot reference, observation date, observer names, species cover estimates, and notes. A regional science partner receives a reviewed CSV every Friday. Two coordinators resolve questions about submitted observations.
>
> ## Approach
>
> Provide offline capture, a server-side record store, and a review-to-export workflow. Preserve submitted edits and make the exported state explainable. The first release handles structured records only; photographs remain in the team's existing archive.
>
> ## Architecture
>
> | Node | Responsibility | Design | State |
> |---|---|---|---|
> | site-catalog | Maintain stable plot references and distribute the field catalog | docs/intent/site-catalog/site-catalog-design.md | Drafted |
> | record-store | Accept visit submissions and define how concurrent edits become a current record | docs/intent/record-store/record-store-design.md | Drafted; whole-visit revisions selected |
> | tablet-sync | Keep local drafts, submit changes, and explain server outcomes to field workers | docs/intent/tablet-sync/tablet-sync-design.md | Not written |
> | review-export | Present review work and produce the partner's reviewed CSV | docs/intent/review-export/review-export-design.md | Not written |
>
> The concurrency mechanism belongs to record-store. Its whole-visit revision contract determines submission metadata, the shape of review work, and which record states can enter an export. Tablet-sync and review-export depend on that contract.
>
> ## Tenets
>
> - Do not silently discard a submitted edit.
> - Let field workers continue collecting observations without connectivity.
> - Keep the path from a submitted observation to an exported value inspectable.
> - Prefer workflows two coordinators can operate without a dedicated systems administrator.
>
> ## Goals
>
> - Retain drafts across tablet restarts and multi-day disconnection.
> - Support independent corrections to the same visit.
> - Make reviewable problems visible before the Friday export.
> - Export the partner's existing columns without requiring spreadsheet cleanup.
>
> ## Non-Goals
>
> - Photograph storage or image annotation.
> - Real-time collaborative editing.
> - Automated botanical validation or inference of scientific intent.
> - Replacing the team's identity provider.

The record-store design and specs still reflect the open choice; they need the next design and specification passes. The site-catalog design also says the choice is pending. I’ve left that sibling document untouched for now.

1. **Do you approve this HLD check so I can continue with the record-store design?**
2. Would you add a tenet such as **“Prefer preserving observation context over reducing manual review”**, or are the existing tenets sufficient?
3. This choice has durable tradeoffs and shapes two downstream designs. Would you like a standalone decision document, or a concise decision row in the record-store design?