Wrote `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the `Concurrent visit edit policy` row in `docs/intent/record-store/record-store-design.md`.

### `docs/intent/record-store/decisions/concurrent-visit-edits.md`

```markdown
---
node: record-store
---

# Decision: Concurrent Visit Edit Handling

## Context

Seasonal field crews (24 workers sharing 12 Android tablets) collect roughly 6,000 plot-visit records per season across 320 permanent coastal vegetation plots. Tablets routinely remain offline for up to 48 hours, and workers independently revise the same visit after comparing paper or verbal field notes. Because edits derived from the same fetched starting state can reach the server days apart, server receipt order carries no information about which observation is more accurate. Two coordinators review flagged records ahead of a weekly Friday CSV export to a regional science partner.

Each visit record contains a plot reference (`plot_id`), `observation_date`, `observers` list, `species_cover` estimates, and free-text `notes`. Concurrent edits fall into two domain patterns that look similar structurally:

- **Independent corrections**: one tablet corrects an observer's name spelling while another adds an omitted species entry.
- **Scientifically coupled corrections**: one tablet reclassifies a misidentified taxon and adjusts `notes` to explain the voucher check while another adjusts cover percentages or species entries under the prior identification. Field names alone do not reveal when two distinct fields form a single botanical judgment.

Every credible concurrency design in this domain must retain all original worker submissions intact with author and receipt metadata and must never overwrite an earlier edit based on arrival order. Within that boundary, `record-store` must choose whether concurrent edits derived from the same base state remain whole-visit competing revisions for coordinator resolution or undergo automated field-level three-way merging. That choice sets the public submission, retrieval, and resolution contracts that `tablet-sync` and `review-export` build around.

## Decision Elements

- **Cross-field scientific coherence** (**major**) — Visit fields can carry coupled ecological meaning across `species_cover`, `notes`, `observation_date`, and `observers`. Combining changes across submissions without human inspection can synthesize a composite visit that neither observer recorded, running counter to the HLD non-goal against *automated botanical validation or inference of scientific intent* and the tenet *Do not silently discard a submitted edit* as applied to whole-observation meaning.
- **Coordinator review volume and pre-export throughput** (**major**) — Two coordinators clear unresolved observations across ~6,000 seasonal visits before each Friday export, engaging the tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator*. Because unresolved visits are held out of the partner CSV, escalating routine non-overlapping edits to manual review expands the weekly queue and delays export eligibility.
- **End-to-end provenance inspectability** (**moderate**) — Derives from the tenet *Keep the path from a submitted observation to an exported value inspectable*. Coordinators and partner scientists need a direct, auditable trace from any exported CSV row back to the worker submission(s) and coordinator decision that produced it.
- **Merge-rule maintenance and schema evolution cost** (**moderate**) — Engages *Prefer workflows two coordinators can operate without a dedicated systems administrator*. A visit combines scalar values, an observer list, and structured species-cover entries; specifying, testing, and maintaining deterministic conflict and merge semantics across heterogeneous types—and updating them if survey fields expand—adds persistent engineering and operational surface.
- **Manual reconciliation slip risk on multi-species visits** (**moderate**) — Vegetation plots often list many species. When disjoint edits must be combined by hand rather than deterministically, a coordinator working through a Friday queue can inadvertently drop a small edit from one branch while adopting changes from another unless comparison tooling surfaces per-field differences clearly.
- **Offline tablet state and sync payload complexity** (**minor**) — Derives from *Let field workers continue collecting observations without connectivity*. Tablets must persist draft lineage across restarts and 48-hour offline windows; tracking full base snapshots and structured field deltas adds client sync state compared to storing a single base revision identifier, while wire-size differences on structured text-and-number records (without photographs) are small.

## Options in the Domain

### Whole-Visit Revisions

**Description**

Every accepted worker submission and coordinator resolution stores an immutable, complete visit payload as a node in a per-visit revision graph. When editing an existing visit, a tablet sends the complete updated visit payload along with the `base_revision_id` it started from. If `base_revision_id` matches the visit's sole active head, the new revision supersedes it linearly and becomes the new `current_revision` (`status: resolved`). If `base_revision_id` has already been superseded, both branches remain active heads (`status: unresolved`, `current_revision: null`), regardless of which fields changed. `review-export` withholds `unresolved` visits from the CSV and presents competing whole-visit revisions alongside their common base revision so a coordinator can select one revision or submit a manually reconciled whole-visit payload naming all superseded `contributing_revision_ids`.

**Demonstration**

Base revision `R1` records `observers: ["M. Ortiz"]`, `species_cover: [{"species": "Spartina alterniflora", "cover": 40}]`, `notes: ""`.
- *Unrelated edits*: Tablet 1 submits `R2` (`base_revision_id: R1`) adding `"J. Chen"` to `observers`. Tablet 2, still offline from `R1`, submits `R3` adding `{"species": "Distichlis spicata", "cover": 15}`. Both `R2` and `R3` become active competing heads (`status: unresolved`); a coordinator reviews the pair against `R1` and submits `R4` containing both additions.
- *Coupled edits*: Tablet 1 submits `R2` (`base_revision_id: R1`) changing *Spartina alterniflora* (40%) to *Spartina patens* (40%) after checking a pressed specimen. Tablet 2 submits `R3` (`base_revision_id: R1`) leaving *Spartina alterniflora* at 40% and adding `notes: "S. alterniflora culms grazed at plot edge"`. `record-store` holds `[R2, R3]` as `unresolved` so a coordinator inspects the contradiction between the reclassified species and the note before export.

**Analysis**

- **Cross-field scientific coherence**: **strong** fit — No automated cross-submission field combination occurs; every `resolved` record is either a single worker's intact visit snapshot or a complete visit explicitly reviewed and submitted by a coordinator.
- **Coordinator review volume and pre-export throughput**: **weak** fit — Every concurrent edit pair from the same base revision enters the coordinator review queue and blocks CSV export of that visit, even when edits touch disjoint fields such as `observers` and `species_cover`.
- **End-to-end provenance inspectability**: **strong** fit — Every exported visit maps to a single `revision_id` authored by one worker or resolved by one coordinator with explicit links to `contributing_revision_ids`, without per-field source reconstruction.
- **Merge-rule maintenance and schema evolution cost**: **strong** fit — Concurrency detection depends only on `base_revision_id` and active head lineage; adding or changing visit payload fields requires validation updates only, with zero server merge rules.
- **Manual reconciliation slip risk on multi-species visits**: **partial** fit — Coordinators manually construct or verify the combined whole-visit payload when reconciling disjoint edits, relying on `review-export`'s diff presentation against the base revision to avoid omitting non-overlapping changes.
- **Offline tablet state and sync payload complexity**: **strong** fit — `tablet-sync` stores only `base_revision_id` alongside the local working draft and transmits a complete structured visit document (~1–5 KB) per submission.

**Summary**

Preserves whole-observation integrity, lineage simplicity, and thin client/server contracts at the cost of routing all concurrent same-base edits—including disjoint field fixes—through manual coordinator review.

### Field-Aware Three-Way Merge

**Description**

Each edit is evaluated as a structured change set against the exact base state the worker started from. Tablets retain the immutable base snapshot alongside local edits and submit either structured field-level operations (scalar replacements, observer set additions/removals, species-keyed upserts/deletions) or the base revision reference paired with structured changes. When a submission arrives against a superseded base revision, `record-store` computes a three-way merge between the base state, the current head, and the incoming submission using deterministic per-field rules: changes to disjoint top-level fields or distinct species keys combine automatically into a new merged current record (`status: resolved`) with field-level provenance linking each value to its contributing submission ID. Only overlapping changes to the same scalar field, observer entry, or species entry produce field-level conflicts (`status: unresolved`) held out of CSV export for coordinator resolution. All original submissions remain stored intact.

**Demonstration**

Starting from the same `R1`:
- *Unrelated edits*: Tablet 1 adds `"J. Chen"` to `observers`; Tablet 2 adds `{"species": "Distichlis spicata", "cover": 15}` to `species_cover`. Because `observers` and the `Distichlis spicata` key are disjoint relative to `R1`, `record-store` automatically produces a merged `resolved` record ready for Friday's CSV without coordinator intervention, recording `R2` as provenance for `observers` and `R3` for `Distichlis spicata`.
- *Coupled edits*: Tablet 1 deletes `Spartina alterniflora` and inserts `Spartina patens` (40%); Tablet 2 leaves `Spartina alterniflora` unchanged and updates `notes: "S. alterniflora culms grazed at plot edge"`. Because Tablet 2 did not modify the `Spartina alterniflora` entry and Tablet 1 did not modify `notes`, the changes are structurally disjoint: `record-store` auto-merges them into an export-eligible `resolved` record pairing `Spartina patens` in `species_cover` with a note describing grazed `S. alterniflora`.

**Analysis**

- **Cross-field scientific coherence**: **weak** fit — Structurally disjoint edits across coupled fields (such as species replacement in `species_cover` paired with taxon-specific commentary in `notes`, or `observation_date` paired with `observers`) combine automatically into `resolved` export-eligible records without human review.
- **Coordinator review volume and pre-export throughput**: **strong** fit — Disjoint concurrent corrections auto-merge into export-ready visits immediately, reserving the two coordinators' queue for direct collisions on the same field or species entry.
- **End-to-end provenance inspectability**: **partial** fit — Original submissions are preserved, but an auto-merged current visit is a machine-assembled composite whose inspection requires field- and entry-level provenance metadata and UI views showing which submission contributed each value.
- **Merge-rule maintenance and schema evolution cost**: **weak** fit — Requires specifying and maintaining three-way diff and merge rules across scalars, observer lists (set vs. ordered semantics), and species entries (key identity vs. rename vs. duplicate strata), and re-auditing those rules whenever survey fields change.
- **Manual reconciliation slip risk on multi-species visits**: **strong** fit — Non-overlapping edits across large species lists merge deterministically in `record-store`, asking coordinators to adjudicate only the specific colliding field or species entry.
- **Offline tablet state and sync payload complexity**: **partial** fit — Wire payloads for small edits are compact, but `tablet-sync` must persist full immutable base snapshots alongside drafts across 48-hour offline windows and encode structured deltas (or rely on server-side diffing coupled to field identity rules).

**Summary**

Minimizes coordinator queue size and manual synthesis effort on unrelated edits, at the cost of maintained per-field merge rules, per-field provenance machinery, and silent auto-combination of botanically coupled edits across distinct fields.

## Selection

**Whole-Visit Revisions** is selected.

Between the two **major** criteria, **Cross-field scientific coherence** outweighs **Coordinator review volume and pre-export throughput** for this survey workflow. At ~6,000 total visits per season across 24 workers, concurrent offline edits to the *same* visit represent a subset of submissions rather than the common path, whereas silently exporting a synthetically merged visit whose species list contradicts its field notes undermines partner trust in the dataset without raising any visible signal. That choice aligns directly with the HLD non-goal against *automated botanical validation or inference of scientific intent* and the tenets *Do not silently discard a submitted edit* and *Keep the path from a submitted observation to an exported value inspectable*. On the tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator*, the decision deliberately accepts more manual review items in exchange for a rule-free lineage model (**Merge-rule maintenance and schema evolution cost**) whose behavior coordinators can understand without diagnosing field-merge edge cases.

### When to Reconsider Field-Aware Three-Way Merge

`Field-Aware Three-Way Merge` (or a narrowly scoped variant) remains a credible alternative if operational conditions shift the balance between the two major criteria:

1. **Unsustainable disjoint-edit queue volume**: Production sync patterns show frequent concurrent edits to strictly administrative or independent fields (for example, routine post-sync observer-list corrections colliding with unrelated species additions) that consistently exceed what two coordinators can resolve before the Friday export cutoff.
2. **Observed manual synthesis defects**: Coordinators reconciling competing whole-visit snapshots on species-rich plots repeatedly drop non-overlapping edits despite diff highlighting in `review-export`.
3. **Explicit schema separation**: Future survey revisions cleanly partition uncoupled administrative metadata from botanical observation fields so automated merging can be restricted to fields with no cross-field scientific coupling.

Because `record-store` retains every immutable worker submission and its `base_revision_id`, migrating to or layering field-level merge assistance later would not invalidate historical lineage data.

### Implications and Downstream Accommodations

Committing to whole-visit revisions forecloses automatic CSV export eligibility whenever two tablets edit the same base revision concurrently, even on unrelated fields, and forecloses partial/delta-only visit updates that omit unchanged visit fields.

Sibling nodes must accommodate the following obligations:

- **`tablet-sync`**:
  - Persist the server-assigned `revision_id` of the fetched or last-accepted visit as `base_revision_id` (`null` for newly created offline visits) alongside local draft state across app restarts and multi-day offline periods (*Let field workers continue collecting observations without connectivity*).
  - Transmit complete visit payloads paired with `base_revision_id` and a durable `idempotency_key` on submission and retry.
  - Distinguish linear acceptance (`status: resolved`, updating the local base to the returned `revision_id`) from competing-branch acceptance (`status: unresolved`), displaying pending competing revisions clearly so field workers see why their edit is awaiting coordinator review rather than assuming it silently replaced or was replaced by another tablet's edit.
- **`review-export`**:
  - Exclude all `status: unresolved` visits from the weekly partner CSV export and surface unresolved queue counts prominently ahead of the Friday export.
  - Mitigate **Manual reconciliation slip risk on multi-species visits** by retrieving revision history alongside `competing_revisions`, locating the common ancestor `base_revision_id`, and highlighting per-field and per-species differences from that base across all competing heads—allowing a coordinator to either adopt one revision intact or synthesize a reconciled whole-visit payload without overlooking unrelated edits.
  - Submit coordinator resolutions containing the complete approved visit payload and the exact `contributing_revision_ids` inspected, and handle stale-head conflict responses by refreshing the comparison view if another tablet submission or coordinator resolution lands mid-review.
```

---

**Phase 2 Stop — Ready for your check:**
1. Does the decision doc capture the tradeoff, reconsideration triggers, and downstream obligations on `tablet-sync` and `review-export` as you want them?
2. For `record-store-design.md`, would you like to settle any of the six edge-case items from above now, defer them to `Open Questions & Future Decisions`, or approve Phase 2 as-is and move to Phase 3 (`docs/intent/record-store/record-store-specs.md`)?