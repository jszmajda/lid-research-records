I have written the decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the `Decisions & Alternatives` table in `docs/intent/record-store/record-store-design.md`.

### Decision Doc (`docs/intent/record-store/decisions/concurrent-visit-edits.md`)

```markdown
---
node: record-store
---

# Decision: Concurrent Visit Edit Policy

## Context

Twenty-four seasonal field workers share 12 Android tablets to survey 320 permanent coastal vegetation plots, producing roughly 6,000 visit records per season. Tablets frequently remain offline for up to 48 hours. While disconnected, two workers on different tablets may independently edit the same plot visit after comparing field notes—for example, one worker correcting an observer list while another revises a species identification and cover percentage.

Every visit record contains five structured areas: plot reference (`plot_id`), observation date, observer names, species cover estimates, and free-text notes. A reviewed CSV is delivered to a regional science partner every Friday, with two coordinators responsible for resolving questions about submitted observations.

In compliance with the HLD tenet *Do not silently discard a submitted edit*, the record store preserves every accepted worker submission and never uses server receipt order to overwrite one worker's observation with another's. The open design question is how `record-store` models concurrent edits that branch from the same starting visit state, how much reconciliation happens automatically versus through coordinator review, and what contracts that choice imposes on `tablet-sync` and `review-export`.

## Decision Elements

### Weighted Criteria

- **Preservation of cross-field scientific coherence (major)** — Derived from the HLD non-goal excluding *automated botanical validation or inference of scientific intent* and the tenet *Keep the path from a submitted observation to an exported value inspectable*. Botanical edits within a single visit often span multiple fields: re-identifying a specimen in `species_cover` may pair with an updated total cover estimate or an explanatory remark in `notes`. The concurrency model must evaluate whether combining fields from separate submissions could synthesize a scientifically invalid visit record that neither worker observed.
- **Coordinator review throughput before the Friday export (major)** — Derived from the HLD tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator* and the goal *Make reviewable problems visible before the Friday export*. Because two coordinators must clear pending conflicts before generating the weekly partner CSV, the concurrency model affects how many concurrent edits become manual review items each week.
- **Rule maintenance and operational simplicity (moderate)** — Derived from the HLD tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator*. Automatic reconciliation across scalar fields, set-like lists (`observers`), and keyed domain records (`species_cover`) requires explicit merge rules and ongoing maintenance whenever survey fields evolve.
- **Inspectability of export provenance (moderate)** — Derived from the HLD tenet *Keep the path from a submitted observation to an exported value inspectable*. Coordinators and science partners need a clear lineage from any exported CSV row back to the specific worker submission(s) and coordinator judgment that produced it.
- **Tablet sync state and payload complexity (minor)** — Derived from the HLD tenet *Let field workers continue collecting observations without connectivity*. The concurrency model determines whether offline tablets track a single base revision identifier per visit or store full base snapshots and compute structured field diffs across multi-day offline windows.

## Options in the Domain

### Option 1: Whole-Visit Revisions

#### Description

Each accepted submission or coordinator resolution produces an immutable, complete visit revision identified by a `revision_id`. When a tablet downloads a visit, it records that visit's `revision_id` as its `base_revision_id`. When a worker submits an edit, the tablet sends the `base_revision_id` and the complete updated visit payload.

If the visit is currently `resolved` and the submission's `base_revision_id` matches the visit's `current_revision`, the submission advances `current_revision` directly without review. If another edit has already advanced `current_revision` (or if the visit is already `unresolved`), the server records the incoming payload intact as a competing whole-visit revision and transitions the visit to `review_status: unresolved`. A coordinator resolves the conflict by comparing the competing whole-visit revisions and submitting a single authoritative whole-visit payload referencing all `contributing_revision_ids`.

#### Demonstration

```json
{
  "visit_id": "b6f8c2d0-4a1e-4b9b-9c3d-1e2f3a4b5c6d",
  "idempotency_key": "8f14e45f-ceea-467a-a839-2b5f6c7d8e9f",
  "base_revision_id": "rev-01",
  "payload": {
    "plot_id": "2c9f0b1a-7d3e-4f5a-8b1c-9d0e1f2a3b4c",
    "observation_date": "2026-06-14",
    "observers": ["A. Rivera", "M. Chen"],
    "species_cover": [
      { "species_code": "SPAL", "cover_pct": 45 },
      { "species_code": "SAPA", "cover_pct": 20 }
    ],
    "notes": "Re-assigned Salicornia patch to SAPA after checking voucher."
  }
}
```

#### Analysis

- **Preservation of cross-field scientific coherence**: **strong** — Every revision is stored, reviewed, and promoted as a complete visit record authored by a worker or consciously synthesized by a coordinator; the server never combines fields across independent submissions automatically.
- **Coordinator review throughput before the Friday export**: **weak** — Any concurrent edit to the same visit—even when one worker only fixes a typo in `observers` and another adds a remark in `notes`—produces competing revisions that a coordinator must resolve before the visit can be exported.
- **Rule maintenance and operational simplicity**: **strong** — The server checks only whether `base_revision_id` matches `current_revision` on a `resolved` visit; no per-field diffing or collection-merge rules are implemented or maintained.
- **Inspectability of export provenance**: **strong** — Every exported visit traces to a single whole-visit revision whose origin is either one worker submission or one coordinator resolution citing specific `contributing_revision_ids`.
- **Tablet sync state and payload complexity**: **strong** — Tablets store only the `base_revision_id` alongside the current local draft and transmit the whole visit payload (~1–2 KB) on sync.

#### Summary

Guarantees that scientifically coupled fields are never silently mixed and keeps storage, sync, and provenance simple, at the cost of routing all concurrent edits to the same visit through coordinator review.

### Option 2: Field-Aware Three-Way Merge

#### Description

Each tablet retains a complete snapshot of the base visit state from which a local edit began. Upon submission, the client (or server, comparing the submitted state against the stored base snapshot) computes structured changes per field: scalar replacements for `observation_date` and `notes`, set additions/removals for `observers`, and per-species entry changes for `species_cover`.

When two concurrent edits branch from the same base state, the record store applies deterministic three-way merge rules. If the two edits touch disjoint fields or non-overlapping collection entries (for example, one modifies `observers` while the other modifies `notes`), the server automatically merges them into a combined current visit record and marks it ready for export. Only overlapping changes to the same field or species entry transition the visit into coordinator review. Even if the team later required coordinator sign-off on auto-merged records, pre-computing the field merge would still separate clean disjoint merges from true field collisions.

#### Demonstration

```json
{
  "visit_id": "b6f8c2d0-4a1e-4b9b-9c3d-1e2f3a4b5c6d",
  "idempotency_key": "8f14e45f-ceea-467a-a839-2b5f6c7d8e9f",
  "base_snapshot_id": "snap-01",
  "changes": {
    "observers": { "add": ["M. Chen"], "remove": [] },
    "species_cover": {
      "upsert": [{ "species_code": "SAPA", "cover_pct": 20 }],
      "remove": ["SAL-SP"]
    }
  }
}
```

#### Analysis

- **Preservation of cross-field scientific coherence**: **weak** — Disjoint field changes merge automatically without semantic awareness; for example, one worker changing a species entry in `species_cover` and another editing `notes` or `observation_date` under a different assumption are combined into a hybrid visit record without coordinator review.
- **Coordinator review throughput before the Friday export**: **strong** — Concurrent edits to unrelated fields resolve automatically on ingest, keeping those visits eligible for the Friday export and reserving coordinator time for direct field collisions.
- **Rule maintenance and operational simplicity**: **weak** — Requires defining, testing, and maintaining merge semantics for scalar fields, observer sets, and keyed species-cover entries, as well as handling multi-way merges when three or more tablets sync offline edits.
- **Inspectability of export provenance**: **partial** — Explaining an exported row requires field-level provenance metadata linking individual cells (`observers` vs. `species_cover` vs. `notes`) to different submissions.
- **Tablet sync state and payload complexity**: **partial** — Tablets must retain immutable base snapshots alongside working drafts and construct or reconcile field-level diffs across multi-day offline periods.

#### Summary

Minimizes coordinator review volume by automatically combining non-overlapping field edits, at the cost of maintaining collection merge rules, tracking field-level provenance, and risking silent combination of scientifically coupled edits across distinct fields.

## Selection

**Chosen: Option 1 — Whole-Visit Revisions.**

### Why Option 1 Wins

The decision turns on **Preservation of cross-field scientific coherence (major)** and the HLD non-goal excluding *automated botanical validation or inference of scientific intent*, reinforced by *Keep the path from a submitted observation to an exported value inspectable*. In vegetation surveys, fields that are structurally separate in JSON (`species_cover`, `notes`, `observation_date`, `observers`) are frequently coupled in field practice. A three-way merge that treats disjoint field names as independent edits can synthesize a record that misrepresents the plot without raising a review flag. Whole-visit revisions ensure that whenever two workers independently edit the same visit from the same starting revision, a coordinator sees each worker's complete submitted visit in context before deciding the authoritative record.

This choice deliberately accepts a weaker score on **Coordinator review throughput before the Friday export (major)** in exchange for scientific integrity and **Rule maintenance and operational simplicity (moderate)**. At 6,000 visits per season across 320 plots, concurrent post-hoc edits to the exact same visit are a small fraction of total submissions, making a slightly larger review queue manageable for two coordinators without maintaining custom field-merge logic.

### Why Option 2 Remains a Credible Alternative

Option 2 (Field-Aware Three-Way Merge) is not rejected for losing data—it preserves all raw submissions and could even be paired with coordinator approval of merged previews. It remains the primary alternative to revisit if operational experience shows that routine, scientifically unrelated edits (such as one tablet appending a secondary observer name while another fixes a plot note) generate more unresolved visits before the Friday cutoff than two coordinators can clear. Re-evaluating in favor of Option 2 would require defining explicit coupling boundaries (for example, allowing automatic merge of `observers` changes while still treating `species_cover` and `notes` as a single coupled unit).

### Downstream Implications and Obligations

Committing to whole-visit revisions forecloses automatic server-side combination of concurrent edits to the same visit and establishes the following downstream obligations:

- **`tablet-sync`**:
  - Store the server-assigned `revision_id` of each downloaded or accepted visit and attach it as `base_revision_id` (`null` on initial creation) when submitting local edits.
  - Send the complete visit payload (`VisitPayload`) together with a client-generated `idempotency_key` on every submission attempt rather than field-level patches.
  - Handle acceptance responses where `review_status` is `unresolved` by informing the field worker that their submission was safely recorded as a competing revision pending coordinator review, rather than overwriting local state silently or treating the sync as failed.
- **`review-export`**:
  - Provide a coordinator review queue and comparison view that displays all active competing whole-visit revisions side by side (along with their `author_id`, `received_at`, `base_revision_id`, and intact payloads) so coordinators can either select one revision intact or author a reconciled whole-visit payload.
  - Submit coordinator resolutions citing the full set of `contributing_revision_ids` superseded by the decision.
  - Hold any visit with `review_status: unresolved` out of the Friday partner CSV export until a coordinator resolution returns the visit to `review_status: resolved`.
```

---

### Remaining Phase 2 Review Items

Does this decision doc and the updated `record-store-design.md` look good to approve for Phase 2, and would you like to settle any of the edge-case probe items (such as stale conflict sets on resolution, competing revision set membership, `base_revision_id` validation, or `plot_id` immutability) before we move to **Phase 3 (`record-store-specs.md`)**?