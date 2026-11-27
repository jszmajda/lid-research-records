Written to `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked from `docs/intent/record-store/record-store-design.md` (`Decisions & Alternatives` and `References`). Here is the full decision doc for review:

---

```markdown
---
node: record-store
---

# Decision: Concurrent Visit Edit Reconciliation

## Context

TidePlot serves 24 seasonal field workers sharing 12 Android tablets across 320 permanent coastal vegetation plots, producing roughly 6,000 plot-visit records per season. Tablets operate without connectivity for 48 hours or more. After comparing paper or verbal field notes, workers sometimes edit the same visit independently on different tablets before syncing, so updates derived from the same starting visit arrive at `record-store` days later and out of capture order. Two coordinators resolve data questions and deliver a reviewed CSV to a regional science partner every Friday without a dedicated systems administrator.

Each visit payload contains `plot_id`, `observation_date`, `observers`, `species_cover`, and `notes`. Concurrent edits fall into two domain patterns that look identical at the schema level:

- **Independent administrative or additive edits**, such as one worker correcting a misspelled observer name while another adds an omitted trace species.
- **Scientifically coupled edits across distinct fields**, such as one worker re-identifying a grass species and adjusting its cover percentage while another adds a field note or adjusts an overlapping cover estimate under the original identification.

Every candidate concurrency design for `record-store` must preserve all original worker submissions (per *"Do not silently discard a submitted edit"*), operate across multi-day disconnection (per *"Let field workers continue collecting observations without connectivity"*), and avoid automated botanical inference. Silent timestamp or arrival-order overwrite fails TidePlot's reason for existing and is not in contention. What remains open in the domain is whether `record-store` reconciles concurrent edits as atomic whole-visit revisions or through field-aware three-way merging. That choice sizes local state and upload envelopes in `tablet-sync` and determines the review interface, provenance model, and export eligibility rules in `review-export`.

## Decision Elements

Both options in contention retain every submitted edit and support 48-hour offline operation, so no binary gate eliminates an option. Selection turns on five weighted criteria:

- **Cross-field scientific integrity (`major`)** — Grounded in *"Do not silently discard a submitted edit"* (preserving the coherent observational meaning of a worker's submission) and the non-goal against *automated botanical validation or inference of scientific intent*. Evaluates whether concurrent edits that interact scientifically across separate fields are guaranteed human review rather than automatically combined into a synthetic observation neither worker recorded.
- **Operational and engineering simplicity (`major`)** — Grounded in *"Prefer workflows two coordinators can operate without a dedicated systems administrator."* Evaluates the complexity of server reconciliation logic, client state machinery, and ongoing maintenance when visit fields or survey conventions evolve.
- **Coordinator review throughput and export readiness (`moderate`)** — Also grounded in *"Prefer workflows two coordinators can operate without a dedicated systems administrator,"* weighing coordinator capacity rather than system administration. Evaluates how much weekly review work accumulates ahead of the Friday partner CSV and how much manual effort (and potential transcription error) coordinators face when reconciling routine non-overlapping edits.
- **End-to-end provenance inspectability (`moderate`)** — Grounded in *"Keep the path from a submitted observation to an exported value inspectable."* Evaluates how directly a coordinator or science partner can trace an exported CSV value back to human-authored submissions and explicit review choices without mentally re-executing server merge rules.
- **Wire upload efficiency on constrained connections (`minor`)** — Grounded in *"Let field workers continue collecting observations without connectivity"* when tablets reconnect over weak coastal cellular links. Evaluates upload payload size per edit relative to local baseline storage on shared tablets.

## Options in the Domain

### Whole-Visit Revisions

**Description**

Every worker submission carries a complete `VisitPayload` and the `base_revision_id` (`null` on initial creation) of the server revision the worker edited. `record-store` persists every accepted submission as an immutable whole-visit revision in a per-visit directed acyclic graph. When a submission's `base_revision_id` matches the visit's sole active tip, the new revision supersedes it and becomes `current_revision` (`resolved`). When `base_revision_id` has already been superseded, the store retains existing tip(s) and adds the new revision as a competing tip, placing the visit in `needs_review` with `current_revision: null`. A coordinator resolves a `needs_review` visit by comparing the competing revisions against their common base revision(s) and submitting a complete resolved `VisitPayload` referencing the exact `contributing_revision_ids` superseded.

**Demonstration**

Starting from revision `R1` (`observers: ["Lin", "Mora"]`, `species_cover: [{species: "Spartina patens", cover: 35}]`, `notes: null`):

- *Coupled botanical edits*: Tablet 1 submits `R2` (`base_revision_id: R1`) re-identifying the grass as `Distichlis spicata` at `20%` cover. Tablet 2 submits `R3` (`base_revision_id: R1`) keeping `Spartina patens` at `35%` and setting `notes: "Spartina patch shows salt-pan dieback"`. `R3` arrives after `R2`; the visit enters `needs_review` with tips `[R2, R3]` so a coordinator catches the contradictory `notes` and `species_cover` together.
- *Unrelated edits*: Tablet 1 fixes `observers` to `["Lin", "Morales"]`; Tablet 2 sets `notes: "Marker post loose"`. The visit likewise enters `needs_review` with two full snapshots for a coordinator to combine.

**Analysis**

- *Cross-field scientific integrity*: **Strong** — any concurrent edits branching from an already-superseded revision enter `needs_review` as intact whole-visit tips; `record-store` never synthesizes cross-field combinations without coordinator review.
- *Operational and engineering simplicity*: **Strong** — `record-store` treats visit payloads as atomic validated documents linked by `base_revision_id` and `contributing_revision_ids`, tablets track only a revision UUID per draft, and schema changes to visit fields require no diff or merge rule updates.
- *Coordinator review throughput and export readiness*: **Weak** — concurrent edits to unrelated fields (such as an observer spelling fix and a note addition) enter `needs_review`, holding the visit out of the Friday CSV until a coordinator inspects the competing revisions and submits a combined whole-visit payload.
- *End-to-end provenance inspectability*: **Strong** — every stored revision and every exported record is a complete visit authored as a whole by a single worker or coordinator, with explicit parent revision and `contributing_submission_ids` links.
- *Wire upload efficiency on constrained connections*: **Partial** — tablets avoid storing duplicate base snapshots locally, but upload the full structured visit JSON (typically a few kilobytes without media) on every edit rather than only changed fields.

**Summary**: Preserves whole-visit scientific coherence and eliminates per-field merge machinery, at the cost of routing every concurrent edit pair through coordinator review before export.

### Field-Aware Three-Way Merge

**Description**

Each tablet retains an immutable snapshot of the base revision a local edit started from alongside the working draft. On submission, the tablet sends `base_revision_id`, the worker's structured change set against that base (scalar replacements for `observation_date` and `notes`, element additions/removals for `observers`, and species-keyed additions, updates, or removals for `species_cover`), and the resulting snapshot for submission-history archival. When concurrent submissions share an ancestor, `record-store` runs field-specific three-way merge rules against the base state:

- If modified scalar fields, observer operations, and `species_cover` species keys are disjoint, `record-store` automatically produces a merged `current_revision`, records per-field provenance pointing to the submission that supplied each value, and keeps the visit `resolved` for Friday export.
- If two submissions modify the same scalar field, conflict on the same observer entry, or touch the same species key with different values, `record-store` flags only the colliding fields as `needs_review` and holds the visit out of export until a coordinator resolves those overlapping fields.

Advocates of this approach in offline field-survey systems point out that routine post-survey cleanup — fixing observer rosters, correcting dates, or appending plot access notes — frequently happens independently of botanical cover edits, and deterministic merging keeps those routine edits from consuming coordinator review time or risking manual copy mistakes.

**Demonstration**

Starting from the same `R1`:

- *Unrelated edits*: Tablet 1 changes `observers` (`"Mora"` -> `"Morales"`); Tablet 2 sets `notes: "Marker post loose"`. Because `observers` and `notes` are disjoint fields, `record-store` merges both automatically into a `resolved` current revision ready for Friday export without coordinator action.
- *Coupled botanical edits*: Tablet 1 deletes `Spartina patens` and adds `Distichlis spicata: 20%` in `species_cover`; Tablet 2 leaves `species_cover` untouched and sets `notes: "Spartina patch shows salt-pan dieback"`. Because `species_cover` and `notes` are distinct fields, `record-store` automatically merges them into a `resolved` record pairing `Distichlis spicata` cover with a note describing `Spartina` dieback, exporting it on Friday without review.

**Analysis**

- *Cross-field scientific integrity*: **Weak** — disjoint changes across `species_cover`, `notes`, `observation_date`, or distinct species keys combine automatically into `resolved` state, allowing scientifically incompatible cross-field combinations to enter the partner CSV unreviewed.
- *Operational and engineering simplicity*: **Weak** — requires specifying, testing, and maintaining three-way diff and merge rules across scalars, observer lists, and keyed species-cover entries (including species renames modeled as delete-plus-insert), alongside base-snapshot storage on tablets and field-level conflict states in `record-store`.
- *Coordinator review throughput and export readiness*: **Strong** — non-overlapping concurrent edits merge on receipt and remain immediately eligible for the Friday CSV, reserving coordinator attention for direct field or species-key collisions and eliminating manual transcription of disjoint fixes.
- *End-to-end provenance inspectability*: **Partial** — per-field provenance tags identify which submission wrote each individual field, but an exported visit can be a rule-assembled composite no worker or coordinator ever inspected as a whole, requiring readers to understand both submission history and server merge-rule behavior.
- *Wire upload efficiency on constrained connections*: **Strong** — uploads transmit compact structured change sets rather than complete visit payloads, trading extra local base-snapshot storage on tablets for minimal wire bytes.

**Summary**: Keeps routine disjoint edits out of the coordinator review queue and ready for Friday export, at the cost of maintaining per-field merge rules that can silently combine scientifically coupled changes across fields.

## Selection

**Selected option**: **Whole-Visit Revisions**.

Whole-visit revisions wins on both `major` criteria (**Cross-field scientific integrity** and **Operational and engineering simplicity**) and holds an advantage on `moderate` **End-to-end provenance inspectability**, trading away `moderate` **Coordinator review throughput and export readiness** and `minor` **Wire upload efficiency**. Because TidePlot handles structured text and species tables rather than photographs (~6,000 visits per season, a few kilobytes per visit), wire payload differences are negligible in practice. The real trade is a larger weekly coordinator review queue versus maintaining structural merge rules that cannot recognize botanical relationships across fields.

The decision turns on three high-level design tenets:

- *"Do not silently discard a submitted edit"* (together with the non-goal against *inference of scientific intent*): preserving an edit faithfully includes preserving the coherent whole-visit observation the worker recorded, rather than auto-assembling cross-field hybrids neither observer intended.
- *"Keep the path from a submitted observation to an exported value inspectable"*: every exported CSV row traces to a complete snapshot authored either by a field worker or explicitly by a coordinator citing `contributing_submission_ids`.
- *"Prefer workflows two coordinators can operate without a dedicated systems administrator"*: this tenet pulls in both directions — two coordinators have finite review time before Friday export, yet a small conservation team cannot afford ongoing maintenance of subtle list- and species-merge edge cases. Accepting a larger manual review queue keeps `record-store`'s rules small, predictable, and free of hidden merge bugs.

### Conditions That Would Warrant Reconsidering Field-Aware Three-Way Merge

A future maintainer re-running this decision should reconsider **Field-Aware Three-Way Merge** (or a narrower variant restricted to strictly administrative metadata) if seasonal operation demonstrates both of the following:

1. **Coordinator queue bottleneck**: Weekly `needs_review` volume regularly exceeds what two coordinators can clear before the Friday partner CSV export, holding substantial numbers of visits out of weekly deliveries.
2. **Empirical dominance of orthogonal edits**: Audit of resolved conflicts in `record-store` history shows that competing revisions overwhelmingly modify scientifically independent fields (for example, post-shift `observers` roster fixes colliding with `species_cover` entries) rather than coupled botanical fields, or shows that manual coordinator synthesis is itself introducing copy errors.

### Implications and Downstream Obligations

**What committing forecloses**:
- `record-store` will not compute field-level diffs, store per-field attribution metadata, or automatically advance concurrent edits on disjoint fields to `resolved` status. Any concurrency after a superseded `base_revision_id` withholds `current_revision` (`null`) until coordinator resolution.

**What `tablet-sync` must accommodate**:
- **Revision-ID baseline tracking**: Persist the server `revision_id` from which any local draft starts (`null` for newly created visits) and submit it as `base_revision_id` alongside the complete `VisitPayload` and a stable per-attempt `idempotency_key`. Tablets do not need to retain separate immutable base snapshots or generate structured patches.
- **Unresolved state presentation on shared tablets**: Handle sync and submission responses where a visit is in `needs_review` (`current_revision: null` with `competing_revisions`). Explain clearly to field workers that competing revisions are awaiting coordinator review rather than displaying one competing tip as settled truth, and define which `revision_id` a worker branches from if making a follow-up correction before coordinator resolution.

**What `review-export` must accommodate**:
- **Export holdback rule**: Exclude all `needs_review` visits from the Friday partner CSV, exporting only `resolved` visits' `current_revision`, and surface unresolved visit counts prominently ahead of the Friday export deadline.
- **Diff-assisted revision comparison and synthesis UI**: Because all concurrent edits — including unrelated field fixes — reach coordinator review, provide a comparison view backed by `competing_revisions` and `base_revisions` that visually highlights which fields changed against the starting revision and helps a coordinator select or assemble a combined `VisitPayload` without manual re-typing errors, while still submitting a single coordinator-approved whole-visit payload to `record-store`.
- **Optimistic concurrency across coordinators**: Submit resolutions naming the exact `contributing_revision_ids` reviewed and handle conflict responses cleanly if the other coordinator resolved the visit or a delayed tablet synced an additional competing revision while the comparison screen was open.
```

---

Before we move to Phase 3 (`record-store-specs.md`), please confirm:

1. Do the decision doc and `record-store-design.md` look ready to approve?
2. For the Phase 2 LLD edge-case probe items (1–7 from the previous message), would you like to settle any of them in `record-store-design.md` now, or defer them under `Open Questions & Future Decisions` and proceed to Phase 3?