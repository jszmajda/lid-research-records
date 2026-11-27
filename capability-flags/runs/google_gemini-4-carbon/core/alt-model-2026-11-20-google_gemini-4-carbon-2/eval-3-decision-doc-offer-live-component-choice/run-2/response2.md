I have written `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from `record-store-design.md`'s `Decisions & Alternatives` table. Here is the decision doc in full:

```markdown
---
node: record-store
---

# Decision: Concurrent Visit Edit Reconciliation

## Context

TidePlot serves 24 seasonal field workers sharing 12 Android tablets across 320 permanent coastal vegetation plots, producing roughly 6,000 visit records per season. Tablets operate offline for up to 48 hours. Workers frequently review paper or personal field notes after returning from a site and independently correct an existing visit — fixing observer names, clarifying access or habitat notes, revising a tentative plant identification, or adjusting species cover percentages — before tablets sync with the server. Two coordinators oversee data quality and deliver a reviewed CSV to a regional science partner every Friday.

Two standing project constraints bound the solution space before comparing designs. Under the HLD tenet *Let field workers continue collecting observations without connectivity*, tablets cannot acquire online locks or leases before editing a visit. Under *Do not silently discard a submitted edit*, `record-store` must retain every authenticated worker submission intact rather than treating server arrival order as observational authority.

Within those bounds, `record-store` must define how concurrent edits derived from the same starting visit state relate to a visit's current state and review lifecycle. That choice governs `record-store`'s submission envelope, state transitions, and coordinator resolution contract, and sizes two sibling nodes: `tablet-sync` (what base state tablets persist locally, how sync payloads are structured, and how sync outcomes are explained to workers) and `review-export` (what coordinators inspect during review, how resolutions are authored, and which visits qualify for the Friday CSV).

## Decision Elements

- **Cross-field botanical coherence (major)** — Derived from the HLD tenet *Do not silently discard a submitted edit*, the tenet *Keep the path from a submitted observation to an exported value inspectable*, and the HLD non-goal excluding *automated botanical validation or inference of scientific intent*. Survey fields within a single visit carry implicit scientific couplings that schema types do not express: re-identifying a sedge species typically changes its cover entry or splits one species row into two, and habitat notes often qualify a cover estimate or observation date correction. Reconciliation must avoid synthesizing a composite visit state that no observer witnessed and passing it to export without human inspection.
- **Rule-maintenance and schema-evolution burden (major)** — Derived from the HLD tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator* and the non-goal excluding *automated botanical validation or inference of scientific intent*. Visit payloads combine scalar fields (`plot_id`, `observation_date`, `notes`), a list (`observers`), and keyed collection entries (`species_cover`). Any server-side merge specification must handle insertions, deletions, key renames, ordering, and future survey-column additions without requiring ongoing engineering upkeep.
- **Coordinator review volume and Friday export readiness (major)** — Derived from the HLD tenet *Prefer workflows two coordinators can operate without a dedicated systems administrator* and the goal *Make reviewable problems visible before the Friday export*. Two coordinators clear unresolved review items ahead of a weekly Friday export (~300–500 visits per peak week). Every visit held in an unresolved state demands coordinator attention and stays out of the partner CSV until resolved; unnecessary review items on routine, scientifically unrelated fixes reduce export readiness.
- **Export provenance inspectability (moderate)** — Derived from the HLD tenet *Keep the path from a submitted observation to an exported value inspectable*. When the regional science partner or a coordinator audits an exported CSV row, the system must make clear which human judgment produced the exported values — a single worker's intact submission or an explicit coordinator resolution — without requiring reconstruction of automated multi-ancestor field lineage.
- **Downstream implementation and workflow obligations in tablet-sync and review-export (moderate)** — Derived from *Let field workers continue collecting observations without connectivity* and *Prefer workflows two coordinators can operate without a dedicated systems administrator*. The concurrency contract determines whether `tablet-sync` tracks lightweight revision IDs or full base snapshots and structured diffs, and whether `review-export` implements whole-revision side-by-side comparison and composition or per-field provenance badges and overlap-only conflict resolution.
- **Offline tablet storage and sync payload size (minor)** — Derived from *Let field workers continue collecting observations without connectivity*. Shared tablets buffer edits across 48-hour disconnections and sync over intermittent coastal connectivity. Because photographs are excluded from scope, a complete structured visit record is roughly 1–4 KB of JSON, keeping wire size small even across dozens of queued edits unless large inline data series are added in future releases.

## Options in the Domain

### Option 1: Whole-Visit Revisions

**Description**

Every worker submission carries a complete visit snapshot (`plot_id`, `observation_date`, `observers`, `species_cover`, `notes`) and the `base_revision_id` the worker edited from (`null` for a newly created visit). When `base_revision_id` matches the visit's sole active head revision, the new revision supersedes it cleanly and becomes the visit's `resolved` current revision. When `base_revision_id` refers to an already-superseded ancestor — or arrives while the visit is already `unresolved` — `record-store` retains the submission as a competing active head revision and marks the visit `unresolved` without attempting to combine fields across branches.

To resolve an `unresolved` visit, an authenticated coordinator inspects the competing head revisions alongside their ancestor base revision(s) and submits a complete resolved visit payload naming the `superseded_revision_ids` and `contributing_submission_ids`, creating a new single `resolved` head revision. `tablet-sync` stores only the fetched `revision_id` alongside local drafts and uploads whole visit snapshots. `review-export` holds `unresolved` visits out of the Friday CSV and provides a revision comparison screen where coordinators either select one revision intact or carry fields across revisions into a resolved payload.

**Demonstration**

Suppose Visit `V1` stands at revision `R1` (`observers: ["A. Lin", "M. Ortiz"]`, `species_cover: [{ "SPAA", 25% }, { "SALV", 10% }]`, `notes: "Spartina patch patchy near wrack line"`). Offline on Tablet 1, Lin realizes `"SPAA"` was misidentified and updates the table to `[{ "SPAP", 25% }, { "SALV", 10% }]` (`R2`, `base_revision_id: R1`). Offline on Tablet 2, Ortiz corrects her name spelling to `"M. Ortiz-Cruz"` and updates `notes` to `"Spartina patens confirmed from seedhead; wrack line shifted"` (`R3`, `base_revision_id: R1`).

`R2` syncs first and becomes the `resolved` head. When `R3` syncs later, `record-store` sees `base_revision_id: R1` is superseded, keeps both `R2` and `R3` as competing heads, and transitions `V1` to `unresolved`. `V1` is excluded from the Friday CSV until a coordinator compares `R2` and `R3` against `R1`, sees that Ortiz's note confirms Lin's `"SPAP"` re-identification, and records `R4` combining `"SPAP"` with `"M. Ortiz-Cruz"` and the updated note.

**Analysis**

- **Strong fit** — Cross-field botanical coherence: No composite visit is ever produced without a coordinator viewing the full competing observations together; coupled edits (such as a species code change on one tablet and a cover or note edit assuming the old species code on another) always stop for human review.
- **Strong fit** — Rule-maintenance and schema-evolution burden: `record-store` treats `payload` as a validated whole snapshot with revision-graph pointers; adding or modifying survey fields requires schema validation updates only, with zero per-field merge rules.
- **Weak fit** — Coordinator review volume and Friday export readiness: Any two concurrent offline edits to the same visit — including purely administrative fixes such as correcting an observer typo while another tablet appends site-access notes — produce an `unresolved` visit that coordinators must clear before it can enter the Friday CSV.
- **Strong fit** — Export provenance inspectability: Every exported row corresponds directly to a single revision snapshot authored either by one worker (`submission_id`) or by a named coordinator (`resolution_id` citing `superseded_revision_ids` and `contributing_submission_ids`).
- **Partial fit** — Downstream implementation and workflow obligations in tablet-sync and review-export: `tablet-sync` stays simple (storing a single `base_revision_id` UUID per cached visit and uploading full snapshots), while `review-export` must provide side-by-side diff highlighting against the base revision and ergonomic field/species copy helpers so coordinators do not retype unchanged species tables when manually combining two competing revisions.
- **Partial fit** — Offline tablet storage and sync payload size: Each queued edit sends the entire 1–4 KB visit payload rather than only modified fields, while avoiding local storage of separate base snapshots on the tablet.

**Summary**

Preserves every observation as an indivisible scientific unit with minimal server merge logic, at the cost of routing all concurrent same-visit edits through coordinator review before export.

---

### Option 2: Field-Aware Three-Way Merge

**Description**

`tablet-sync` retains the full base visit snapshot alongside local edits and submits either the base snapshot plus structured changes or a full edit evaluated against the server's stored base revision across three field classes: scalar fields (`plot_id`, `observation_date`, `notes`), set/list membership (`observers`), and species-keyed entries (`species_cover` keyed by species identifier). When concurrent edits touch disjoint fields or distinct species keys relative to their common base revision, `record-store` automatically produces a merged current revision in `resolved` status while preserving both original worker submissions and recording field-level provenance pointing each field or species entry to the submission that supplied it.

When concurrent edits modify the same scalar field to different values, edit the same species key's cover estimate differently, or violate configured conflict triggers, `record-store` marks those overlapping elements unresolved and routes the visit to `review-export`. Coordinators inspect a conflict view focused on the overlapping fields alongside field-level provenance for already-merged fields; visits with no overlapping fields proceed directly to the Friday CSV without manual coordinator intervention.

**Demonstration**

Under the same `V1` scenario from `R1`: if Tablet 1 changes `"SPAA"` (`25%`) to `"SPAP"` (`25%`) (modeled as deleting `"SPAA"` and inserting `"SPAP"`) while Tablet 2 fixes `"M. Ortiz-Cruz"` in `observers` and edits `notes`, none of the modified field keys overlap (`species_cover["SPAA"]` and `species_cover["SPAP"]` vs. `observers` and `notes`). `record-store` automatically synthesizes a `resolved` current record containing all three changes and includes `V1` in the Friday CSV without coordinator review.

However, if Tablet 1 re-identifies `"SPAA"` (`25%`) as `"SPAP"` (`25%`) while Tablet 2 — still believing the grass is `"SPAA"` — updates `species_cover["SPAA"]` from `25%` to `40%` (or deletes `"SPAP"` / adjusts another species percentage so plot cover totals align), the delete-vs-modify rule on `"SPAA"` catches direct key overlap, whereas an adjustment to a companion species (`"DIST"` from `15%` to `30%` after splitting clumps) has no key overlap and merges automatically into a species table neither worker observed.

**Analysis**

- **Weak fit** — Cross-field botanical coherence: Disjoint field keys do not imply independent botanical observations; edits to companion species cover, habitat notes explaining an older species list, or observation dates paired with observer lists combine silently into an exported `resolved` visit without human review unless bespoke cross-field conflict heuristics are added.
- **Weak fit** — Rule-maintenance and schema-evolution burden: Requires specifying, testing, and maintaining merge and conflict rules across scalars, ordered/unordered observer names, species-table insertions/deletions/renames, duplicate-species normalization, and multi-hop three-way merges when three or more tablets branch sequentially.
- **Strong fit** — Coordinator review volume and Friday export readiness: Routine concurrent edits to unrelated fields (such as observer spelling fixes on one tablet and species or note updates on another) merge automatically into `resolved` status, keeping coordinator review focused on direct field collisions and maximizing Friday CSV completeness.
- **Partial fit** — Export provenance inspectability: Original submissions remain stored, and per-field provenance links each exported value to a `submission_id`, but auditing an exported row requires inspecting a composite record assembled by merge rules from multiple submissions rather than a single human-authored snapshot.
- **Partial fit** — Downstream implementation and workflow obligations in tablet-sync and review-export: Eliminates manual coordinator action for disjoint edits, but requires `tablet-sync` to retain full base snapshots and produce structured field changes (or strict key-normalized payloads) and requires `review-export` to render field-level provenance alongside partial-conflict resolution controls.
- **Strong fit** — Offline tablet storage and sync payload size: Structured change payloads transmit only modified fields over intermittent connections, though tablets store local base snapshots for edited visits.

**Summary**

Minimizes coordinator review load and keeps disjoint concurrent edits moving directly to Friday export, at the cost of maintained per-field merge rules and silent combination of scientifically coupled edits across distinct fields.

## Selection

**Selected option: Option 1 — Whole-Visit Revisions.**

Whole-visit revisions win on both **major** criteria tied to scientific integrity and long-term operability (**Cross-field botanical coherence** and **Rule-maintenance and schema-evolution burden**), as well as **Export provenance inspectability** (**moderate**). In vegetation plot surveys, fields that are structurally distinct in JSON — two rows in `species_cover`, or a species row and `notes` — are frequently coupled in the field worker's observation. Automatic field combination risks violating the HLD non-goal against *automated botanical validation or inference of scientific intent* by assembling a composite botanical record that neither observer recorded and sending it straight to the regional science partner's Friday CSV. Whole-visit revisions uphold *Do not silently discard a submitted edit* and *Keep the path from a submitted observation to an exported value inspectable* by guaranteeing that every exported visit state was reviewed as a whole by either a single observer or a coordinator.

The decision engages *Prefer workflows two coordinators can operate without a dedicated systems administrator* on both sides and consciously favors operational simplicity over queue automation: two coordinators can work a straightforward revision comparison queue without a specialist maintaining three-way merge semantics across evolving survey fields, even though this trades directly against **Coordinator review volume and Friday export readiness** (**major**).

### Why Option 2 Remains Credible (Conditions to Revisit)

Field-aware three-way merge is not eliminated by project constraints — it preserves original submissions and works offline — and remains the natural alternative if production conflict patterns invert this trade:

- **High rate of genuinely orthogonal concurrent edits**: If seasonal history logs show that most `unresolved` visits stem from independent metadata edits (for example, crew leads fixing `observers` or plot access `notes` on one tablet while botanists enter `species_cover` on another) rather than coupled species/cover corrections.
- **Friday export bottleneck**: If unresolved queue volume consistently exceeds what two coordinators can inspect before the weekly Friday export cutoff, holding significant numbers of otherwise valid visits out of the partner CSV.
- **Tightly bounded auto-merge scope**: A future revision could also adopt a conservative variant of Option 2 (for instance, treating the entire `species_cover` + `notes` block as a single atomic unit while allowing disjoint `observers` edits to merge) if full field-level merging remains too risky scientifically.

### Implications of Committing

**Foreclosed:**
- Concurrent edits to the same visit never auto-combine into a `resolved` exportable visit, even when they modify non-overlapping JSON fields.
- Clients cannot submit partial field patches; every edit and coordinator resolution submits a complete visit payload.

**Downstream obligations to accommodate:**
- **`tablet-sync`**:
  1. Persist the server's `revision_id` as `base_revision_id` when caching a visit (`null` for newly created offline visits) and attach a stable per-edit `idempotency_key` alongside the complete visit payload during upload retries.
  2. Advance the cached `base_revision_id` when an accepted upload returns `status: resolved`.
  3. Surface `status: unresolved` clearly on shared tablets when an accepted upload lands alongside a competing revision — confirming that the worker's observation is safely stored on the server for coordinator review so workers do not re-enter or re-upload duplicates — and define how local viewing/editing behaves while a visit awaits coordinator resolution.
- **`review-export`**:
  1. Provide a coordinator revision comparison screen that fetches `competing_revisions` together with their ancestor base revision snapshot(s) and highlights field- and species-level differences visually against the base.
  2. Support low-friction resolution authoring so a coordinator can either accept one competing revision whole or selectively pull fields/species entries across competing revisions into a synthesized whole-visit `payload` without manual retyping, submitting `superseded_revision_ids` and `contributing_submission_ids` and handling rejection if a delayed tablet uploads another edit mid-review.
  3. Surface unresolved visit counts and items ahead of the Friday export workflow and hold all `unresolved` visits out of the partner CSV until resolved into a single authoritative head revision.
```

---

### Remaining Phase 2 Check Before Phase 3 (`record-store-specs.md`)

1. **Decision doc & `record-store-design.md` review**: Does this decision doc and the `record-store-design.md` LLD look good as written?
2. **Edge-case triage**: Which (if any) of the 8 edge cases from the Phase 2 probe above would you like pinned down in `record-store-design.md` now vs. deferred to `Open Questions & Future Decisions`?
3. **Cross-node status references**: Should I also update the open-choice notes in `docs/high-level-design.md` (`Drafted; concurrency choice open` / "unresolved choice") and `docs/intent/site-catalog/site-catalog-design.md` ("pending that choice"), or leave those untouched for now?