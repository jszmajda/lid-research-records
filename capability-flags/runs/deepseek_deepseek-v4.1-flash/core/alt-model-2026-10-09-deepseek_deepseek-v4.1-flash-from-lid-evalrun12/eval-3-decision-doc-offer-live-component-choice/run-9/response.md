## Phase 1 — HLD check

The concurrency mechanism was always record-store's to own (the HLD says so explicitly), so choosing whole-visit revisions does **not** change the HLD's architecture. I made one coherence edit: the architecture table now reads `Drafted; whole-visit revisions selected`, and the paragraph after it no longer calls the choice "unresolved." That is the only HLD touch.

## Phase 2 — Record Store LLD (updated)

Full text now at `docs/intent/record-store/record-store-design.md`:

---

**# Record Store**

**## Context**

This node owns visit persistence and the meaning of a current visit when independently edited copies arrive. A visit is identified by a client-generated UUID and refers to a catalog plot ID. Updates can arrive days after their starting state was fetched. The server must not treat arrival order as evidence that one worker's observations are more authoritative.

The concurrency policy is **whole-visit revisions**. Each submission is a complete visit revision that names the revision it started from; independently edited copies become competing revisions that a coordinator resolves by selecting one intact revision. This preserves each worker's submitted visit as a unit and needs no server-side field merge rules. The trade is a larger coordinator review queue: even edits to unrelated fields become review work. Tablet-sync retains base revision IDs and shows pending competing revisions; review-export compares revisions and holds unresolved visits out of the partner CSV.

**## Architecture**

The record store exposes authenticated submission, current-state retrieval, submission-history retrieval, and review-resolution operations. Persistence retains every original revision, its author, its base revision pointer, and its server receipt time. A submission carries an idempotency key so a connection failure does not create another edit on retry.

A visit's scientific fields are observation date, observer list, species cover estimates, and notes. A revision carries a complete set of those fields; the store never combines fields from two revisions.

**### Revision Model**

- A **revision** is one complete visit payload submitted by one worker, identified by a client-generated `revisionId`, and naming the `baseRevisionId` it started from (null for a visit's first revision). Revisions of a visit form a tree by base pointer.
- The visit's **current revision** is the revision the store treats as its present state. It begins as the first accepted revision.
- A submission is **clean** when its base is the visit's current revision; it advances the current revision.
- A submission is **competing** when its base is any other revision the store knows for that visit; it is stored intact and the visit becomes **unresolved**. A competing submission based on an existing competing revision supersedes it, so the competing set stays at branch tips.
- A visit is **unresolved** while it holds at least one competing revision. A clean advance does not clear existing competing revisions.
- A visit is **resolved** when it holds no competing revisions.

**### Submission Envelope**

| Field | Source | Notes |
|---|---|---|
| `visitId` | client | stable UUID for the visit |
| `revisionId` | client | UUID for this complete revision |
| `baseRevisionId` | client | the revision this edit started from; null for a visit's first revision |
| `authorId` | server (authenticated) | submitting worker |
| `idempotencyKey` | client | retry identity |
| `plotId` | client | must resolve in the site catalog |
| `observationDate`, `observerNames`, `speciesCoverEstimates`, `notes` | client | complete scientific payload |

The server validates field types and plot references before accepting, and assigns the receipt time.

**## Submission and Retrieval**

**### Submission** — Authenticate the worker and validate the envelope. Preserve the submitted payload as its own revision, separately from the visit's current state.

- A first submission for a visit (null base) creates the visit and its first revision, which becomes the current revision.
- A clean submission advances the current revision to the new revision.
- A competing submission is stored as a competing revision and marks the visit unresolved; the current revision is unchanged.
- A retry with the same idempotency key and an identical payload returns the original acceptance result; reuse of a key with a different payload is rejected and leaves the stored submission unchanged. The payload for this comparison includes the base revision.

**### Retrieval** — Current-state retrieval returns the visit's plot reference, a resolution status (`resolved` or `unresolved`), and the current revision's fields and metadata. When the visit is unresolved, the response also lists every competing revision — each with its `revisionId`, `baseRevisionId`, author, receipt time, and complete fields — so a coordinator can compare candidates. Submission-history retrieval returns every revision with its base pointer, author, and receipt time, making the edit path from a submitted observation to the current value inspectable.

**### Resolution** — A coordinator resolves an unresolved visit by selecting one candidate revision: the current revision or any competing revision. The selected revision becomes the visit's current revision, the competing set is cleared, and the visit becomes resolved. Every revision is retained. The store records the coordinator's identity, the selected revision, the contributing submission IDs, and the resolution time with the outcome.

**## Decisions & Alternatives**

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrent-edit policy | Whole-visit revisions | Field-aware three-way merge | Preserves each submitted visit as a unit and avoids maintained merge rules that could silently combine scientifically related edits; accepts a larger coordinator review queue. |
| Resolution action | Coordinator selects one candidate revision | Field-level merge at review; automatic union | Keeps resolution to a single choice and needs no merge logic in the store. |
| Retention on resolution | Retain every revision; resolution only moves the current pointer | Discard losing revisions | The HLD tenet forbids silently discarding a submitted edit, and the edit path must stay inspectable. |

**## Open Questions & Future Decisions**

**Resolved:** ✅ Concurrent visit edits use whole-visit revisions.

**Deferred:**
1. Handling of an unknown `baseRevisionId` — a base the store has never accepted for that visit. Proposed default: reject with a resync signal rather than store as competing. Confirm before EARS.
2. Whether a coordinator may hand-compose a new revision instead of selecting an existing one. Deferred to review-export.
3. Whether long revision histories need pruning. At expected scale, no pruning planned for the first release.

---

## Phase 2 edge-case probe

I delegated the probe to a subagent that saw only the docs, not our conversation. It returned these gaps; I have **not** silently folded them in — please triage which to fix now vs defer:

1. **Two concurrent first submissions (both null base) for the same visit.** "Competing" keys off a base the store *knows*; it is unstated whether a second null-base submission matches or diverges. *(creation race)*
2. **A competing submission arrives after resolution.** Does the visit re-open to unresolved, or is a pre-resolution base rejected? *(state transition)*
3. **Two coordinators resolve the same visit concurrently.** No ordering, locking, or losing-resolution outcome is given. *(race)*
4. **Idempotency-key scope** — global, per-visit, per-author? — and whether rejected submissions register a key. REC-003 covers only accepted keys. *(error shape)*
5. **Non-null base on a visit that does not exist yet** — unknown-base rejection or creation path? Collides with Deferred item 1. *(transition)*
6. **Resolution on an already-resolved visit, or naming a revision that is neither current nor listed competing.** Precondition and failure response undefined. *(error shape)*
7. **Reuse of an existing `revisionId` with a different payload/base.** No uniqueness or collision rule stated. *(invariant)*
8. **Selecting a competing revision that a later competing branch superseded.** Is the candidate set only branch tips, or any retained non-current revision? *(candidate definition)*
9. **"Contributing submission IDs" (REC-006) vs. an envelope with no submission ID** — only `revisionId`. Which identifier is meant? *(inconsistency)*
10. **A submission naming itself as base, or a base from a different visit.** Neither is classified. *(validation)*
11. **Basing on a revision cleared by resolution but still retained** — valid base that re-opens the visit, or not? *(post-resolution state)*
12. **Empty observer list / cover estimates / notes** — completeness is not defined per field. *(validation)*
13. **Receipt-time ties and idempotent retries** — ordering of competing revisions and whether a retry reuses the original receipt time are unpinned. *(ordering)*

## Decision record

The whole-visit-vs-field-aware choice still reads as live to a cold reader — two credible options traded against review workload, submission size, implementation burden, and preservation of scientific intent, with tablet-sync and review-export about to be sized around the result. I'll offer once: record it as a **decision doc** under `docs/intent/record-store/decisions/`, with the Decisions row above as the alternative. Say the word and I'll write it; otherwise the row stands.

## Please review (Phase 2 stop)

1. Is the revision model right — clean vs competing, unresolved persisting across clean advances, resolution selecting one candidate and retaining the rest?
2. Triage the probe items: which become LLD/spec decisions now, which defer?
3. Confirm the unknown-base default (reject with a resync signal) or choose competing.
4. Do you want the decision doc?

On your approval I'll move to Phase 3 (EARS) for this node. I have not touched tablet-sync or review-export.