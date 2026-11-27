Phase 2 (record-store LLD) is drafted around whole-visit revisions. Here's where it stands for your review.

## What the revised LLD now says
- **Mechanism — whole-visit revisions.** A visit is a series of complete **revisions**, each carrying its payload, author, receipt time, and the **base revision** it was edited from. A submission whose base *equals the current revision* fast-forwards it (no review); a submission whose base is *earlier* is retained as a **competing revision** and the visit goes **unresolved**. A coordinator resolves by designating one revision in the competing set as current; the rest are kept as superseded. The server never combines fields.
- **Contract filled in:** submission envelope (visit UUID, base revision ID, idempotency key, payload; author from auth; server-assigned revision IDs), retrieval (current revision + resolution status + competing set when unresolved), submission-history, and the resolution operation (records coordinator, contributing IDs, chosen revision).
- **Downstream contract** spelled out for tablet-sync (retain/send base revision ID, surface "became a competitor") and review-export (comparison screen, invoke resolution, exclude unresolved from the CSV).
- **Decisions & Alternatives** records the mechanism choice vs. field-aware merge with your rationale (bigger queue over merge rules that could silently combine related edits), plus two follow-on choices: server-assigned revision IDs, and resolution-as-selection (not server-authored merge).
- **HLD cascade:** I updated the record-store status row and softened the "must wait for its contract" note to reflect the resolved choice — the HLD had explicitly delegated this choice to record-store, so no architecture changed.

## 1. Decision doc — offer
The mechanism choice clears the bar for a standalone decision doc: two credible options traded against review workload, implementation burden, and preservation of whole-visit scientific intent, with two downstream nodes about to be sized around it. I've recorded it as a **Decisions & Alternatives row** for now. **Would you like a full decision doc** (`docs/intent/record-store/decisions/`) instead, or is the row enough?

## 2. Forks to resolve before EARS (Phase 3)
These are genuine spec forks — I've drafted leanings but need your call, since each would narrow the specs differently. The first three are in the LLD's Open Questions; the rest came from a blind edge-probe of the draft:

1. **Submit against the current revision while the visit is unresolved** — fast-forward current (moving the resolution target mid-review), or join the competing set? *(Lean: unsure — flagging.)*
2. **"Earlier revision" under branching** — competitors have their own bases, so the series is a tree, not a line. Is "earlier/ancestor" defined by **ancestry** or by **receipt-time ordering**? And may a worker base an edit on a *competing* (non-current) revision, or only on current + its ancestors?
3. **Readability while unresolved** — *(Lean: keep the pre-competition current revision readable but flagged; export excludes it.)* Or should an unresolved visit expose no current state at all?
4. **Re-entry** — after resolution, can a later stale-base submission push the visit back to unresolved? *(Lean: yes.)* And can a competing submission that *arrives after* resolution (based on the old current) re-open it?
5. **Resolution preconditions** — must the chosen revision be a member of the competing set; what happens if the set changed between the coordinator's read and the resolve call, or two coordinators resolve concurrently?
6. **Base-less submission for an existing visit** (claims creation but the UUID already has revisions) — validation failure, or a competitor?
7. **Idempotency scope** — is the key global or per-visit; does "identical payload" include the base revision ID; and on retry, does it replay the original acceptance result even if competition status has since changed?
8. **Error shapes** — should the rejection classes (auth, unknown plot, bad field types, base-not-in-visit, idempotency conflict) be distinguishable in the response, and to what resolution?

Tell me which of these to pin down in the LLD vs. defer as open questions, and your calls on the leanings — then I'll cascade them into the REC specs (Phase 3). Nothing past this stop is written yet.

I'm **stopping here for your review** of the Phase 2 LLD before moving to EARS.