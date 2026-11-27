I have completed the decision documentation and updated the `record-store` design.

The standalone decision doc has been created at `docs/intent/record-store/decisions/concurrency-policy.md` and linked from the Decisions & Alternatives table in `docs/intent/record-store/record-store-design.md`.

---

### Decision Doc (`docs/intent/record-store/decisions/concurrency-policy.md`)

```markdown
---
node: record-store
---

# Decision: Concurrency Policy for Independent Visit Edits

## Context

In TidePlot, 24 seasonal field workers share 12 Android tablets to survey 320 permanent coastal vegetation plots, producing approximately 6,000 visit records per season. Tablets frequently operate disconnected for up to 48 hours. Field workers regularly compare field notes at the end of a shift and independently submit corrections or additions for the same plot visit.

Because these edits derive from identical starting states and arrive days apart in arbitrary order, the server cannot treat arrival sequence as an indicator of scientific authority. An observation visit record contains interrelated biological and metadata fields: plot ID, observation date, observer rosters, species determinations, percentage cover estimates, and field condition notes.

The decision addresses how the record store handles concurrent, independently submitted edits to the same visit. At stake is scientific data integrity: botanical fields are tightly coupled (e.g., revising a species determination interacts with valid cover estimates and observer roles), so resolving concurrent edits incorrectly can corrupt scientific data, violate the tenet of never silently discarding edits, or overwhelm the two coordinators responsible for preparing reviewed weekly CSV exports for the regional science partner.

## Decision Elements

- **Gates**:
  - **No silent data loss** (doc-local and inherited tenet): Any mechanism must preserve all submitted edits and their provenance immutably; submissions derived from the same base state must never overwrite each other without trace. Both options in contention pass this gate.

- **Weighted Criteria**:
  - **Preservation of whole-visit scientific coherence (major)** — derived from HLD tenet *"Keep the path from a submitted observation to an exported value inspectable"* and non-goal *"Automated botanical validation or inference of scientific intent"*. Field observations represent cohesive ecological moments. Modifications to species determinations, cover estimates, or observers often share unexpressed domain intent that field names alone cannot convey.
  - **Operational feasibility for two coordinators (major)** — derived from HLD tenet *"Prefer workflows two coordinators can operate without a dedicated systems administrator"*. The team consists of 24 seasonal workers and only two coordinators. Review mechanisms must avoid brittle automated rule maintenance, opaque algorithmic edge cases, or complex three-way diff troubleshooting.
  - **Review queue volume and export readiness (moderate)** — derived from HLD goal *"Make reviewable problems visible before the Friday export"*. The weekly Friday export deadline to the regional science partner requires that non-conflicting, valid records become export-ready without unnecessary human intervention delaying the pipeline.
  - **Implementation complexity and schema evolution (moderate)** — The engineering effort required to build and maintain the concurrency system, including tablet sync tracking, server-side merge or reconciliation engines, and schema migrations across seasons.
  - **Client storage and bandwidth efficiency (minor)** — Tablets operate on intermittent cellular connectivity and must retain offline data without excessive local storage or transmission overhead.

## Options in the Domain

### Whole-Visit Revisions

#### Description
In whole-visit revisions, each submission carries the complete visit snapshot along with the identifier of the server revision on which it was based (`base_revision_id`). The server tracks visits as a revision tree (a directed acyclic graph). When an incoming submission's `base_revision_id` matches the current single head revision, the visit cleanly advances. When an edit arrives referencing an ancestor revision that is no longer the sole head (or when multiple edits branch from the same base), the server creates competing whole-visit leaf revisions. The visit transitions to `in_review`. No automated field merging is performed, even if the edits modified disjoint fields. Resolution requires a coordinator to explicitly select or synthesize a single authoritative head revision through a side-by-side comparison interface before the visit can be exported.

#### Analysis
- **Gate: No silent data loss**: **passes**. Every submission is stored immutably in the submission log, and all competing leaf revisions exist concurrently in the revision tree until resolved.
- **Preservation of whole-visit scientific coherence (major)**: **strong**. Observations are never fragmented into independent field changes. An observer's submission is preserved as a cohesive ecological snapshot, ensuring species determinations, cover estimates, and observer roles are never mismatched by rule-based combination.
- **Operational feasibility for two coordinators (major)**: **strong**. Coordinators work with complete, familiar visit sheets presented side-by-side rather than troubleshooting merge anomalies or maintaining field-merge precedence rules. The system relies on human botanical judgment rather than algorithmic heuristics.
- **Review queue volume and export readiness (moderate)**: **weak**. Any concurrent submission to a visit triggers review, even when workers edited completely disjoint fields (e.g., Worker A fixed a typo in an observer name while Worker B added an omitted grass species). This maximizes review queue size and holds those visits out of the Friday CSV until coordinators review them.
- **Implementation complexity and schema evolution (moderate)**: **strong**. The server logic is standard optimistic concurrency and branching. No field-by-field merge algorithms, three-way list reconciliation, or schema-aware merge configuration are required. Adding new survey fields in future seasons requires zero merge rule updates.
- **Client storage and bandwidth efficiency (minor)**: **partial**. Tablets must track single scalar `revision_id` tokens. Bandwidth is slightly higher because full visit records are sent rather than field deltas, though complete visit JSON payloads remain small (< 10 KB).

#### Summary
Trades increased human review volume on disjoint field collisions for absolute preservation of scientific coherence and minimal implementation complexity.

---

### Field-Aware Three-Way Merge

#### Description
In a field-aware three-way merge, each edit submission supplies its base snapshot (or base revision ID) along with structured field-level changes or deltas. When concurrent submissions arrive derived from the same base, the server executes domain-specific three-way merge rules across the visit schema:
- Scalar metadata fields (e.g., notes, observation date): combine automatically if only one side modified them; trigger review if both modified them differently.
- Observer rosters (lists): set union or three-way list merge.
- Species records (keyed lists): match by species ID; if Worker A adds Species X and Worker B adds Species Y, both species are included automatically; if both edited the cover estimate for Species X, a field conflict is flagged for review.

Edits on disjoint fields combine automatically into a new merged head revision without coordinator review. Overlapping edits on identical fields route to a review queue with field-level provenance.

#### Analysis
- **Gate: No silent data loss**: **passes**. The server preserves original submission envelopes and provenance logs, recording field-level origins for all merged states.
- **Preservation of whole-visit scientific coherence (major)**: **weak**. Automated merging can combine changes that are syntactically disjoint but ecologically linked. For instance, Worker A might update the observer list because a senior botanist conducted the survey, while Worker B (assuming a junior observer) adjusts species cover estimates based on a different methodology. Combining these automatically produces a record that neither worker actually observed or verified.
- **Operational feasibility for two coordinators (major)**: **partial**. While overall review volume is lower, resolving edge cases requires understanding field-level merge mechanics and tracking down why certain fields were auto-combined. The team must also maintain, test, and audit merge rules whenever the survey protocol evolves.
- **Review queue volume and export readiness (moderate)**: **strong**. Disjoint edits are automatically merged and immediately export-ready, minimizing the number of visits held back from the Friday partner CSV.
- **Implementation complexity and schema evolution (moderate)**: **weak**. Requires building a full three-way merge engine for nested JSON structures (scalars, arrays, keyed entity lists), maintaining field-level provenance metadata, and updating merge logic whenever survey protocols introduce new fields.
- **Client storage and bandwidth efficiency (minor)**: **partial**. Tablets must store base snapshots to compute structured deltas, or upload larger diff envelopes. Transmission payloads are slightly smaller for small deltas, but client-side state tracking is more complex.

#### Summary
Trades scientific coherence risks and merge engine maintenance for a smaller coordinator review queue and faster export readiness on non-overlapping edits.

## Selection

**Whole-Visit Revisions** is selected.

### Why Whole-Visit Revisions Wins
This decision turns directly on the project tenets **"Do not silently discard a submitted edit"**, **"Keep the path from a submitted observation to an exported value inspectable"**, and the non-goal **"Automated botanical validation or inference of scientific intent"**.

In coastal vegetation surveys, scientific credibility rests on the explainability and coherence of the observations. A visit is an empirical unit: percentage cover estimates, species identifications, and observer rosters are interdependent. A field-aware three-way merge can mechanically combine edits without syntactic collision, but in doing so it creates synthetic records that no field worker witnessed. Such automated combinations risk publishing inaccurate data in the weekly partner export.

While whole-visit revisions will generate review work for non-conflicting edits (e.g., adding an observer name while another worker corrects a species cover estimate), this review queue is manageable: 24 workers on 12 tablets across 320 plots produce roughly 6,000 visits per season. Concurrent collisions occur on a minority of visits. Two coordinators can operate a visual side-by-side comparison screen far more reliably than they could audit and maintain automated merge algorithms or clean up erroneously merged scientific records.

### Conditions to Reconsider Field-Aware Three-Way Merge
A future team should reconsider Field-Aware Three-Way Merge if:
1. **Survey scale expands significantly**: If the monitoring program scales from 320 plots to thousands of plots with hundreds of field workers, causing concurrent collisions to overwhelm coordinator review capacity prior to the Friday export deadline.
2. **Edits become predominantly clerical rather than scientific**: If field practice shifts such that concurrent edits almost exclusively touch non-scientific administrative metadata (e.g., plot parking notes, equipment tags, clerical typo fixes) rather than coupled botanical observations.
3. **Formal domain-specific merge schemas are introduced**: If the science partner establishes verified semantic merge ontologies that define safe automated combination boundaries for every field.

### Downstream Contract Obligations

Committing to Whole-Visit Revisions imposes concrete architectural obligations on downstream nodes:

1. **Tablet-Sync Obligations**:
   - **Base Revision Tracking**: Tablets must store the server-provided `revision_id` alongside each cached visit. Edits must supply this identifier as `base_revision_id` in the submission envelope.
   - **Full Snapshot Uploads**: Tablets must submit complete visit records rather than field-level deltas or change logs.
   - **Review State Visibility**: When synchronizing, if a visit has branched into `status: "in_review"`, the tablet must indicate to field workers that competing revisions exist and the record is awaiting coordinator review, preventing local drafts from assuming they are the authoritative head.

2. **Review-Export Obligations**:
   - **Side-by-Side Comparison UI**: The review workflow must present whole-visit diffs between competing revisions, displaying the author, timestamp, observer roster, notes, and individual species cover discrepancies side-by-side.
   - **Resolution Endpoint Consumption**: The review tool must implement `POST /visits/{visit_id}/resolve`, supplying the coordinator ID, the verified whole-visit payload, and the set of resolved competing revision IDs.
   - **Strict Export Quarantine**: The Friday CSV export pipeline must filter strictly for visits with `status: "clean"`. Any visit with unresolved competing revisions (`status: "in_review"`) must be quarantined and withheld from the partner export until explicitly resolved by a coordinator.
```

---

### Phase 2 Boundary Review

With the LLD and decision doc complete:

1. **Edge-Case Triage**: Are there specific edge cases from the probe (e.g., optimistic concurrency check on resolve, late-sync ancestor behavior) you want specified in the LLD before moving forward, or should they be deferred to implementation?
2. **Approval to Proceed**: Do you approve the LLD and decision doc to proceed to **Phase 3 (EARS spec update)** for `record-store`?