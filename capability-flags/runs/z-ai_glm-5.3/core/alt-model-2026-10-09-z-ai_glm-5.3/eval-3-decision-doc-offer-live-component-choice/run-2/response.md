The record-store LLD is finished around whole-visit revisions. Per the workflow this is the Phase 2 stop — please review before I cascade to EARS.

**What changed**

- `record-store-design.md`: the open-choice section is replaced with the full contract — a revision model (every accepted submission becomes a revision naming its base; base = current joins the resolved line, any other base becomes a competing revision and marks the visit unresolved), the submission envelope (visit UUID, idempotency key, base revision ID, complete payload), current-state/history retrieval with the unresolved-work listing, and a resolution operation where the coordinator selects one submitted revision as current (no composed merges). The rejected merge alternative and rationale live in the Decisions & Alternatives table.
- `high-level-design.md`: the record-store row no longer says "concurrency choice open," and the dependency paragraph now states the contract the two unwritten nodes design against. No tablet-sync/review-export changes — per your sequencing.

**LLD edge-case probe — gaps for you to triage (fix in the LLD vs. defer)**

1. A submission based on the current revision of an *unresolved* visit — does it advance the resolved line while the flag stays set, and do existing competitors now compete against it?
2. When a resolution selects a competitor, what happens to the formerly-current revision and anything accepted on top of it?
3. Competitor-on-competitor chains — the base rule permits naming a non-current revision; resolution only defines a flat current-vs-competitors disposition.
4. Idempotency-key scope (per visit? per worker? global?) and what a retry returns when the original attempt was rejected, not accepted.
5. Resolution vs. concurrent submissions — ordering when a coordinator resolves while a worker submits against a candidate, or two coordinators resolve the same visit.
6. Whether "retained," "superseded," and "disposed of" denote the same set of revisions for base-eligibility.
7. Whether a rejected first submission reserves a client-generated visit UUID.
8. Re-unresolved cycles — do prior resolutions accumulate visibly per visit?
9. Error shapes — the doc lumps auth, validation, unresolvable plot, bad base, and key-reuse rejections together.
10. Revision-ID uniqueness scope beyond the visit, and acceptance-time ties.

**Decision doc offer:** the whole-visit-revisions choice will stay live for a cold reader — the merge option credibly trades a smaller review queue, and tablet-sync and review-export are about to be sized around the result. Want me to record it as a full decision doc under `docs/intent/record-store/decisions/` (the Decisions & Alternatives row is the alternative, and it's already there)?

Which probe gaps should I fold into the LLD, which should I defer, and your call on the decision doc?