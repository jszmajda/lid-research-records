Wrote the decision doc to `docs/intent/record-store/decisions/concurrent-visit-edit-policy.md` and linked it from the LLD's Decisions & Alternatives table. Full text:

---

**---**
**node: record-store**
**---**

**# Decision: Concurrent Visit Edit Policy**

**## Context**

Field workers independently correct the same visit after comparing notes, and their submissions can arrive days apart. The store must turn these arrivals into one current visit without treating arrival order as evidence that one worker's observations are more authoritative, and without silently discarding a submitted edit. Two policies satisfy that constraint: keep each submitted visit intact as a whole revision and let a coordinator choose among competing revisions, or merge edits field by field so disjoint changes combine automatically. The choice sets the submission contract that tablet-sync stores and sends, the shape of the coordinator's review work, and which visits are eligible for the Friday partner export, so it is settled here before those nodes are designed.

**## Decision Elements**

No option is eliminated by a gate. Both preserve every original submission (the *do not silently discard a submitted edit* tenet), both work with 48-hour disconnection, and neither performs automated inference of scientific intent as the HLD non-goals define it. The choice therefore turns on weighted criteria.

| Criterion | Importance | Tenet / goal it turns on |
|---|---|---|
| Integrity of submitted visits and scientific relationships | major | *Keep the path from a submitted observation to an exported value inspectable*; HLD non-goal *no automated inference of scientific intent* |
| Coordinator review workload | major | *Workflows two coordinators can operate without a dedicated systems administrator*; goal *make reviewable problems visible before the Friday export* |
| Implementation and maintenance burden | major | *without a dedicated systems administrator* |
| Handling of mixed edits (a good unrelated edit alongside a conflict) | moderate | — |
| Time-to-export for the Friday CSV | moderate | goal *export the partner's existing columns without requiring spreadsheet cleanup* |
| Auditability of an exported value's origin | moderate | *Keep the path from a submitted observation to an exported value inspectable* |
| Tablet-side local state and submission size | minor | goal *retain drafts across restarts and multi-day disconnection* |

**## Options in the Domain**

**### Whole-visit revisions** — Each submission is a complete visit plus a `revisionId` and the `baseRevisionId` it started from. A base equal to the current revision advances cleanly; any other known base is stored intact as competing and makes the visit unresolved. A coordinator resolves by selecting one candidate; every revision is retained. The store never combines fields across revisions.

*Demonstration:* A and B both open `V` at `R0`; A's observer-name fix submits `R1` (base `R0`) and advances cleanly; B's added species submits `R2` (base `R0`), which mismatches current `R1`, so it is stored competing and `V` becomes unresolved. The coordinator sees `R1` and `R2` side by side and selects one.

*Analysis:* integrity of visits **strong** (a chosen revision is exactly what a worker submitted); review workload **weak** (every concurrent edit, including unrelated fields, becomes a task); implementation/maintenance **strong** (no merge rules); mixed edits **weak** (can't keep a good unrelated edit from the loser); time-to-export **partial** (unresolved visits held out); auditability **strong** (one revision, one author); tablet-side state **strong** (base IDs, not snapshots/diffs). *Summary:* trades review volume for integrity and low maintenance.

**### Field-aware three-way merge** — Each submission supplies its base state plus structured changes. Disjoint field changes combine automatically; overlaps require review. Merge rules are maintained per field kind (scalars, observer lists, species-cover entries), and combined records carry field-level provenance.

*Demonstration:* From `R0`, A's observer-name change and B's added species touch disjoint fields and combine with no review; a shared observer-list change goes to a coordinator with provenance showing who set what.

*Analysis:* integrity **weak** (automatic combination can cross scientific relationships the rules don't model — e.g. a species identification and its cover estimate — producing a record no worker submitted); review workload **strong**; implementation/maintenance **weak** (rules must be built and kept correct); mixed edits **strong**; time-to-export **strong**; auditability **partial** (field-level provenance must be maintained and surfaced); tablet-side state **weak** (base snapshots + computed diffs). *Summary:* trades maintained merge logic and scientific-combination risk for a smaller review queue.

**## Selection**

Whole-visit revisions is selected. It is strong on the three major criteria — submitted-visit integrity, maintenance burden, and, at moderate weight, auditability — while field-aware merging's advantages (review workload, mixed-edit handling, time-to-export) are outweighed by two costs the team declines to carry: a maintained merge-rule set the two coordinators must keep correct, and the possibility of silently combining scientifically related fields. The decision turns on the tenet *prefer workflows two coordinators can operate without a dedicated systems administrator* and on the HLD non-goal *no automated inference of scientific intent*; it is taken *against* the review-workload tenet's pull toward automatic combination, accepting a larger queue as the price. The tenet *do not silently discard a submitted edit* is respected by both options and does not separate them.

The decision forecloses automatic field-level combination in the first release — a coordinator's only resolution action is to select one whole revision. It stays reversible: field-aware merging remains a credible alternative if the coordinator queue proves unmanageable, and a merge operation could be added to the retained-revision model without discarding any stored submission, since every original revision is already preserved.

**### Downstream Obligations**

- **tablet-sync** must retain each draft's `baseRevisionId`, submit complete visits rather than diffs, and display pending competing revisions so a worker can see that a visit awaits resolution. Its retry state machine keys on the submission's idempotency key.
- **review-export** must provide a revision comparison view (candidate revisions side by side) and exclude unresolved visits from the partner CSV until a coordinator resolves them; export eligibility depends on the record store's resolution status.
- Both nodes consume the record store's submission envelope, unresolved-work representation, and resolution operation rather than defining their own concurrency semantics.

---

That is the doc as written. The LLD is unchanged apart from the link.

I'm still holding at the **Phase 2 stop**. Before I move to Phase 3 (EARS), I still need:

1. **LLD approval** — is the revision model (clean vs competing; unresolved persisting across clean advances; resolution selects one candidate and retains the rest) what you want?
2. **Probe triage** — of the 13 edge-case gaps from the earlier message, which should I settle now in the LLD/specs, and which defer? The ones that most change the contract are #1 (two concurrent first submissions), #2/#11 (whether a post-resolution or cleared base re-opens the visit), #4 (idempotency-key scope), #7 (`revisionId` collision), #8 (candidate set = branch tips only?), and #9 (`contributing submission IDs` vs. the envelope's `revisionId`).
3. **Unknown-base default** — confirm reject-with-resync, or store as competing?

On your answers I'll write the EARS update and stop there for review.