I have written the decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from `docs/intent/record-store/record-store-design.md`.

### `docs/intent/record-store/decisions/concurrent-visit-edits.md`

```markdown
---
node: record-store
---

# Decision: Concurrent Visit Edit Policy

## Context

Field workers collect ~6,000 plot-visit records per season across 320 coastal vegetation plots using 12 shared Android tablets. Tablets routinely operate offline for up to 48 hours. After comparing paper notes or noticing an entry error, two workers on different tablets sometimes update the same visit independently before either tablet syncs.

Each visit record contains a plot reference (`plotId`), `observationDate`, `observers` list, `speciesCovers` list (`speciesCode` and `coverPercent`), and free-text `notes`. A regional science partner receives a reviewed CSV every Friday, and two coordinators resolve questions about submitted observations before export.

Because updates can arrive days after the worker fetched the starting visit state, server receipt order does not indicate which observation is scientifically authoritative. At the same time, edits within a visit can have unstated ecological coupling: changing a species identification often changes how cover percentages or field notes should be interpreted, whereas fixing a misspelled observer name and adding an omitted species may be independent. The record store must define how concurrent edits to the same visit are represented, what enters a current record, and what review work is produced before the Friday export.

## Decision Elements

### Gates

- **No silent loss of submitted edits** (inherited from HLD tenet *Do not silently discard a submitted edit*): Every accepted worker submission must remain stored and attributable. An approach that overwrites an earlier or later edit without recording and surfacing the superseded observation is eliminated.

### Weighted Criteria

- **Cross-field scientific integrity (major)** — Derived from the HLD Non-Goal *Automated botanical validation or inference of scientific intent* and the tenet *Keep the path from a submitted observation to an exported value inspectable*. The policy must not synthesize a record that combines scientifically coupled edits (such as a revised species identification from one worker with a cover estimate or habitat note written for the original identification by another worker) without human review.
- **Rule and tooling maintenance burden (major)** — Derived from the HLD tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator*. The policy should minimize ongoing maintenance of schema-specific merge rules, per-field provenance tracking, and complex client-side diff state machines.
- **Coordinator review queue volume (moderate)** — Derived from the HLD goal *Make reviewable problems visible before the Friday export* and the two-coordinator staffing constraint. Concurrent edits to unrelated fields of the same visit (for example, one worker correcting `observers` while another appends to `notes`) should ideally avoid unnecessary manual review before the Friday export.
- **Inspection clarity from submission to export (moderate)** — Derived from the HLD tenet *Keep the path from a submitted observation to an exported value inspectable*. Coordinators and auditors should be able to trace any exported CSV row directly to the submitted observation(s) and coordinator resolution that produced it.

## Options in the Domain

### Whole-Visit Revisions

Each accepted submission stores a complete visit payload as an immutable revision and names the `baseRevisionId` the worker started from (`null` for initial creation). When a submission's `baseRevisionId` matches the visit's sole active head revision, the new revision supersedes it and the visit remains `resolved`. When two or more submissions branch from the same `baseRevisionId` (or arrive concurrently with `baseRevisionId: null` for the same `visitId`), all resulting head revisions remain active and the visit enters `needs_review`. A coordinator resolves the conflict by selecting one competing revision or submitting a synthesized whole-visit payload that supersedes the competing heads. Visits in `needs_review` have no single authoritative current revision and are held out of the Friday CSV export until resolved.

**Demonstration**

Worker A and Worker B both sync revision `R1` before going offline:
- Worker A submits `R2` (`baseRevisionId: R1`) revising `Spartina alterniflora` (40%) to `Spartina patens` (40%) and updating `notes`.
- Worker B submits `R3` (`baseRevisionId: R1`) adjusting `Spartina alterniflora` cover to 55% based on a recount.
- Both `R2` and `R3` become competing active heads; the visit status becomes `needs_review` and is excluded from CSV export until a coordinator resolves `[R2, R3]` into `R4`.

**Analysis**

- **No silent loss of submitted edits (gate)**: **passes** — Every submission is retained as an immutable revision in the visit's lineage; concurrent edits become competing active heads rather than overwriting one another.
- **Cross-field scientific integrity (major)**: **strong** — Never combines fields across independent submissions automatically. Coupled changes across `speciesCovers`, `observationDate`, and `notes` stay together inside the revision the worker submitted until a coordinator inspects the competing revisions side by side.
- **Rule and tooling maintenance burden (major)**: **strong** — Requires only `baseRevisionId` parent tracking on the server and tablets, with no field-specific merge heuristics or per-cell provenance schemas to maintain as survey fields evolve.
- **Coordinator review queue volume (moderate)**: **weak** — Any concurrent edit to the same visit produces a `needs_review` conflict, even when one worker only fixed an observer name and another edited `notes`.
- **Inspection clarity from submission to export (moderate)**: **strong** — Every exported visit points to a single authoritative revision (`currentRevisionId`), which is either one worker's exact submission or an explicit coordinator resolution naming the competing revisions it superseded.

**Summary**: Preserves whole-visit scientific coherence and keeps server and tablet state simple, at the cost of routing every concurrent same-visit edit—including disjoint field edits—to the coordinator review queue.

### Field-Aware Three-Way Merge

Each tablet retains a full snapshot of the base revision it started from and submits either a structured field diff or the base snapshot alongside the updated visit. When concurrent edits arrive against the same base state, the record store performs a three-way merge using field-type rules: scalar fields (`observationDate`, `notes`), set/list fields (`observers`), and keyed collection entries (`speciesCovers` keyed by `speciesCode`). If two submissions modify disjoint fields or disjoint species codes, the store automatically combines them into a merged current revision ready for export. If both modify the same scalar field or the same `speciesCode` entry with different values, the store flags only the overlapping fields for coordinator resolution and tracks field-level provenance on the resulting record.

**Demonstration**

Worker A and Worker B both start from base snapshot `R1`:
- Worker A adds observer `"J. Morales"` to `observers`.
- Worker B adds `{ speciesCode: "SALVIR", coverPercent: 15 }` to `speciesCovers`.
- Because `observers` and `speciesCovers["SALVIR"]` are disjoint under the merge rules, the server automatically produces a combined current record containing both changes without queuing the visit for coordinator review.

**Analysis**

- **No silent loss of submitted edits (gate)**: **passes** — Original submissions are preserved in history, disjoint edits are retained in the combined record, and overlapping edits to the same field are routed to coordinator review.
- **Cross-field scientific integrity (major)**: **weak** — Automated merge rules only detect structural overlap on the same field key. If Worker A reclassifies a species (deleting `SPAL` and adding `SPPA`) while Worker B updates `notes` or total cover commentary assuming `SPAL` is present, the changes touch distinct keys and merge automatically into a scientifically inconsistent record without coordinator review.
- **Rule and tooling maintenance burden (major)**: **weak** — Requires defining and maintaining merge semantics for scalars, observer lists, and species arrays, storing full base snapshots on tablets, and maintaining field-level provenance metadata across the store and review UI.
- **Coordinator review queue volume (moderate)**: **strong** — Automatically resolves concurrent edits that touch unrelated fields (such as observer list fixes vs. species cover additions), keeping routine non-overlapping corrections out of the Friday review bottleneck.
- **Inspection clarity from submission to export (moderate)**: **partial** — An exported row may be an automated composite that no single worker or coordinator ever viewed as a whole, requiring field-level provenance inspection to understand how each column value originated.

**Summary**: Minimizes coordinator review work for disjoint field edits, but risks silently combining scientifically coupled changes across different fields and requires sustained maintenance of merge rules and field-level provenance.

### Last-Write-Wins by Server Receipt Time

The record store retains all submitted payloads in an audit log, but whichever submission arrives at the server latest (or carries the latest device timestamp) automatically becomes the current authoritative record for export, without tracking base revisions or queuing conflicts for review.

**Analysis**

- **No silent loss of submitted edits (gate)**: **eliminated** — With tablets offline for up to 48 hours, a tablet syncing an older draft after another worker's correction silently replaces the correction in the current record and Friday CSV export without alerting a coordinator.

## Selection

**Selected option: Whole-Visit Revisions.**

Whole-Visit Revisions wins because **cross-field scientific integrity (major)** and **rule and tooling maintenance burden (major)** outweigh **coordinator review queue volume (moderate)** at the team's scale (~6,000 visits per season across 320 plots). In vegetation surveys, species identifications, cover percentages, and habitat notes frequently depend on one another in ways schema rules cannot detect; silently synthesizing a composite visit across two independent edits risks exporting scientifically invalid records to the regional science partner. Accepting a larger coordinator review queue when two tablets edit the same visit offline is preferable to maintaining field-merge rules that can combine scientifically coupled edits without human notice.

This decision turns on three HLD tenets and one non-goal:
- **Do not silently discard a submitted edit**: Every submitted visit revision is preserved intact, and concurrent edits become competing active heads rather than overwriting one another.
- **Keep the path from a submitted observation to an exported value inspectable**: Every exported visit traces to a single whole revision submitted by a worker or explicitly resolved by a coordinator.
- **Prefer workflows two coordinators can operate without a dedicated systems administrator**: Avoids maintaining custom three-way merge rules and field-level provenance machinery.
- **Non-Goal — Automated botanical validation or inference of scientific intent**: Refuses to infer that edits to different fields of the same visit are scientifically independent.

Field-Aware Three-Way Merge remains the credible alternative to revisit if seasonal visit volume or concurrent same-visit editing grows enough that two coordinators cannot clear the review queue before the Friday export.

### Downstream Obligations

Committing to Whole-Visit Revisions forecloses automatic server-side merging of disjoint field edits and establishes the following requirements for sibling nodes:

- **`tablet-sync`**:
  - Persist the server-assigned `revisionId` alongside each locally stored visit and include it as `baseRevisionId` (`null` on initial creation) in every visit submission envelope.
  - Retain full whole-visit draft payloads and idempotency keys across restarts and 48-hour offline windows rather than field-level diffs or full base snapshots.
  - Handle submission responses where `status` is `needs_review` by surfacing to the field worker that competing revisions exist on the server and are awaiting coordinator review, rather than treating the response as a transport error or silently overwriting local state.
- **`review-export`**:
  - Provide a coordinator revision comparison screen that loads all `competingRevisions` for `needs_review` visits side by side and submits the coordinator's chosen or synthesized whole-visit payload along with the `resolvedRevisionIds` set.
  - Hold all visits with `status == needs_review` (`currentRevision == null`) out of the Friday CSV export, exporting only `resolved` visits using their single authoritative `currentRevision`.
```

---

### Remaining Phase 2 Check

Before we move to Phase 3 (`record-store-specs.md`), does this decision doc and the `record-store-design.md` LLD look good, and would you like to settle any of the 6 edge-case probe items from above in the LLD now or keep them deferred?