I have written the decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from `docs/intent/record-store/record-store-design.md`.

Here is the decision doc in full:

---

```markdown
---
node: record-store
---

# Decision: Concurrent Visit Edit Policy

## Context

Twenty-four seasonal field workers share twelve Android tablets to survey 320 permanent coastal vegetation plots, producing roughly 6,000 visit records per season. Tablets operate offline for up to 48 hours. Workers frequently review field notes together at the end of a shift or the next day and submit corrections to the same visit from different tablets before syncing.

Because updates can arrive days after the starting state was fetched, server receipt order does not reflect which observation is more accurate. A visit record contains a plot reference (`plotId`), `observationDate`, `observers` list, `speciesCovers` (species identifiers paired with cover percentage estimates), and free-text `notes`. Some concurrent edits touch independent information (such as fixing a typo in an observer's name while another tablet adds a missed species). Other edits touch scientifically coupled fields: for example, when a worker realizes *Spartina alterniflora* was misidentified as *Spartina patens* and adjusts both the species entry, the cover estimate, and an explanatory note.

The choice of concurrency policy in `record-store` governs how concurrent submissions are represented, what state `tablet-sync` must persist on devices, and what review and export workflows `review-export` must provide for the two coordinators who prepare the Friday partner CSV.

## Decision Elements

### Gates

- **No silent data loss (inherited from HLD tenet: *Do not silently discard a submitted edit*)**: Every accepted worker submission must remain stored with its original payload, author, and receipt timestamp, and no concurrent edit may overwrite another without leaving an auditable trace or review path. Policies that overwrite earlier or later submissions silently (such as arrival-order last-writer-wins) fail this gate.

### Weighted Criteria

- **Scientific integrity of coupled observations (major)**: Whether the policy prevents producing a synthetic current visit that combines scientifically interdependent edits (such as species identity, cover percentages, and qualifying notes) that no single observer or coordinator ever intended together. Grounded in the HLD non-goal against automated botanical inference and the tenet *Keep the path from a submitted observation to an exported value inspectable*.
- **Operational simplicity and maintainability (major)**: Whether the policy can be operated by two coordinators and maintained without evolving complex domain-specific merge rules as survey fields or species list conventions change. Grounded in the HLD tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator*.
- **Coordinator review queue volume (moderate)**: How many concurrent visit edits require manual coordinator intervention before the Friday CSV export. With two coordinators handling 6,000 seasonal visits, policies that resolve benign disjoint edits automatically reduce Friday review bottlenecks.
- **Tablet storage and sync payload footprint (minor)**: How much baseline state each tablet must retain per cached visit during a 48-hour offline window and include in each submission request.

## Options in the Domain

### Option 1: Whole-Visit Revisions

Each accepted submission creates an immutable whole-visit revision and names the `baseRevisionId` from which the worker started editing. When a submission's `baseRevisionId` matches the visit's current uncontested revision, it advances the visit linearly. When a submission branches from an earlier revision (or arrives while the visit already has competing revisions), `record-store` transitions the visit to `needs_review` and tracks the competing revision heads in `competingRevisionIds`. A coordinator resolves the conflict by inspecting the competing complete revisions and submitting a resolution revision that cites the resolved `competingRevisionIds`.

#### Demonstration

```json
{
  "visitId": "8f14e45f-ceea-467f-a811-2b4d55e1c901",
  "visitStatus": "needs_review",
  "currentRevisionId": null,
  "competingRevisionIds": ["rev-02", "rev-03"]
}
```

#### Analysis

- **Gate — No silent data loss**: **passes**. Every submitted payload is retained as an immutable revision, and concurrent branches remain in `competingRevisionIds` until a coordinator explicitly resolves them.
- **Scientific integrity of coupled observations (major)**: **strong**. A visit is never assembled from pieces of two different submissions without a coordinator viewing the complete competing visits side by side. Coupled changes across `speciesCovers` and `notes` remain intact as submitted.
- **Operational simplicity and maintainability (major)**: **strong**. Conflict detection depends only on `baseRevisionId` lineage comparison. The server requires no field-by-field diffing or collection-matching rules, and adding or modifying visit fields does not require updating merge semantics.
- **Coordinator review queue volume (moderate)**: **weak**. Any concurrent edit to the same visit—even when one tablet only fixes an observer name and another only appends a note—places the visit into `needs_review` for manual resolution before Friday export.
- **Tablet storage and sync payload footprint (minor)**: **strong**. Tablets store only the current visit payload and its single `revisionId` string, sending the updated visit payload plus `baseRevisionId` on submission.

#### Summary

Guarantees whole-visit scientific coherence and simple lineage rules at the cost of routing all concurrent same-visit edits to the coordinator review queue.

### Option 2: Field-Aware Three-Way Merge

Each tablet retains the full base visit snapshot alongside local edits and submits either the base snapshot or structured field-level changes against that base. When two concurrent edits modify disjoint parts of a visit against a common base (for example, one modifies `observationDate` and another modifies `observers`), `record-store` automatically merges the non-overlapping changes into a new composite current state while preserving both raw submissions in history. When two edits modify the same scalar field, overlapping entries in `observers` or `speciesCovers`, or fail merge rules, `record-store` flags only the overlapping fields as conflicted for coordinator resolution.

#### Demonstration

```json
{
  "visitId": "8f14e45f-ceea-467f-a811-2b4d55e1c901",
  "visitStatus": "needs_review",
  "BaseRevisionId": "rev-01",
  "autoMergedFields": ["observationDate", "observers"],
  "conflictingFields": ["speciesCovers[Spartina patens]"]
}
```

#### Analysis

- **Gate — No silent data loss**: **passes**. Original submissions are preserved in history alongside field-level provenance linking each merged field to its contributing submission.
- **Scientific integrity of coupled observations (major)**: **weak**. Structural field rules cannot detect semantic coupling across distinct fields or distinct species keys. If Worker A reclassifies *Spartina patens* (25%) to *Spartina alterniflora* (25%) and updates `notes`, while Worker B adjusts `notes` or adds another species cover that shifts total canopy composition, an automatic merge can combine incompatible botanical records into an exported visit without flagging a conflict.
- **Operational simplicity and maintainability (major)**: **weak**. Requires explicit three-way merge semantics for scalars (`observationDate`, `notes`), set/list fields (`observers`), and keyed collection entries (`speciesCovers`), plus field-level provenance tracking so coordinators can audit how a composite record was assembled.
- **Coordinator review queue volume (moderate)**: **strong**. Concurrent edits to unrelated fields (such as observer list corrections vs. date corrections) merge automatically and become immediately eligible for the Friday CSV export without coordinator intervention.
- **Tablet storage and sync payload footprint (minor)**: **partial**. Each tablet must retain the immutable base snapshot alongside the working draft for every edited visit so three-way diffs can be computed or verified across 48-hour offline windows.

#### Summary

Reduces coordinator review load for disjoint edits, but requires maintaining collection merge rules and risks silently combining scientifically coupled edits across different fields or species entries.

## Selection

Select **Option 1: Whole-Visit Revisions**.

The decision turns on the major criteria of **scientific integrity of coupled observations** and **operational simplicity**, guided by the HLD tenets *Keep the path from a submitted observation to an exported value inspectable* and *Prefer workflows two coordinators can operate without a dedicated systems administrator*, as well as the HLD non-goal excluding automated inference of scientific intent.

In vegetation surveys, species identifications, cover percentages, and field notes within a single plot visit are scientifically interdependent. Option 2 (Field-Aware Three-Way Merge) remains a credible alternative if coordinator review volume ever becomes unsustainable and the team is willing to restrict auto-merge to strictly isolated metadata fields (such as `observers`), because it substantially reduces manual review for disjoint corrections. However, for full visit records, maintaining collection-merge rules that could silently combine related botanical edits without coordinator review poses an unacceptable risk to data quality. With 6,000 visits per season and conflicts limited to cases where two tablets independently edit the same visit within an offline window, the additional review queue volume under Option 1 is manageable for two coordinators.

### Downstream Implications

Committing to Whole-Visit Revisions forecloses automatic server-side combination of concurrent edits and establishes the following obligations for downstream design nodes:

- **`tablet-sync` accommodations**:
  - Persist the server-assigned `revisionId` alongside each cached visit and attach it as `baseRevisionId` when submitting edits (`null` when creating a new visit).
  - Handle submission responses that return `visitStatus: needs_review` and `competingRevisionIds`, surfacing to field workers that their submission was recorded safely on the server and is awaiting coordinator review rather than silently overwriting or being overwritten.
  - Refresh cached visits cleanly once a coordinator resolves competing revisions into a new `currentRevisionId`.
- **`review-export` accommodations**:
  - Query visits in `visitStatus: needs_review` and provide a revision comparison screen where coordinators can inspect the competing complete revisions side by side (including authors, receipt times, and field differences) and submit a unified resolution payload citing `resolvedRevisionIds`.
  - Hold any visit with `visitStatus: needs_review` (`currentRevisionId: null`) out of the Friday partner CSV export so only uncontested or coordinator-resolved visits are exported.
  - Preserve inspectable provenance from an exported CSV row back to its `currentRevisionId`, its `resolvedRevisionIds` (if resolved by a coordinator), and the underlying worker submissions.
```

---

Please let me know if this decision doc and the `record-store` LLD look good, and how you would like to triage the 6 edge-case questions from the Phase 2 probe (fix in the LLD now vs. defer to Open Questions) before we move to Phase 3 (`record-store-specs.md`).