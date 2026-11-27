Both artifacts are written. Presenting them in full, then the probe.

---

## Written: `docs/intent/record-store/decisions/whole-visit-revisions.md`

```markdown
---
node: record-store
---

# Decision: Whole-visit revisions for concurrent visit edits

## Context

Field workers edit the same visit independently on shared tablets, often days apart and offline. The server must accept both edits without treating arrival order as authority, must keep every original submission, and must hand coordinators something they can resolve before the weekly Friday export. Two mechanisms reconcile such edits: keep each submitted visit whole and let coordinators choose among competing revisions, or combine edits field-by-field on the server. The choice shapes what tablets store, what coordinators review, and which records may enter the partner CSV.

## Decision Elements

No gate eliminates either option: both preserve original submissions and both allow fully offline capture. The choice turns on the weighted criteria.

- **Scientific visibility of combined values** (major; tenet: *Keep the path from a submitted observation to an exported value inspectable*). Can a reader see how an exported value came to be, and does any combination of edits become current only where a human has seen it?
- **Coordinator workload** (major; tenet: *Prefer workflows two coordinators can operate without a dedicated systems administrator*). How much review work does ordinary contention create?
- **Clearing review before the Friday export** (moderate). Under expected contention (~6,000 visits/season, with occasional independent corrections of the same visit), can two coordinators drain unresolved work before the weekly deadline?
- **Implementation and maintenance burden** (moderate). Server logic, plus any rules that must stay correct as the visit schema evolves.
- **Tablet state and retry complexity** (moderate). What each tablet must retain between fetch and submit, and how many retry cases the sync logic must handle.
- **Submission payload size** (minor). Full records versus deltas over intermittent field connections.

## Options in the Domain

### Whole-visit revisions

**Description.** Every submission carries the complete visit payload plus the identifier of the revision the editor started from. The server stores each accepted submission as a new whole-visit revision. When a visit's active revisions branch — two workers based edits on the same starting state, or on different states — the visit becomes unresolved: every branch stays intact, and none becomes current for export until a coordinator resolves. Resolution either selects one surviving revision or authors a resolved record; either way the outcome records the coordinator and the contributing submissions. Nothing is combined automatically.

**Demonstration.** Two tablets fetch revision 7 of visit V. One corrects an observer name; the other adds a species. Both submit against base 7. Visit V now has two active revisions and is unresolved. A coordinator compares them side by side, selects one (or writes a resolved visit that keeps both changes), and V becomes resolved with that outcome current.

**Analysis**

- Scientific visibility of combined values — **strong**: any combination exists only as a coordinator's explicit, recorded outcome; field-level server combination never occurs.
- Coordinator workload — **weak**: even edits to unrelated fields produce competing revisions and review work; the queue reflects raw contention, not overlap.
- Clearing review before Friday — **partial**: per-visit resolution is a quick comparison, but queue volume equals contention volume.
- Implementation and maintenance burden — **strong**: no merge rules to author, test, or extend as fields change; server logic is branch detection, storage, and a resolution operation.
- Tablet state and retry complexity — **strong**: a tablet retains one base revision identifier and resubmits whole payloads under an idempotency key.
- Submission payload size — **weak**: every edit resends the full visit; bounded by small structured records at this scale.

**Summary.** Trades a larger, contention-sized review queue for a small server/tablet surface and no unattended combination.

### Field-aware three-way merge

**Description.** Each submission carries its base state, or structured field-level changes against a named base. The server merges: fields changed on only one side apply automatically; fields changed on both sides become review items. Observer lists and species entries are reconciled by maintained merge rules — additions union, per-entry conflicts escalate. Only true overlaps reach coordinators; merged-but-uncontested fields become current without human review, with field-level provenance retained.

**Demonstration.** Same fetch of revision 7: one tablet corrects an observer, the other adds a species. Disjoint fields merge automatically and visit V is export-ready immediately. Had both tablets edited the same species entry's cover estimate, that field alone would wait for a coordinator.

**Analysis**

- Scientific visibility of combined values — **weak**: rules act on field names and list membership; they cannot see that a revised identification and its cover estimate are scientifically related, so related edits can combine without notice even though per-field provenance is kept.
- Coordinator workload — **strong**: review shrinks to actual overlaps; unrelated concurrent edits create none.
- Clearing review before Friday — **strong**: the queue is overlap-only under expected contention.
- Implementation and maintenance burden — **weak**: rules for scalar fields, observer lists, and species entries must be authored, tested against conflict corpora, and maintained as the visit schema grows.
- Tablet state and retry complexity — **weak**: each tablet must retain base snapshots (or field-level bases) and transmit structured changes, with more retry and divergence cases in sync logic.
- Submission payload size — **strong**: deltas are smaller than full records.

**Summary.** Trades a maintained merge-rule surface and the risk of unattended cross-field combination for a much smaller review queue.

## Selection

**Whole-visit revisions.** It is the only option strong on scientific visibility (major): a coordinator always sees competing submissions before any combination exists, so an exported value's path stays reconstructable from stored originals. The cost is accepted deliberately — weak fits on coordinator workload, Friday clearing, and payload size — because two coordinators working a larger comparison queue is an operational burden that can be staffed and scheduled, whereas merge rules that can silently combine scientifically related edits are a failure mode no schedule catches: the error would surface in the partner's CSV, not in the review queue.

The decision turns on *Keep the path from a submitted observation to an exported value inspectable* and accepts a heavier — still operable — load under *Prefer workflows two coordinators can operate without a dedicated systems administrator*.

**Implications of committing.**

- Forecloses unattended reduction of review volume: disjoint-field edits do not fast-path to current. Automated combining of any kind is outside this mechanism.
- Obligates **tablet-sync**: retain each fetched visit's revision identifier as the base of the next submission; send complete visit payloads; surface unresolved status and the competing revisions to the worker.
- Obligates **review-export**: present competing revisions for comparison; admit only resolved visits to the exported CSV.
- **Why field-aware three-way merge stays on the table**: it wins the workload criteria outright. If the unresolved queue routinely threatens the Friday export, or contention data shows most conflicts are disjoint-field, the balance flips — and the switch remains possible because original submissions and base references are retained whether or not a mechanism ever combines them. Schema stability plus a conflict corpus drawn from real whole-visit history would be the precondition for trusting merge rules; until then the weaker scientific-visibility fit is not purchasable at any queue size the team has seen.
```

---

## Phase 2 — Record Store LLD (rewritten)

`docs/intent/record-store/record-store-design.md` — full contents:

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context

This node owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot ID. Updates can arrive days after their starting state was fetched. The server must not treat arrival order as evidence that one worker's observations are more authoritative.

Concurrent edits are reconciled as whole-visit revisions: every accepted edit becomes a complete revision, and competing revisions wait for coordinator resolution. Tablet-sync and review-export are separate nodes that consume the contract defined here; neither may invent its own concurrency semantics.

## Revision Model

Each visit is a chain of whole-visit revisions. A revision stores the complete visit payload, a server-assigned revision ID unique within the visit, the base revision ID the edit started from (`null` for visit creation), the author's identity, and the server receipt time. Original payloads are retained for the life of the visit; resolution never overwrites them.

A revision's children are the later revisions based on it. An **active tip** is a revision with no active child. A visit is **unresolved** when two or more of its revisions are active tips; it is **resolved** when exactly one is active, and that revision is its current state. Every accepted submission adds one revision whose parent is its base, so concurrent acceptance against the same base — including two creations (`base_revision_id: null`) of the same visit ID — branches the chain and leaves the visit unresolved. Competing revisions are never collapsed on content equality, even when payloads match: no outcome becomes current without a coordinator.

Resolution marks the tips it covers as superseded and records the outcome: either one covered tip is selected as current, or the coordinator authors a new revision whose payload becomes current. Either form records the coordinator's identity and the contributing submission IDs. Superseded revisions remain retrievable in submission history.

## Submission Envelope

| Field | Meaning |
|---|---|
| `visit_id` | Client-generated UUID of the visit being created or edited |
| `base_revision_id` | Revision ID the edit started from; `null` creates the visit |
| `payload` | Complete visit: plot UUID, observation date, observer list, species cover estimates, notes |
| `idempotency_key` | Client-generated key that makes retries safe |

The author identity comes from the authenticated session, not the device: tablets are shared across the team, and the store records who signed in. The server stamps receipt time.

Acceptance rules:

- Validate the session, field types, and that the plot UUID exists in the catalog. Archived plots remain valid for edits to existing visits; the catalog's picker exclusion governs new visits, not this store.
- `base_revision_id` must reference a stored revision of that visit but need not be an active tip. Tablets offline for days submit against old bases, and blocking them would deny field work.
- A visit accepts submissions whether or not it is currently unresolved. A worker never waits on a coordinator.
- Idempotency: a retry with an accepted key and an identical payload — compared after canonical JSON normalization (object keys sorted, insignificant whitespace removed) — returns the original acceptance result without creating another stored submission; the same key with a different payload is rejected and the original submission is unchanged.
- The server serializes acceptance per visit so tip accounting stays exact under concurrent submissions.

## Retrieval

Current-state retrieval returns the visit's status and enough payload to continue work:

- `status: resolved` — the current revision in full: payload plus revision metadata, including the revision ID to use as the next base.
- `status: unresolved` — every active tip in full, flagged as competing; no single current state is implied. This status field is what downstream nodes key their unresolved-work handling on.

Submission-history retrieval returns every revision — active, superseded, or covered — with bases, authors, receipt times, and payloads, plus every resolution record: coordinator identity, contributing submission IDs, and outcome. Original submissions never drop out of history.

## Resolution Operation

A coordinator resolves an unresolved visit by submitting the set of active tips they reviewed (an optimistic guard) and an outcome:

- **Select** — name one of those tips as current.
- **Author** — supply a payload under the same field validation as submissions; it becomes a new current revision, and its contributing submissions are the covered tips.

The operation marks the covered tips superseded and records coordinator identity and contributing submission IDs. It is rejected if the visit's active-tip set no longer matches the submitted set — a submission may have arrived while the coordinator reviewed — and rejected when fewer than two revisions are active. Rejection leaves the visit untouched; the coordinator refetches and retries.

A later edit based on the current revision extends the chain linearly and the visit stays resolved. Recovering from a mistaken outcome is an ordinary submission: an authenticated coordinator submits a corrected payload against the current revision. No separate reversal operation exists.

## Downstream Obligations

These are contract consequences for sibling nodes, not their designs:

- **tablet-sync** sizes its local state around one retained base revision ID per fetched visit, whole-payload submissions with idempotency keys, and presentation of `unresolved` status with competing revisions.
- **review-export** sizes its coordinator interface around revision comparison for unresolved visits, and admits only `resolved` visits to the exported CSV.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Concurrent-edit reconciliation | Whole-visit revisions with coordinator resolution ([decision doc](decisions/whole-visit-revisions.md)) | Field-aware three-way merge | Merge rules can combine scientifically related edits without noticing; a larger comparison queue is operable by two coordinators. The decision doc carries the full criteria and the conditions that would reopen the choice. |
| Submission granularity | Complete visit payload per submission | Structured field-level changes | Whole-visit revisions review as the worker submitted them; deltas add tablet state and retry cases without reducing review work under this policy. |
| Unresolved-work representation | Derived from active tips: two or more tips unresolved, one tip resolved | A separate review-work table maintained beside revisions | Tip accounting derives from stored revisions, so status cannot drift from history; there is no second source of truth to reconcile. |
| Blocked field work | Accept submissions against any stored base, including while unresolved | Reject edits until resolution; restrict bases to active tips | Field workers proceed without connectivity or coordinator availability; stale bases are the offline normal, not an error. |
| Resolution failure handling | Optimistic guard on the reviewed tip set | Last-write-wins resolution; server-side fold of racing submissions | A submission arriving mid-review must not become current inside an outcome the coordinator never saw. |
| Wrong-outcome recovery | Ordinary coordinator submission against the current revision | Dedicated re-resolution or strike operation | One submission path to test and explain; history keeps both the original outcome and the correction. |

## Open Questions & Future Decisions

### Resolved

1. ✅ Concurrency policy: whole-visit revisions — recorded in [decisions/whole-visit-revisions.md](decisions/whole-visit-revisions.md).

### Deferred

1. Field validation bounds (maximum notes length, species-entry counts, numeric ranges for cover estimates) — set alongside implementation; not load-bearing to the contract's shape.

## References

- docs/high-level-design.md
- docs/intent/site-catalog/site-catalog-design.md
```

Context-free check: Decisions table rationale columns are filled; alternatives named; no reliance on conversation history. The rejected three-way-merge rationale lives only in the decision doc and the table row, not as body asides.

---

## LLD-level edge-case probe

Gaps in *this* LLD, each with my written lean — you triage: **confirm the lean / change it / defer**:

1. **Identical-content competitors.** Two workers submit byte-equivalent payloads against the same base. Lean: still competing, still review (written in the Revision Model) — no unattended outcome, even a trivial one.
2. **Double creation.** Two devices create the same `visit_id` (`base_revision_id: null` twice). Lean: accepted as competing revisions, visit unresolved (written) — rather than rejecting the second as a client bug.
3. **Mistaken resolution.** Lean: recovery is an ordinary coordinator submission against the current revision; no strike/reversal operation (written). Confirm, or do you want an explicit reversal?
4. **Idempotency equality.** Lean: identical means equal after canonical JSON normalization (written), not byte-exact wire equality.
5. **Ancient bases.** A tablet offline for weeks submits against a long-superseded revision, re-opening a resolved visit to unresolved. Lean: accepted anyway (written) — never-block holds even at archaeological staleness.
6. **Authored-resolution bookkeeping.** An author-outcome creates a new revision, but the LLD does not pin its `base_revision_id`. Lean: set it to one of the covered tips (contributing IDs come from the resolution record regardless). Needs a line either way.
7. **Validation bounds.** Notes length, species counts, cover ranges. Lean: deferred (written) — confirm deferral or specify now.

---

**STOP — Phase 2 review.** Number your feedback:

1. **Decision doc** — accept as written, or revise?
2. **LLD** — accept as written, or revise?
3. **Probe items 1–7** — for each: confirm the lean, change it, or defer (e.g. `1 confirm, 3 change to…`).
4. **Still open from Phase 1 (#3): the tenet.** Add *"Prefer review-visible resolution over automated combination when edits may be scientifically related"* to the HLD's Tenets / reword / reject?
5. **Cross-segment flag (pause, per cascade rules):** `site-catalog-design.md` still says *"Tablet-sync's visit submission and reconciliation behavior remains pending that choice"* — now stale. Permission to update that one sentence in the sibling node?

On approval I proceed to **Phase 3**: EARS specs for the record-store contract (including REC-004's text update, ID stable), with a consistency report — stopping again for your review.