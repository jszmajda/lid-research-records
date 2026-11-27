**Phase 2 output — Record Store LLD** (`docs/intent/record-store/record-store-design.md`)

---

```markdown
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context

This node owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot ID. Updates can arrive days after their starting state was fetched. The server must not treat arrival order as evidence that one worker's observations are more authoritative.

Tablet-sync and review-export take their contracts from this node: the submission envelope, the current-state response, the unresolved-work representation, and the resolution operation. Neither sibling owns concurrency semantics.

## Architecture

The record store exposes authenticated submission, current-state retrieval, submission-history retrieval, and review-outcome operations. Persistence keeps original submissions, their authors, and server receipt times. A submission carries an idempotency key so a connection failure does not create another edit on retry.

Concurrency follows whole-visit revisions: every accepted submission stores a complete visit payload and names the base revision it was edited from. Competition is derived only from base revision IDs against the visit's current head. The server does not infer scientific relationships between fields and does not combine fields from different submissions.

A visit's scientific fields include observation date, observer list, species cover estimates, and notes.

## Revision Model

Each visit is a revision history. A revision records a revision ID, the base revision it extends (absent only for a visit's first revision), the complete visit payload, the author ID, and the server receipt time.

- **Resolved visit** (one head): a submission whose base revision is that head extends it linearly; the visit stays resolved. A submission whose base revision is any other revision in history becomes a second head; the visit becomes unresolved.
- **Unresolved visit** (multiple heads): a submission whose base revision is one of the open heads extends that head—the new revision replaces it in the head set, and the visit stays unresolved. A submission whose base revision is any other revision in history (an earlier linear revision or a superseded head) becomes an additional head.

Only resolution reduces the head count. Extending a branch never clears unresolved state, even when the extension leaves a single lineage from the common ancestor's point of view. Heads never combine implicitly. Losing heads and their original payloads remain in history after resolution; accepted submissions are never rewritten or dropped.

## Submission Envelope

A submission carries:

| Field | Meaning |
|---|---|
| visitId | Client-generated UUID of the visit being edited or created |
| baseRevisionId | Revision the editor started from; absent when creating a visit |
| payload | Complete visit record: plot UUID, observation date, observer list, species cover estimates, notes |
| idempotencyKey | Client-generated key identifying this submission attempt |

The server authenticates the submitting worker and validates field types and plot references before acceptance. On acceptance it assigns a submission ID, the author ID, a server receipt time, and a revision ID.

A retry with the same key and an identical envelope returns the original acceptance result without another stored submission. The same key with a different envelope is rejected and leaves the stored submission unchanged. A base revision ID that does not exist in the visit's history is rejected; the payload is not stored.

Preserve the original payload exactly as submitted. Later resolved or current representations never overwrite stored submissions.

## Current-State Response

Retrieval returns whether unresolved review work exists for the visit, alongside enough structure for callers to render a usable state or a comparison:

- **Resolved visit**: `unresolved: false`, plus the current head (revision ID, payload, author, receipt time).
- **Unresolved visit**: `unresolved: true`, plus every head (revision ID, base revision ID, payload, author, receipt time). The most recent revision that was current before the visit became unresolved is included as the comparison baseline when one exists; a visit created directly into competition (two first-round submissions on the same new visitId) has no baseline.

Submission-history retrieval returns all revisions in receipt order, including superseded heads, for audit and deep comparison. Callers must not treat history order as an edit order across competing heads.

## Unresolved-Work Representation

Unresolved work is visit-scoped: a visit is either resolved or unresolved, never partially unresolved by field. While unresolved, every head is review work. There is no server-side prioritization, field-level status, or automatic clearance—work leaves this state only through resolution.

## Resolution

A coordinator resolves an unresolved visit by recording a resolution that names:

| Field | Meaning |
|---|---|
| visitId | Visit being resolved |
| contributingSubmissionIds | Submission IDs of the heads considered |
| outcomeRevisionPayload | Complete visit record that becomes current |
| idempotencyKey | Key for safe retry of the resolution call |

Resolution also records the coordinator's identity and the server receipt time. The outcome becomes the visit's single current head; previously competing heads remain in history marked superseded, with original payloads intact. A resolution must cite every head that was open at the time it is accepted; a resolution that omits a head is rejected.

Resolutions are accepted only while the visit is unresolved. Resolving a resolved visit, or citing a submission ID that is not an open head, is rejected.

A submission accepted after resolution compares its base revision to the new head under the ordinary revision rules: linear if it matches, competing if it does not.

## Downstream Contract Work

Tablet-sync and review-export are not designed here; each must accommodate the following from this node.

**Tablet-sync** will:

- Store the base revision ID with every local draft and send it in the submission envelope; drafts created against a visit with no prior revision omit it.
- Send the complete visit payload on every submission, not field deltas.
- Interpret acceptance as either a linear extension or a new competing head from the current-state response, and surface unresolved state to the worker when their submission competed.
- Handle rejection of unknown base revision IDs by refreshing current state and re-deriving the draft's base without dropping the worker's payload.
- Size retry logic around envelope-level idempotency keys, including resolution calls made from the review surface if that surface shares the client.

**Review-export** will:

- Present heads side by side for an unresolved visit, using the baseline revision when present.
- Drive resolution through the resolution operation, citing contributing submission IDs and sending a complete outcome payload.
- Treat `unresolved: true` as ineligible for export and `unresolved: false` as export-eligible at the record-store level, without re-deriving concurrency from raw submissions.
- Read submission history for provenance display rather than reconstructing authorship from the current head alone.

Both link back to this node rather than inventing concurrency semantics.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Concurrent-edit policy | Whole-visit revisions: each edit names its base revision and carries a complete payload; non-matching bases create competing heads resolved by a coordinator | Field-aware three-way merge: edits send base snapshots plus structured changes; disjoint fields combine automatically; overlaps go to review | The team will accept a larger review queue in exchange for never auto-combining scientifically related edits under rules that cannot see the relationship. Merge rules for scalars, observer lists, and species entries would be maintained indefinitely and could silently produce combined records a coordinator never intended to approve as a unit. Whole-visit revisions keep each submitted visit intact, keep tablet logic to base revision IDs rather than field diffing, and make review a choice between complete revisions. Field-aware merging remains credible if review volume becomes operationally unworkable or if export deadlines start missing because unrelated concurrent edits all require coordinator time; revisiting it would replace the resolution-centric review surface with field-level provenance and maintained merge rules. |
| Unresolved work granularity | Visit-level: a visit is resolved or unresolved as a whole | Per-field or per-submission partial resolution | Partial states would reintroduce field-level merge machinery into review and export eligibility. Two coordinators resolving whole visits keeps the export rule a single boolean. |
| Resolution outcome shape | Coordinator supplies a complete outcome payload citing all open heads | Server picks a winning head automatically; or resolution accepts a subset of heads | Automatic selection would discard the losing submission's differences without inspection, violating the project rule against silently discarding submitted edits. Accepting a subset would leave uncited heads open with no path to export. A complete payload lets the coordinator take the best head as a starting point or adjust fields while leaving an attributable, inspectable outcome. |
| Stale-base submissions after resolution | Accept under ordinary rules (linear or competing against the new head) | Reject submissions whose base predates the latest resolution | Rejection would push work back to the tablet without preserving the submission server-side. Acceptance keeps every edit in history and routes disagreement through the same review queue. |

## Open Questions & Future Decisions

### Resolved

1. ✅ Concurrency policy is whole-visit revisions; field-aware three-way merge is documented above as the alternative to revisit if review volume fails operationally.

### Deferred

1. Whether review-export may export a resolved visit whose outcome payload was never the direct head of any worker submission (coordinator-authored outcomes) without an extra confirmation step — review-export's design decision.
2. Whether tablet-sync shows competing-head detail to workers or only a "submitted; under review" state — tablet-sync's design decision.
3. Retention limits on superseded heads and full history at season scale (~6,000 visits) — implementation detail unless archive requirements change.
```

---

**LLD-level edge-case probe** — gaps pointed at this LLD. Which fix in the LLD now vs. defer?

1. **Visit creation race**: two first submissions share a `visitId` with no base — both become heads with no baseline (described in Current-State Response). Is no-baseline comparison acceptable for review-export, or must record-store synthesize an empty baseline?
2. **Head-set check timing**: “cite every head open at the time it is accepted” — concurrent resolution vs. a new competing submission in flight: is last-writer-wins on the head set enough, or need a formal compare-and-swap on head count?
3. **Payload equality for idempotent retry**: “identical envelope” — byte-identical JSON vs. field-equal after canonicalization? Affects tablet retry encoding.
4. **Authoring a resolution with edited fields**: LLD allows coordinator outcome ≠ any head; does resolution need an explicit “edited from head X” pointer for provenance UI, or are `contributingSubmissionIds` enough?
5. **Worker identity on shared tablets**: author ID comes from authentication at submit time — no LLD gap unless the team needs anonymous/shift-level attribution (would be HLD-level).
6. **`plotId` changes in a whole-visit payload**: is moving a visit to a different plot UUID a normal field edit under this model, or should it be rejected? LLD validates “plot references” but doesn’t say whether plot is mutable.

**Decision-doc offer (once):** the concurrent-edit policy choice (whole-visit vs. field-aware merge) is contested-looking, multi-criteria, and tablet-sync/review-export will size around it — it clears the bar for a full decision doc at `docs/intent/record-store/decisions/concurrent-edit-policy.md`, with the Decisions row as the alternative. Accept the doc, or keep the row only?

Approve to proceed to Phase 3 (EARS specs), or give numbered feedback (including probe triage and the decision-doc yes/no).