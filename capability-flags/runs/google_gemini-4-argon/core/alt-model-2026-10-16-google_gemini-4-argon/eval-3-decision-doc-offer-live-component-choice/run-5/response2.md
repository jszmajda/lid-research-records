I have written `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from the `Decisions & Alternatives` table in `docs/intent/record-store/record-store-design.md`.

### `docs/intent/record-store/decisions/concurrent-visit-edits.md`

```markdown
---
node: record-store
---

# Decision: Concurrent Visit Edits

## Context

Field workers survey 320 permanent coastal vegetation plots using 12 shared Android tablets that can operate offline for up to 48 hours. Workers regularly refine or correct the same plot visit independently after comparing field notes — for example, one worker updates observer names or notes while another revises a species identification and its cover estimate.

Because updates arrive hours or days after their starting state was fetched, server arrival order does not reflect which observation is more accurate. A visit's scientific fields (`plot_id`, `observation_date`, `observers`, `species_cover`, `notes`) can have domain dependencies that are not visible in the schema: changing a species identification often changes how cover percentages or field notes should be interpreted, while other edits (such as fixing an observer's spelling and adding a missed species) are genuinely independent.

The `record-store` concurrency mechanism defines how concurrent edits are persisted, when a visit is considered ready for the Friday partner CSV export versus held for coordinator review, and what metadata `tablet-sync` and `review-export` must carry.

## Decision Elements

### Gates

- **Preserve all submitted edits** *(inherited from HLD tenet: "Do not silently discard a submitted edit")*: Every accepted worker submission must remain intact and recoverable in the store's history; arrival order alone may never overwrite a concurrent edit.

### Weighted Criteria

- **Scientific integrity across coupled fields (major)** *(derives from HLD Non-Goal: "Automated botanical validation or inference of scientific intent" and HLD tenet: "Keep the path from a submitted observation to an exported value inspectable")*: Avoid producing an exported visit record whose combined field values were never observed or approved together as a coherent scientific record.
- **Coordinator review workload before Friday export (major)** *(derives from HLD Goal: "Make reviewable problems visible before the Friday export" and HLD tenet: "Prefer workflows two coordinators can operate without a dedicated systems administrator")*: Keep the weekly volume of unresolved visits manageable for two coordinators preparing the Friday partner CSV across ~6,000 seasonal plot visits.
- **Rule maintenance and operational simplicity (moderate)** *(derives from HLD tenet: "Prefer workflows two coordinators can operate without a dedicated systems administrator")*: Minimize custom merge semantics, collection-diffing rules, and schema-coupled conflict logic that must be maintained as survey fields evolve.
- **Client and review/export contract complexity (moderate)**: Keep the local state tracked by `tablet-sync` and the provenance and comparison models in `review-export` straightforward to implement and explain to field workers and coordinators.

## Options in the Domain

### Whole-Visit Revisions

- **Description**: Every submission is stored as a complete, immutable visit snapshot naming the `base_revision_id` it was edited from (`null` on initial creation). When a submission's `base_revision_id` matches the visit's sole current head revision, it advances the head linearly and the visit stays `current`. When two or more submissions branch from the same `base_revision_id` (or an ancestor that already has a successor), the store retains all of them as competing active head revisions and places the visit into `in_review`. A coordinator resolves the fork by inspecting the competing revisions, submitting a resolved whole-visit payload that names the exact `superseded_revision_ids`, and restoring the visit to a single `current` head revision.
- **Demonstration**:
  - Revision `R1` created offline; synced as `current` head.
  - Tablet A and Tablet B both fetch `R1`. Tablet A submits `R2` (`base_revision_id: R1`, fixing observer list). Tablet B submits `R3` (`base_revision_id: R1`, revising *Spartina alterniflora* cover from 15% to 25% and updating notes).
  - Store records `R2` and `R3` as competing heads (`status: in_review`, `head_revision: null`).
  - Coordinator compares `R2` and `R3` against `R1`, confirms the edits do not conflict scientifically, and submits resolution `R4` (`superseded_revision_ids: [R2, R3]`), returning the visit to `current`.
- **Analysis**:
  - *Preserve all submitted edits (gate)*: **passes** — every submitted revision is stored immutably in the revision graph; concurrent submissions become competing heads and stale resolutions are rejected if new heads arrive.
  - *Scientific integrity across coupled fields (major)*: **strong** — the store never synthesizes a composite visit without coordinator inspection; every `current` record is either a single worker's complete submission or a coordinator's explicit resolution.
  - *Coordinator review workload before Friday export (major)*: **weak** — any concurrent edits to the same visit, even to completely unrelated fields such as observer names and species cover, place the visit into `in_review` and require manual coordinator resolution before Friday export.
  - *Rule maintenance and operational simplicity (moderate)*: **strong** — conflict detection depends only on revision ID lineage (`base_revision_id` vs. current head), requiring no per-field or collection merge rules.
  - *Client and review/export contract complexity (moderate)*: **strong** — `tablet-sync` tracks a single `base_revision_id` per stored visit and sends full payloads; `review-export` compares whole revisions and filters export eligibility by `status == current`.
- **Summary**: Guarantees that no unreviewed composite record is ever synthesized and keeps store/sync rules simple, at the cost of routing every concurrent visit edit through the two coordinators' review queue.

### Field-Aware Three-Way Merge

- **Description**: Each tablet retains the full base snapshot it edited from and submits structured changes alongside the base reference. When concurrent edits arrive against the same base state, the store computes field-level diffs against the base snapshot: scalar fields (`observation_date`, `notes`), set/list fields (`observers`), and keyed collection entries (`species_cover` keyed by species code). If the two submissions modify disjoint fields or disjoint species entries, the store automatically merges them into a combined current revision with field-level provenance linking each value to its contributing submission. Only overlapping edits to the same field or the same species entry mark the visit unresolved for coordinator review. If concurrent edits arrive while a visit is already partially unresolved, non-overlapping fields can still merge while overlapping fields accumulate review items.
- **Demonstration**:
  - Base state `S1` has observers `["Ada"]` and species `[{"code": "SPAL", "cover": 15}]`.
  - Tablet A updates `observers` to `["Ada", "Ben"]`. Tablet B adds `{"code": "DISP", "cover": 10}` to `species_cover`.
  - Store compares both against `S1`, detects disjoint changes, and produces merged current state `S2` with field provenance (`observers <- SubA`, `species_cover[SPAL] <- S1`, `species_cover[DISP] <- SubB`), ready for Friday CSV export without coordinator intervention.
- **Analysis**:
  - *Preserve all submitted edits (gate)*: **passes** — original submissions are retained immutable in history alongside the merged representation and field-level provenance links.
  - *Scientific integrity across coupled fields (major)*: **weak** — automatic merging cannot see domain couplings across separate fields or species keys (for example, one worker reclassifying a specimen from species A to species B while another worker adjusts species A's cover or notes based on the old identification), producing a composite record that neither worker intended and marking it ready for export without review.
  - *Coordinator review workload before Friday export (major)*: **strong** — concurrent edits to unrelated fields (such as observer names vs. species entries, or separate species within a plot) merge automatically and clear straight to the Friday export, reserving coordinator time for true field collisions.
  - *Rule maintenance and operational simplicity (moderate)*: **weak** — requires defining and maintaining merge semantics for scalars, ordered or unordered observer lists, and keyed species cover entries, and updating those rules whenever visit schema fields change.
  - *Client and review/export contract complexity (moderate)*: **weak** — `tablet-sync` must retain full base snapshots and construct structured change sets; `review-export` must store and display field-level provenance and present partial field conflicts alongside auto-merged fields.
- **Summary**: Substantially reduces coordinator review volume by auto-merging disjoint edits, at the cost of maintaining collection merge rules and risking silent synthesis of scientifically coupled edits.

### Last-Write-Wins by Server Receipt Time

- **Description**: Each valid submission overwrites the current visit record in arrival order while appending the prior state to an audit log. No competing state or review queue is created for concurrent edits.
- **Analysis**:
  - *Preserve all submitted edits (gate)*: **eliminated** — while prior payloads sit in an audit log, an earlier-synced correction can be overwritten by a tablet reconnecting 48 hours later without surfacing that an edit was displaced, violating the tenet against silently discarding submitted edits.

## Selection

**Chosen: Whole-Visit Revisions.**

Whole-visit revisions win on **scientific integrity across coupled fields** and **rule maintenance and operational simplicity**, turning directly on the HLD non-goal against automated inference of scientific intent and the tenet to keep the path from a submitted observation to an exported value inspectable. In vegetation surveys, edits that look structurally disjoint in JSON — such as adding a species entry on one tablet while editing cover percentages or notes on another — can represent competing interpretations of the same quadrat observation. Accepting a larger coordinator review queue is preferable to maintaining custom merge rules that can silently synthesize scientifically inconsistent records and export them to the regional science partner unreviewed.

Field-aware three-way merge remains a credible alternative if seasonal volume or multi-tablet contention grows beyond what two coordinators can clear before the Friday export, or if the team later pairs automated merging with mandatory coordinator sign-off on all merged records.

### Downstream Implications

- **`record-store`**: Must track `base_revision_id` on submissions, maintain the active head revision set per visit (`current` with a single `head_revision` vs. `in_review` with `competing_revisions`), and require coordinator resolutions to specify the exact `superseded_revision_ids` set so newly arrived submissions are never overwritten by a stale resolution.
- **`tablet-sync`**: Must persist the `revision_id` of each downloaded or accepted visit as the local `base_revision_id` (`null` for newly created offline visits), submit complete visit payloads rather than field diffs, and surface `in_review` status and competing revisions when a synced visit forks.
- **`review-export`**: Must provide a whole-revision comparison interface for visits in `in_review`, submit coordinator resolutions with `superseded_revision_ids` and the resolved full visit payload, and hold any visit whose status is `in_review` out of the Friday partner CSV export until resolved to `current`.
```

---

### Remaining Phase 2 Review & Edge-Case Probe Triage

Before we move to Phase 3 (updating `record-store-specs.md`), please let me know if you approve the `record-store` LLD and decision doc, and how you want to handle the Phase 2 probe questions (settle in the LLD now vs. defer to Open Questions):

1. **Follow-up edit on a branch while already `in_review`**: If a visit has competing heads `[R1, R2]` and a worker submits `R3` with `base_revision_id: R1`, does `R3` replace `R1` in the competing head set (yielding `[R2, R3]`), or remain alongside `R1` (`[R1, R2, R3]`)?
2. **Client- vs. server-generated `revision_id`**: Should `revision_id`s be server-generated (with `tablet-sync` collapsing local offline edits or syncing sequentially) or client-generated?
3. **Concurrent identical payloads**: If two submissions against the same `base_revision_id` have identical payloads (but different idempotency keys/authors), do they still fork into `in_review` or fast-forward/deduplicate?
4. **Plot ID mutability across revisions**: Can an edit or resolution change a visit's `plot_id`, or is `plot_id` fixed once a visit is created?
5. **Resolution idempotency & rejected-submission keys**: Should coordinator resolutions also carry an `idempotency_key`, and are `idempotency_key`s bound only on accepted requests?
6. **List/query endpoints in Retrieval Contract**: Should `record-store` explicitly specify list queries by `status` (`current` / `in_review`) for `review-export` and `tablet-sync`?