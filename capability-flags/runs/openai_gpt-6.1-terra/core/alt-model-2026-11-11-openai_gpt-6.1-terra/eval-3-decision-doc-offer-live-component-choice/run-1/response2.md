I added the decision document at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the record-store design. Here is the draft for review:

## Decision: Concurrent Visit Edits

### Context

Field workers use shared tablets that may be offline for 48 hours. They can independently correct the same visit after comparing notes, and their edits may reach the server days after they started. Arrival order does not establish which observation is more authoritative. The store retains original submissions so neither approach silently discards a worker’s edit.

A visit includes plot reference, date, observers, species cover estimates, and notes. Edits to different fields can still be scientifically related: changing a species identification may affect the meaning of its cover estimate. Two coordinators review submissions, and the science partner receives a reviewed CSV every Friday.

### Decision elements

- **Major — preserve scientific context.** Avoid producing a combined visit whose relationship between observations has not been considered. This supports the tenet that the path from an observation to an exported value remain inspectable.
- **Moderate — operational simplicity.** Keep the concurrency policy and its maintenance manageable for a team without a dedicated systems administrator.
- **Moderate — review workload and export readiness.** Limit review work and the number of visits awaiting resolution at the Friday export.
- **Minor — offline storage and transfer.** Limit what tablets must retain and transmit across intermittent connections while keeping offline work practical.

### Whole-visit revisions

Each submitted edit contains a complete visit and identifies its base revision. Independently edited revisions that compete are retained for a coordinator to compare and resolve. The server does not automatically combine their fields. Tablet-sync retains base revision IDs and submits complete revisions; review-export presents competing revisions and holds unresolved visits out of the CSV.

- **Scientific context — strong:** each submission remains intact, and competing versions are reviewed rather than automatically recombined.
- **Operational simplicity — strong:** the server avoids field-specific merge rules, although it still needs revision tracking and a resolution workflow.
- **Review workload and export readiness — weak:** even unrelated corrections produce review work, and unresolved visits wait for resolution before export.
- **Offline storage and transfer — partial:** complete revisions repeat unchanged data, but tablets need base revision IDs rather than merge-ready base snapshots and structured diffs.

### Field-aware three-way merge

Each edit supplies its base state and structured changes. The server compares the changes against the base, combines changes to fields classified as independent, and sends overlaps to review. Rules must cover scalar fields, observer lists, and species entries; original submissions remain available. Tablets retain base snapshots and send structured changes. Review-export needs field-level provenance and a way to review overlapping changes.

- **Scientific context — weak:** disjoint fields can be scientifically related even when merge rules treat them as independent. Field-level provenance makes the result traceable but does not itself establish that the combination is sound.
- **Operational simplicity — weak:** field-specific rules and their behavior as the visit schema changes need ongoing maintenance.
- **Review workload and export readiness — strong:** genuinely unrelated edits can combine without a review item, leaving more coordinator capacity for overlaps and making more visits available for export.
- **Offline storage and transfer — partial:** structured changes can avoid transmitting complete visits, but tablets must retain base snapshots and construct changes suitable for the merge rules.

### Selection

Use whole-visit revisions. The team accepts a larger review queue in preference to maintaining merge rules that might combine scientifically related edits without recognizing their relationship. This favors inspectable submitted observations and an operable workflow, while honoring the tenet that submitted edits are not silently discarded. The cost is more coordinator work and potentially fewer visits ready for a given Friday export.

Tablet-sync must retain base revision IDs and handle the store’s submission outcomes. Review-export must support revision comparison and exclude unresolved visits from the CSV. The exact submission envelope, current-state and unresolved-work representations, and coordinator resolution operation remain open in the record-store design. The tablet and export designs must accommodate the completed contract.

---

Do the criteria and their relative importance reflect your intent? Is there another consideration—particularly one favoring automatic merge—that could change the decision?

The record-store contract also still needs your choice: should a coordinator **select an existing revision only**, or be able to **author a complete resolved revision** that deliberately combines corrections from competing submissions?