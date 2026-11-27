Phase 2 is done. Here is the updated LLD and the edge-case probe — **stopping for your review before writing specs**.

---

## Updated: `docs/intent/record-store/record-store-design.md`

```
---
parent: high-level-design
prefix: REC
---

# Record Store

## Context and Design Philosophy

This node owns visit persistence and the meaning of a current visit when
independently edited copies arrive. A visit is identified by a client-generated
UUID and refers to a catalog plot ID. Updates can arrive days after their
starting state was fetched. The server must not treat arrival order as evidence
that one worker's observations are more authoritative.

The concurrency policy is whole-visit revisions. Each submission is a complete
visit snapshot that names the server revision the worker started editing from.
When two submissions share the same base revision, both are preserved and the
visit is flagged for coordinator review. The record store does not merge fields
automatically; scientific correctness requires a human choice about which
observations are right.

Tablet-sync and review-export are designed after this node. Their contracts
derive from the revision model here.

## Submission Envelope

A submission carries:

- **visit ID**: the client-generated UUID identifying the survey plot visit
- **base revision ID**: the server revision the worker's edits started from;
  `null` for the first-ever submission of a new visit
- **idempotency key**: a client-generated key allowing safe retry on connection
  failure without creating a duplicate revision
- **submitting worker ID**: the authenticated worker's identity, bound at
  submission time
- **visit payload**: the complete record — observation date, observer names,
  species cover estimates, and notes

The base revision ID is the signal the server uses to detect competition.
A submission whose base revision does not exist in that visit's history is
rejected; the visit is left unchanged.

## Visit State Model

Every visit is in one of three states:

- **clean**: all accepted revisions form a single chain; the most recent is
  the current revision; no unresolved competition exists
- **unresolved**: at least two accepted revisions share the same base revision
  ID, or a submission arrived while the visit was already unresolved; coordinator
  review is required; the visit is excluded from the export-eligible set
- **resolved**: a coordinator has designated a canonical revision from the
  competing set; the visit re-enters the clean lineage at that revision

**State transitions:**

- A new visit's first accepted submission (base = `null`) creates revision 1 and
  the visit is clean.
- A submission whose base matches an existing revision and no other accepted
  revision shares that base advances the clean chain; the visit remains clean.
- A submission whose base matches a revision that another accepted submission
  already names as its base creates a competing revision and transitions the
  visit to unresolved.
- A submission arriving while the visit is already unresolved is accepted and
  added to the unresolved set; the visit remains unresolved.
- Coordinator resolution selects or synthesizes a canonical revision, transitions
  the visit to resolved, and that canonical revision becomes the new chain tip.

## Submission and Retrieval

Authenticate the submitting worker and validate field types and plot references
before accepting a submission. Preserve the original payload separately from any
later resolved representation. A retry with the same idempotency key and
identical payload returns the original acceptance result; reuse with a different
payload is rejected.

Current-state retrieval returns: the visit's state (clean, unresolved, or
resolved), the current canonical revision's payload, and the server revision ID
of that canonical revision. For unresolved visits, the response also includes
the IDs of all competing revisions so a review interface can surface them.

History retrieval returns all revisions for a visit in server receipt order.
Each entry includes: revision ID, base revision ID, submitting worker ID, server
receipt time, and visit payload.

## Resolution Operations

A coordinator resolves an unresolved visit by one of two operations:

1. **Select**: designate one competing revision as canonical. The system records
   the coordinator's identity, the resolution timestamp, and the IDs of the
   competing revisions that were considered.
2. **Synthesize**: submit a new combined revision (base = `null`, marked as
   coordinator-authored) that supersedes all competing revisions. The system
   records the coordinator's identity, the timestamp, and the IDs of the
   revisions it supersedes.

After resolution, the visit transitions to the resolved state. All competing
revisions remain in history alongside the resolution record.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Concurrent edit policy | Whole-visit revisions: each submission is a complete snapshot naming its base; competing submissions preserved for coordinator review | Field-aware three-way merge: disjoint field changes combined automatically, overlapping changes reviewed | Field merge reduces review queue but requires maintained merge rules that can silently combine scientifically related fields (e.g., species ID and cover estimate). Coordinators take a larger review queue over merge errors that are not visible. |
| Competing revision detection | Base revision ID comparison: a submission is competing when another accepted revision already names the same base | Arrival-time ordering; last-writer-wins | Base comparison preserves both submissions and is independent of clock synchronization and network order. |
| Coordinator resolution mechanism | Human selects one revision or submits a synthesized replacement | Automated heuristic selection | Scientific correctness of field observations requires a human judgment the system cannot supply. |

## Open Questions & Future Decisions

### Resolved
1. ✅ Concurrency policy: whole-visit revisions (see Decisions & Alternatives)

### Deferred
1. What happens when a late submission arrives for an already-resolved visit —
   does it reopen unresolved state, or is it rejected? Resolve before designing
   tablet-sync and review-export.
2. Whether the system should cap competing revisions per visit and surface a
   coordinator alert at that cap.

## References

- Parent design: docs/high-level-design.md
- Site catalog (plot reference validation): docs/intent/site-catalog/site-catalog-design.md
- Tablet-sync (derives submission envelope and retry model from this contract):
  docs/intent/tablet-sync/tablet-sync-design.md (not yet written)
- Review-export (derives revision comparison interface and export eligibility from
  this contract): docs/intent/review-export/review-export-design.md (not yet written)
```

---

## Edge-case probe

Four gaps in this LLD's own mechanisms — none block the design, but each has a spec or implementation implication:

**1. Synthesized-revision base collision**
The LLD says a coordinator synthesizes a revision with base = `null`. The competition detection rule is "a submission is competing when another accepted revision already names the same base." The original first-ever worker submission also has base = `null`. Under the current rule, the coordinator's synthesis would compete with that first submission and throw the visit back to unresolved. The LLD notes "marked as coordinator-authored" as the exemption, but doesn't specify how that flag is encoded. Two options: (a) coordinator submissions carry a distinct submission type that bypasses competition detection, or (b) synthesized revisions use a special sentinel base (e.g., `"coordinator"`) rather than `null`. Which way do you want this to go?

**2. Normal submissions after resolution**
The LLD says the canonical revision "becomes the new chain tip" after resolution, implying future worker submissions from that tip are valid. But it doesn't state this as an explicit invariant. If a worker was offline during the dispute and resurfaces with a submission based on a pre-competition revision, the outcome is also undefined — does it reopen the visit, or is it a delayed-competing revision handled by the same deferred question above? Worth confirming the clean-lineage intent is correct.

**3. Idempotency key scope**
The LLD says a retry with the same key and identical payload returns the original result. It doesn't say whether keys must be globally unique or are scoped per visit ID. This determines how tablets generate keys — a global UUID per submission attempt, or a per-visit attempt counter. Either works; it just needs to be stated.

**4. Visit with no clean canonical revision**
Current-state retrieval says it returns "the current canonical revision's payload." For an unresolved visit, there is no canonical revision yet — the LLD says to return the competing revision IDs instead, but it doesn't say what payload (if any) the current-state response returns for the visit's "best available" state. Should it return the most recently accepted competing revision's payload as a non-authoritative preview, or return no payload (forcing the caller to pick from the competing IDs)? This affects how tablets display an unresolved visit's current content.

---

Gaps 1 and 4 need a choice before specs can be written cleanly. Gaps 2 and 3 are clarifications I can fold into the LLD as stated invariants once you confirm the intent. What's your call on 1 and 4?