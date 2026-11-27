**Record-store design completed.**

The LLD now defines the whole-visit revisions approach with:

**Core mechanism**: Workers submit complete visits with base revision IDs. Concurrent edits create competing revisions that coordinators resolve by selecting one or manually combining.

**Why field-aware merge remains credible**: The Decisions table now explains that field-aware merge would work for higher-volume teams—auto-combining disjoint changes (one worker fixes spelling, another adds species) cuts coordinator workload. The risk: fields that look disjoint (observer list vs. species entries) may be scientifically coupled (observer A always records species X). Your 6,000 records/season and two-coordinator team favors explicit comparison over merge sophistication, but a larger operation might make the opposite trade.

**Downstream contracts**: 

- **Tablet-sync** must: retain base revision IDs, handle competing-revision outcomes, retry stale-base rejections, budget 150MB for 3,000 queued full-visit payloads.
- **Review-export** must: provide side-by-side revision comparison UI, exclude unresolved visits from Friday CSV, track resolution provenance, handle coordinator race conditions, support manual combination.

**HLD updated** to show concurrency choice resolved; tablet-sync and review-export can now be designed.

**STOP: Review the completed record-store design. Should we proceed to EARS specs, or adjust the design first?**