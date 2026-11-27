**Phase 2 complete.** HLD edits stand as approved. The full decision doc and the finished record-store LLD are written to disk; both appear in full below, followed by the LLD-level edge-case probe. (Carried over from Phase 1: the tenet question is still open — restated at the end.)

---

## Decision doc — `docs/intent/record-store/decisions/whole-visit-revisions.md`

```markdown
# Decision: Whole-visit revisions for concurrent visit edits

## Context

Field workers edit the same plot visit from tablets that may be offline for up to 48
hours, so two workers routinely start from the same visit state and submit days apart.
The record store must decide how those concurrent edits become the current record.
Arrival order is not evidence of authority, and no original submission may be discarded
or silently overwritten (HLD tenet: Do not silently discard a submitted edit). Whatever
is chosen sets the submission metadata tablet-sync sends, the shape of coordinator
review work, and which record states review-export may include in the partner CSV.

## Decision Elements

- **Scientific-meaning safety** — major. The mechanism must not combine edits in ways
  nobody notices. A visit's fields are scientifically related (a species identification
  and its cover estimate, an observer list and the notes that attribute work); rules
  keyed on field names cannot see those relationships. Turns on the HLD tenets Keep the
  path from a submitted observation to an exported value inspectable and Do not
  silently discard a submitted edit.
- **Implementation and maintenance burden** — major. Whichever mechanism ships must be
  maintained by the team that runs the product as it evolves (visit schema changes, new
  fields, observer-list edits). Turns on the HLD tenet Prefer workflows two
  coordinators can operate without a dedicated systems administrator.
- **Review workload before the Friday export** — moderate. Two coordinators resolve
  review work weekly; more competing-edit volume means more comparisons before export.
- **Coordinator review comprehensibility** — moderate. The review interface must let a
  coordinator see what differs and choose confidently without specialized tooling.
  Turns on the two-coordinator tenet above.
- **Tablet storage and submission shape** — moderate. Tablets keep drafts across
  48-hour disconnections; either full payloads or base snapshots plus structured
  changes must fit comfortably on shared devices.

A latent criterion considered and cut: speed of first submission — both options let a
worker submit offline without re-fetching, so they score equally and the element does
not discriminate.

## Options in the Domain

### Whole-visit revisions

**Description.** Every visit has a numbered revision. Each submission carries the base
revision ID the worker started from and a complete visit payload — the whole record as
the worker last saw it, edited. If the base matches the current revision, the payload
becomes the next revision. If another revision has since become current, the submission
is still accepted and retained as a competing complete revision; the visit is marked as
having unresolved review work. A coordinator compares the competing revisions and
selects one as the new current revision. Nothing is merged field-by-field, and no
original submission is ever dropped.

**Demonstration.** Visit sits at revision 3. Tablet A and Tablet B both fetched
revision 3, both go offline, both edit. A submits first: revision 4 (current). B
submits with base 3: retained as a competing revision; the visit flags unresolved work.
A coordinator compares A's and B's payloads, selects one, and revision 5 carries the
winner. Both original submissions remain in history.

**Analysis.**

- Scientific-meaning safety — strong. Competing revisions arrive intact; a coordinator
  always sees whole submissions and never inherits an automated combination of related
  fields.
- Implementation and maintenance burden — strong. Acceptance is a base-revision
  comparison plus retention; there are no merge rules to maintain as the visit schema
  evolves.
- Review workload before the Friday export — weak. Edits to unrelated fields still
  produce competing revisions and review work; the queue is larger than a merge scheme
  would produce.
- Coordinator review comprehensibility — strong. The review surface is a comparison of
  two complete visits — the same object the field worker saw.
- Tablet storage and submission shape — strong. The tablet keeps a base revision ID (a
  few bytes) and sends the payload it already holds.

**Summary.** Buys safety and simplicity with a deliberately larger review queue.

### Field-aware three-way merge

**Description.** Each tablet keeps a base snapshot of the visit it fetched and submits
structured changes (per-field deltas) rather than a whole payload. On arrival the
server three-way merges: changes to disjoint fields combine automatically; changes that
overlap go to review. Combining scalar fields, observer lists, and species entries
requires maintained merge rules, and the review/export side needs field-level
provenance so a coordinator can see which submission supplied each value.

**Demonstration.** Same scenario: A corrects an observer name; B adds a missing
species. Disjoint fields — the server combines both automatically and no review work is
created. Had both revised the same species' cover estimate, the overlap would go to
review with field-level provenance showing each submission's contribution.

**Analysis.**

- Scientific-meaning safety — weak. Disjoint-field combination can cross scientific
  relationships the rules do not model: an identification revised in one submission and
  its cover estimate revised in another are disjoint by field name but related
  scientifically, and would merge without anyone noticing.
- Implementation and maintenance burden — weak. Merge rules for scalars, observer
  lists, and species entries must be built and maintained as the schema changes;
  provenance tracking adds a second maintained surface.
- Review workload before the Friday export — strong. Unrelated edits never reach
  review; only true overlaps do.
- Coordinator review comprehensibility — partial. Overlap review needs field-level
  provenance views; the coordinator must trust that non-overlapping combinations were
  correct.
- Tablet storage and submission shape — partial. Base snapshots plus change structures
  are heavier to keep consistent across long offline periods and app updates than a
  revision ID and a payload.

**Summary.** Buys a smaller review queue with merge rules whose correctness on related
fields the system cannot verify.

## Selection

**Whole-visit revisions.** It wins the two major criteria outright: no mechanism ever
combines scientifically related edits without a coordinator seeing the whole
submissions, and there are no merge rules for two coordinators to maintain. It also
wins review comprehensibility and tablet shape. It loses review workload — a larger
queue of competing revisions, including conflicts over unrelated fields — and that loss
is accepted deliberately: a visible queue a coordinator can work through beats an
invisible combination the system cannot audit.

Committed, the choice obligates downstream:

- **tablet-sync** must track a base revision ID per draft, send it with each
  whole-payload submission, and surface pending competing revisions to the field worker.
- **review-export** must provide a revision comparison workflow for competing
  revisions and exclude visits with unresolved review work from the export set until a
  coordinator resolves them.

It forecloses silent field-level combination for this release; a visit never becomes
export-ready by server-side merging.

The decision turns on Do not silently discard a submitted edit and Keep the path from a
submitted observation to an exported value inspectable, and is taken against the
efficiency preference a merge scheme would serve.

**Why the other approach would still be considered.** Field-aware three-way merge
remains the credible alternative if experience contradicts the weights here: if the
review queue demonstrably outruns two coordinators before the Friday export, or if the
field-level provenance review-export builds for comparison work turns out to make merge
rules cheap to maintain, the trade should be re-run. Any revisit must still pass the
preservation gate — no original submission may be discarded — and should expect to
re-examine the scientific-meaning criterion, which is where this option loses.
```

---

## LLD — `docs/intent/record-store/record-store-design.md` (finished)

```markdown
# Record Store

## Context

This node owns visit persistence and the meaning of a current visit when independently
edited copies arrive. A visit is identified by a client-generated UUID and refers to a
catalog plot ID. Updates can arrive days after their starting state was fetched,
sometimes while the submitting tablet has been offline for the expected 48-hour window.
The server must not treat arrival order as evidence that one worker's observations are
more authoritative.

A visit's scientific fields include observation date, observer list, species cover
estimates, and notes. Some edits are unrelated, such as correcting an observer name and
adding a missing species. Other edits are related, such as revising a species
identification and its cover estimate. The server cannot infer these relationships from
field names, so the concurrency mechanism never combines fields automatically.

Tablet-sync and review-export are designed after this node's contract: submission
metadata, the shape of review work, and which record states can enter an export all
follow from it.

## Revision Model

Concurrency follows whole-visit revisions (see decisions/whole-visit-revisions.md):

- Each accepted visit payload becomes a numbered revision. The first accepted
  submission creates revision 1.
- Every submission names the base revision ID the worker started from (0 for the
  submission that creates revision 1).
- When the base revision ID equals the visit's current revision, the submitted payload
  becomes the next revision.
- When the base revision ID is behind the current revision, the submission is still
  accepted and retained in full as a competing revision. The visit is marked as having
  unresolved review work. The pre-conflict revision remains current until a coordinator
  resolves.
- Competing revisions may stack: any number of submissions may accumulate against a
  visit with unresolved work, and all of them are retained.
- A base revision ID the server has never issued, or one ahead of the current revision,
  is rejected as invalid; it cannot name a starting state the worker actually fetched.

Original submissions are never rewritten, merged, or discarded. The current revision is
a pointer to one retained payload, not a synthesis of others.

## Submission and Retrieval

### Submission envelope

Each submission carries:

| Field | Meaning |
|---|---|
| visitId | Client-generated UUID identifying the visit |
| baseRevisionId | Revision the worker fetched before editing (0 = creating revision 1) |
| payload | The complete visit record: plot UUID, observation date, observer list, species cover estimates, notes |
| idempotencyKey | Client-generated key making retry safe across connection failures |

The server authenticates the submitting worker and records the author ID and server
receipt time alongside the stored payload. It validates field types and that the plot
UUID exists in the catalog before accepting. The payload is preserved separately from
any later resolution outcome.

Idempotency: a retry with an accepted key and an identical payload returns the original
acceptance result without creating another stored submission; reuse of an accepted key
with a different payload is rejected and leaves the original submission unchanged.

### Retrieval

Current-state retrieval returns:

- the current revision (revision ID and payload),
- whether unresolved review work exists for the visit,
- when unresolved: the competing revisions — each with its submission ID, author ID,
  server receipt time, base revision ID, and payload.

The current revision does not change when a competing submission arrives, so retrieval
always has a stable value to return alongside the unresolved-work indicator.
Submission-history retrieval returns every stored submission for the visit in receipt
order, including those already resolved, so the path from any submitted observation to
the current record stays inspectable.

## Resolution

A coordinator resolves unresolved review work by selecting one revision — the current
revision or any competing submission — as the winner. The resolution:

- records the coordinator's identity,
- records the contributing submission IDs (every competing submission the resolution
  settles),
- records the selected submission as the source of the winning payload,
- issues the next revision ID carrying that payload, and
- clears the visit's unresolved-work flag.

Resolution selects whole submitted payloads; it does not compose fields from multiple
submissions. After resolution, later submissions are compared against the new current
revision as usual. If a stale-base submission arrives while a resolution is in flight,
it is retained as a competing revision against whatever revision is current when it is
accepted, and the visit returns to unresolved work. A second resolution attempted
against a visit that another coordinator has already resolved is rejected; the
requester re-fetches and re-evaluates.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Concurrent visit edits | Whole-visit revisions: submissions name a base revision ID; competing complete revisions await coordinator resolution (decision doc linked) | Field-aware three-way merge: base snapshots plus structured changes, disjoint fields combined automatically | Merge rules keyed on field names can combine scientifically related edits without anyone noticing; the accepted cost is a larger review queue |
| Stale-base submissions | Accept and retain as competing revisions; never reject a worker's edit for being based on an old revision | Reject with a stale-revision error, requiring the worker to re-fetch before editing | Tablets are offline up to 48 hours; rejection discards the worker's editing window and conflicts with keeping field workers collecting observations without connectivity |
| Resolution composition | Coordinator selects one existing revision as the winner | Coordinator authors a fresh payload combining preferred values from competing revisions | Authoring a fresh payload is field-level combination by hand at resolution time; selection keeps every exported value traceable to a submission |

## Downstream Obligations

These obligations originate in this node's contract. Each is owned by the sibling node
that must accommodate it when that node is designed:

- **tablet-sync** retains a base revision ID per draft, sends it with each
  whole-payload submission, and surfaces pending competing revisions to the field
  worker so a stale-base outcome is explainable on the device.
- **review-export** provides a revision comparison workflow over competing submissions
  and excludes visits with unresolved review work from the export set until a
  coordinator resolves them.

Neither sibling may invent its own concurrency semantics; both consume the envelope,
retrieval shape, and resolution operation defined here.

## Open Questions & Future Decisions

### Resolved

1. ✅ Concurrency policy for concurrent visit edits: whole-visit revisions, recorded
   with full tradeoffs in decisions/whole-visit-revisions.md.

### Deferred

1. Retention and compaction policy for resolved and losing submissions — first release
   retains all submissions indefinitely per the preservation requirement; pruning is
   not needed at 6,000 visits per season yet.

## References

- High-level design: docs/high-level-design.md
- Decision doc: decisions/whole-visit-revisions.md
- Sibling catalog contract: docs/intent/site-catalog/site-catalog-design.md
```

---

## LLD-level edge-case probe

"What happens when…" questions aimed at this LLD's own gaps. For each, reply **fix in LLD** or **defer** (deferred items move to Open Questions):

1. **Current advances while unresolved work sits.** Visit is unresolved (competing revision B pending against current 4). A third worker submits with base = current 4 and becomes revision 5. Now if the coordinator selects B, B's payload — a whole record built on revision 3 — becomes current and silently reverts revision 5's non-conflicting edit. Freeze current while unresolved (queue such submissions), allow advancement and rely on the comparison screen, or something else?
2. **Fresh key, identical payload.** A tablet app is killed after acceptance but before marking the draft synced; on restart it re-sends the same payload under a *new* idempotency key. Current behavior per the LLD: accepted again as a new revision (or a spurious competing revision). Should a payload identical to the current revision be a no-op returning the current revision?
3. **Archived-plot submissions.** LLD says "validates the plot UUID exists in the catalog." Site-catalog excludes archived plots from the new-visit picker but keeps them resolvable. Are submissions creating a *new* visit on an archived plot rejected? Are edits to an *existing* visit on an archived plot accepted?
4. **"Identical payload" semantics.** Idempotency and any future comparison UI depend on payload equality — is that byte-equality, or normalized (whitespace, observer order, species-entry order)?
5. **Revision ID scope.** The LLD says "numbered revision" and "revision 1" — confirm these are per-visit integers (visit X: 1, 2, 3…), not a global sequence, and I'll state it explicitly.
6. **Never-submitted visit retrieval.** What does current-state retrieval return for a visitId the server has never seen — not-found, or empty? (Tablets may query after a visit was created locally only.)

---

**Carried over from Phase 1 (question 2, still open):** add this line to the HLD's `## Tenets`?

> *Prefer visible review queues over automation that might silently reshape scientific meaning.*

Reply with, e.g.: "1. freeze, 2. no-op, 3. reject new / allow edits, 4. normalized, 5. yes per-visit, 6. not-found; tenet: add" — then I'll amend the LLD and stop for Phase 3 (EARS specs).