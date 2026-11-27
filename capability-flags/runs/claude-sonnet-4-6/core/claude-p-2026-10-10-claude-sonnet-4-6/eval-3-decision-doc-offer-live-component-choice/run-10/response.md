Good. Now I'll compose the Phase 2 stop — presenting Phase 1 (HLD) and Phase 2 (LLD) together for review.

---

## Phases 1–2 complete — stop for review

**Phase 1 (HLD)** — minor update only. The architecture table now shows record-store as "Designed" and the note about tablet-sync/review-export waiting has been updated to say their contracts depend on record-store (not that they are blocked by an unresolved choice). No architectural change.

---

**Phase 2 (LLD)** — `docs/intent/record-store/record-store-design.md`

Here is the full updated design:

---

### Record Store

**Context** (updated): Tablet-sync must retain revision IDs and handle competing-revision notifications; review-export must present competing revisions for coordinator comparison and exclude unresolved visits from export.

---

**Submission Envelope**

Each submission carries:
- `visitId` — client-generated UUID
- `baseRevisionId` — UUID of the revision the worker edited from, or null when this is the first submission for the visit
- `idempotencyKey` — UUID preventing duplicate entries on retry
- `payload` — full visit state: observation date, observer list, species cover estimates, notes
- `authorId` — authenticated worker identity

---

**Revision Model**

Each accepted submission produces a revision: `revisionId` (server-assigned UUID), `visitId`, `baseRevisionId`, `payload`, `authorId`, `receivedAt`.

- Base = null, no prior revisions → creates first revision, becomes HEAD.
- Base = current HEAD → creates new revision, advances HEAD.
- Base = existing revision but not HEAD → recorded as competing revision; visit marked needs-review.

Multiple workers can independently create competing revisions against the same base; all are preserved.

---

**Visit Status**

Derived from revision history (not stored separately):
- `current` — single HEAD, no pending competing revisions.
- `needs-review` — one or more competing revisions exist.

---

**Current-State Response**

| Field | When `current` | When `needs-review` |
|---|---|---|
| `visitId` | present | present |
| `status` | `current` | `needs-review` |
| `currentRevisionId` | HEAD revision ID | absent |
| `currentPayload` | HEAD payload | absent |
| `competingRevisionIds` | empty | all competing IDs |

---

**Coordinator Review and Resolution**

Review response: each competing revision's payload, author ID, revision ID, and receipt time. No field-level diffing (display concern for review-export).

Resolution: coordinator selects one revision. System records `resolutionId`, `visitId`, `selectedRevisionId`, `competingRevisionIds` (all present at resolution), `coordinatorId`, `resolvedAt`. Visit returns to `current`. All competing revisions (including those not selected) remain in history permanently.

---

**Export Eligibility**

`needs-review` visits are excluded. Record-store enforces this; review-export queries only `current` visits.

---

**Decisions & Alternatives**

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrency policy | Whole-visit revisions | Field-aware three-way merge | Avoids maintained merge rules that could silently combine scientifically related fields (e.g., a species ID and its cover estimate) without recognizing the relationship. Larger coordinator queue is acceptable given the preference for explainable records. |
| Competing-revision detection | Base revision ID provided by submitter | Arrival-order detection; server-side timestamp comparison | Arrival order is not evidence of authority in offline scenarios. Submitter-provided base IDs detect forks without relying on clocks. |
| Visit status derivation | Derived from revision history at query time | Stored status flag | Derived status is always consistent; a stored flag is a second source of truth requiring maintenance across every operation that changes status. |

---

**Deferred open questions** (four items surfaced in the design, listed in the LLD):
1. Submission behavior when the visit is already needs-review (critical — must resolve before tablet-sync design).
2. Null base with pre-existing revisions — tablet state-loss scenario (must resolve before tablet-sync design).
3. Upper bound on concurrent competing revisions.
4. Retrieval of a visit that has never been submitted — "not found" vs. empty current state.

---

## LLD-level edge-case probe

Five gaps in this LLD's own mechanics, sorted by how much they could diverge at implementation:

**1. Submission arriving while visit is needs-review** *(most pressing)*
`REC-009` and `REC-010` reference "current HEAD," but a `needs-review` visit has no single HEAD. A worker submits with base = one of the competing revisions. Does that create another competing revision (pool grows), or is it held until resolved? The spec is silent. This is the submission-while-needs-review gap in the Deferred list — it needs a spec before tablet-sync can be written.

**2. Null base when revisions already exist** *(most pressing)*
A tablet that loses its local state submits with null base. `REC-008` covers null base + no prior revisions. `REC-011` covers unrecognized non-null base. Neither covers null base + revisions exist. This case is deferred but should be specced before tablet-sync handles state-loss recovery.

**3. Post-resolution submission on a pre-resolution base**
Coordinator resolves needs-review (picks R2 as canonical HEAD, R1 not selected). An in-flight submission with base = R1 then arrives. R1 exists in history but isn't the HEAD; per `REC-010`, this creates another competing revision and marks the visit needs-review again. Is this intended, or should late-arriving submissions against pre-resolution bases be handled differently?

**4. Orphaned revision chain after resolution**
Worker submits R3 with base = R2 (while R2 is a competing revision). Coordinator resolves by picking R1. R3's base (R2) is in history but was not selected as canonical. Is R3 a competing revision against R1? Should it surface in a subsequent needs-review state, or is it orphaned?

**5. Concurrent resolution race**
Two coordinators simultaneously resolve the same needs-review visit, each picking a different revision. No ordering guarantee is specified. The LLD doesn't describe a locking or last-write-wins rule for this case.

---

**Post-draft consistency notes**

- REC-010 and REC-012 introduce "competing revision" and "needs-review" as first-use terms in specs that travel by grep. I'd recommend adding a brief parenthetical to each — e.g., "competing revision (a revision that shares a base with the current HEAD)" and "needs-review (a visit with one or more unresolved competing revisions)" — so they stand alone when grepped out of context.
- Coverage looks complete for the specced behaviors. The four deferred items above are acknowledged gaps, not spec omissions.
- No contradictions found across REC-001 through REC-015.

---

Please review the LLD and probe. Specific questions for you:

1. **Probe item 1** (submission-while-needs-review): should the submission be accepted into the competing pool, or held until the coordinator resolves first? This drives a spec before tablet-sync can proceed.
2. **Probe item 2** (null base + revisions exist): should this be rejected outright, or treated as a tablet-recovery submission with a defined fallback (e.g., treated as a competing revision against the current state)?
3. **Probe items 3–5**: are these worth speccing now, or deferred to the tablet-sync/review-export sessions?
4. Any other changes to the LLD before we move to EARS specs (Phase 3)?