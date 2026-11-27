I drafted the whole-visit contract in [docs/intent/record-store/record-store-design.md](docs/intent/record-store/record-store-design.md), including your rationale: preserving scientifically related edits as a unit is worth a larger review queue.

**This is the record-store design review stop.** Several choices need your judgment before the contract is complete.

## Draft contract

### Storage and submission

Each submission contains:

| Field | Meaning |
|---|---|
| `visitId` | Client-generated visit UUID |
| `idempotencyKey` | Retry identity scoped to the authenticated author |
| `baseRevisionId` | Revision being edited; null for an initial submission |
| `payload` | Complete plot reference, observation date, observer list, species cover estimates, and notes |

The store retains immutable original submissions, authenticated author IDs, receipt times, and base relationships. Revision IDs are opaque server-issued identifiers; arrival times and client clocks do not establish scientific authority.

Submissions are authenticated and validated before acceptance. Plot references resolve through site-catalog, including historical archived references. A non-null base must exist and belong to the same visit.

Acceptance and its visit-state transition are atomic and serialized per visit. The response contains submission and revision IDs, receipt time, whether the submission advanced current or entered review, and the visit-state version at acceptance. Durable acceptance does not imply review approval or export inclusion.

A retry with the same author-scoped key and identical envelope returns the original acceptance result. Different content under that key is rejected. Retry lookup precedes state-dependent validation, so subsequent changes cannot invalidate an accepted retry. Live visit state is retrieved separately.

### Visit state

| Existing state | Accepted submission | Result |
|---|---|---|
| Visit absent | Null base | Create the visit with this revision current |
| Current, no unresolved work | Base equals current revision | Advance current |
| Current, no unresolved work | Base differs from current, including null | Enter review with current and incoming revisions as candidates |
| Review pending | Any valid base, including null | Add the incoming revision to unresolved candidates; remain in review |

Review-pending visits have **no usable current revision**. The last settled revision remains available as historical context.

Every accepted revision remains stored, including revisions with duplicate content. The store preserves ancestry and unresolved candidates so coordinators can distinguish successive edits from competing edits. It does not automatically combine fields.

Visit retrieval returns status, state version, usable current revision when available, last settled revision, and unresolved revision IDs. History retrieval exposes complete payloads, authors, receipt times, base relationships, and resolution outcomes. Unknown visits have a distinct not-found outcome.

Errors distinguish authentication failures, invalid payloads, unknown plots, unknown bases, bases belonging to another visit, and conflicting idempotency-key reuse. Rejected submissions do not create accepted revisions or change visit state.

### Coordinator resolution

A coordinator resolves a versioned review snapshot, identifying the visit, expected state version, and complete candidate set addressed.

New submissions change the review version. Stale resolutions are rejected so work arriving after inspection cannot be silently cleared.

An accepted resolution atomically retains:

- Coordinator identity and server time.
- Contributing submission IDs.
- Candidates addressed.
- The resulting complete visit revision.

Original submissions remain available. Resolving the complete candidate set restores usable current state. Later submissions based on a non-current revision return the visit to review.

Whether coordinators select an existing revision or author a new complete revision remains open, along with resolution retry and response details.

### Downstream obligations

Tablet-sync will need complete payloads, base revision IDs, durable retry keys, and separate representations of acceptance and current state.

Review-export will need complete revision history, revision comparison, versioned review work, and resolution provenance. **Unresolved visits are excluded from CSV export; the last settled revision is not an export fallback.**

### Recorded decisions

| Decision | Selection and rationale |
|---|---|
| Concurrent edits | Whole-visit revisions. Field-aware three-way merging can combine scientifically related changes without recognizing the relationship; the larger review queue is accepted. |
| Precedence | Base relationships and explicit review outcomes. Arrival order and client timestamps do not establish authority. |
| Resolution concurrency | Check the reviewed version and complete candidate set. A resolution cannot clear arrivals the coordinator has not inspected. |

## Decisions and probe findings

The design-level edge-case probe surfaced these questions. Please choose which to settle now and which to defer:

1. **Resolution capability:**  
   **A. Select an existing revision only** — simpler comparison workflow and provenance, but correcting both candidates requires another edit.  
   **B. Also author a new complete revision** — handles cases where neither submission is correct, but needs a complete-edit workflow and explicit provenance.

2. **Retry equality:** Exact serialized bytes, or parsed structural values? Bytes require identical retry serialization; structural equality tolerates object-key ordering but needs precise equality rules.

3. **Plot corrections:** Can a revision correct the visit’s plot UUID, or is that association immutable after creation?

4. **Invalid resolutions:** I propose distinct errors for unknown visits, visits without pending review, and mismatched candidate sets, with no state change. Does that fit?

5. **Selected revision identity:** If a coordinator selects an existing revision, does that exact ID become current, or does resolution create a new revision ID? That determines how later tablet edits against the selected revision are classified.

6. **State versions:** I propose a non-repeating version change on every accepted creation, advance, competing arrival, and resolution; retries leave live state unchanged. Does that fit?

Concrete validation schemas, transport error formats, and database implementation remain deferred.

## Coherence and decision record

The existing `REC-001`–`REC-006` specs remain compatible with the chosen policy but do not yet cover the new contract. Their update follows design approval. There are no tests or implementation in this repository. `git diff --check` passed.

The HLD still describes the concurrency choice as unresolved. May I update those references when this design is approved?

Finally, this choice has credible alternatives and will shape both downstream designs. **Would you like a standalone record-store decision document capturing those trade-offs, or is the Decisions & Alternatives row sufficient?**