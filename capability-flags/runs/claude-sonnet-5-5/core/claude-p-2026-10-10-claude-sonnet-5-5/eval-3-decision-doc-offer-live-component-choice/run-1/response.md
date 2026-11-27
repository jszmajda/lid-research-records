I've drafted the record-store LLD around whole-visit revisions at `docs/intent/record-store/record-store-design.md`. It's at the Phase 2 stop, so I haven't touched the EARS specs, tests or code yet.

**What the LLD now says**
- **Revision:** every accepted submission is a complete visit and becomes one revision.
- **Submission envelope:** visit ID, idempotency key, complete content, and a base revision ID (absent only on a visit's first submission).
- **Open revisions:** a revision is open when no accepted revision names it as a base. One open revision is the visit's current state. More than one means the visit has unresolved review work.
- **Current-state response:** returns the open revisions with their authors, receipt times and base IDs, plus an explicit unresolved marker. It carries no single current state while the visit is unresolved.
- **Review item:** one per unresolved visit, listing its open revisions and the earlier revision they share.
- **Resolution:** records the coordinator, the contributing revisions and the outcome.
- **Downstream:** tablet-sync keeps base revision IDs; review-export gets a comparison screen and holds unresolved visits out of the CSV. Both are only noted here, not designed.
- **Decisions table:** I recorded your rationale there, including that the larger review queue is accepted in exchange for no merge rules that could combine scientifically related edits unnoticed.

**Decisions for you**
1. **Resolution outcome.** Can a coordinator only pick one of the competing revisions, or also author a new complete revision? This shapes the review-export screen and REC-006. I haven't picked one.
2. **Edit based on a competing revision.** A worker's tablet may start from one of several open revisions. Does that edit silently settle the competition, or is it another open revision?
3. **Same author, same base.** If one worker submits twice from the same base, is that competition or supersession? Retries are already covered by the idempotency key.
4. **Competing first submissions.** If two tablets create the same visit UUID offline, should retrieval give any usable state before resolution?

**Further items for you**
- **Tenet check.** Please weigh the larger queue against the tenet "Prefer workflows two coordinators can operate without a dedicated systems administrator", given about 6,000 visits a season and independent corrections that are routine. You accepted the queue size, so I've treated this as settled unless you say otherwise.
- **Decision doc or table row.** This choice sizes both tablet-sync and review-export, so it may stay live for a cold reader. Should I record it as a standalone decision doc in `docs/intent/record-store/decisions/`, or is the Decisions-table row enough? I haven't written a doc.
- **HLD still stale.** It still says "concurrency choice open" and that those two designs "must wait". I left it alone because it's a different level. Should I update the HLD state and wording now, along with the specs after this review?

Please reply with numbered feedback on the LLD and answers to 1–4, and I'll move to the EARS specs (REC-004 to REC-006 will need revising).