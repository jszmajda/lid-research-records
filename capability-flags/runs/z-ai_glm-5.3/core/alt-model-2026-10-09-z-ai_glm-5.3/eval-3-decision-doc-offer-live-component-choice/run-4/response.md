The record-store design is finished and the HLD's stale pointers are updated. **Phase 2 stop — please review before I draft the EARS specs.**

## What changed

**`docs/intent/record-store/record-store-design.md`** — the open choice is resolved into a concrete design:

- **Revision model**: every accepted submission creates a revision carrying the complete visit payload, author, receipt time, idempotency key, and base revision. A submission whose base is the current head **fast-forwards** to become the new head — but only when the visit has no open competing revisions. Anything else (stale base, or any submission during an open conflict) is retained as a **competing revision** and makes the visit **unresolved**. Arrival order decides only who fast-forwards and who goes to review; the coordinator decides what wins. Nothing is ever overwritten, combined, or deleted.
- **Submission envelope**: visit_id, base_revision_id, idempotency_key, whole-visit payload; author from authentication; revision ID and receipt time server-assigned.
- **Retrieval**: visit state (`resolved`/`unresolved`), head content, and open competing-revision metadata (payloads retrievable for comparison); history lists every revision including superseded.
- **Resolution**: coordinator-authenticated — **select** one competing revision as head, or **merge** by recording a coordinator-authored resolution revision; losers are superseded but retained; coordinator identity and contributing submission IDs are recorded (REC-006).
- **Downstream obligations**: tablet-sync holds base_revision_ids and tells workers a stale edit is pending review, not lost; review-export compares head vs. each competitor and exports only `resolved` visits.
- Decisions & Alternatives table added, including why field-aware merge was rejected.

**`docs/high-level-design.md`** — record-store row now "Drafted"; the dependency paragraph now states the whole-visit-revision contract is defined for tablet-sync and review-export to build against.

## Decision doc offer

The concurrency-policy choice is one the rest of the system is sized around, and a cold reader could plausibly re-litigate it ("why queue every concurrent edit instead of auto-merging disjoint fields?"). I can record it as a full decision doc in `docs/intent/record-store/decisions/` — or the Decisions & Alternatives row that's already there is sufficient. Want the doc?

## Edge-case probe — triage requested

A blind probe of the drafted LLD surfaced these gaps. Please triage: fix in the LLD now, or defer as open questions?

1. **Validation-failed submissions** — retained or discarded? The do-not-discard tenet may extend to even invalid submissions; unstated.
2. **Merge revision's base** — a coordinator merge has multiple parents; what base_revision_id does it carry? (Stale-base classification depends on it.)
3. **Resolution/submission race** — can a submission accepted just after a Select re-open a just-resolved visit? The competitor set's stability during review is assumed, not stated.
4. **Outgoing head after Select** — the text marks competing revisions superseded, but not the head that lost to a selected competitor.
5. **visit_id collision** — two tablets generating the same client UUID as a first submission; no rule stated.
6. **Correcting a resolved visit** — no path out of `resolved` for a coordinator amend except a worker's stale-base edit.
7. **Idempotency semantics** — "identical payload" undefined; key scope (per worker? per visit? global) unstated.
8. **Base for edits during unresolved state** — the design implies the head stands during review, but the tablet's next base choice isn't stated explicitly.

Answer the triage (and the decision-doc question), and I'll fold in the fixes and proceed to Phase 3 — the EARS specs for the revision, retrieval, and resolution behavior.