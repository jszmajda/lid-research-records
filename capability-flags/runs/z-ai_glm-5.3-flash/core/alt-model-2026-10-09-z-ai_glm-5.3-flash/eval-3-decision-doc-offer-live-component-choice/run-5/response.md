Phase 2 is complete — the record-store LLD is finished around your whole-visit-revisions selection. Please review **docs/intent/record-store/record-store-design.md**. Here is what it now says, plus the probe results that need your triage.

## What the LLD now specifies

- **Revisions**: every accepted submission is an immutable complete visit payload with a per-visit sequence number, author, receipt time, and the base revision ID it names. First revision names no base.
- **Clean vs. competing**: a submission whose base equals the current tip appends and becomes the new tip automatically. A submission naming a stale base is still stored in full but does not move the tip — the visit becomes **unresolved** with a competing set (tip + the competing revision). Conflict is decided by base-mismatch alone; no content comparison.
- **Unresolved visits**: current-state retrieval reports unresolved state and the competing revision IDs rather than a payload. Further tip-based submissions join the same competing set rather than being rejected (tablets shouldn't block).
- **Resolution**: a coordinator selects one competing revision as winner; everything stays stored; the resolution records coordinator, winner, full set, and time. No server-side merged revisions — a coordinator who wants a combination submits it as a normal revision afterward.
- **Decisions & Alternatives** records the policy choice, the base-mismatch-only conflict test, the select-don't-merge resolution, and the accept-while-unresolved rule, each with rationale. The HLD's status row and the "must wait for its contract" paragraph are updated to match.

## Edge-case probe — which gaps should the LLD close now?

The delegated probe found 10 gaps; these look most consequential, with my suggested disposition:

1. **Invalid base revision ID** (unknown, or another visit's revision) — reject as invalid, never stored as competing? *(fix in LLD: recommend reject)*
2. **Competing revision wins resolution** — tip moves to it; how does its sequence number relate to the displaced tip? *(fix in LLD: recommend tip moves, sequence numbers untouched)*
3. **Sole competing revision loses** — former tip stays current with no lingering contest marker? *(fix in LLD: recommend yes, outcome recorded in resolution history)*
4. **Re-basing on a competing revision while unresolved** — error, or allowed and joins the set? *(fix in LLD: recommend submissions must always base on the tip; anything else rejected)*
5. **Byte-identical competing submissions with different idempotency keys** — two revisions or one? *(fix in LLD: recommend two revisions; idempotency is per key only)*
6. **Re-opening a resolved visit** — can a coordinator re-select a different winner after clean submissions landed on the old tip? *(defer to review-export's workflow, or forbid re-opening here — your call)*
7. **Zero-revision visit retrieval** — error shape. *(fix in EARS error specs next phase)*

Items 1–5 and 7 I'd close in the LLD with the recommendations above; item 6 needs your judgment. Tell me which to apply, adjust any recommendation, and add anything the probe missed.

## One more decision for you

The whole-visit-revisions choice clears the bar for a **decision doc**: two credible options traded against more than one criterion (review workload vs. merge burden vs. scientific-unit preservation), and tablet-sync and review-export are about to be sized around the result. I can write `docs/intent/record-store/decisions/whole-visit-revisions.md` capturing the full options/criteria/selection so a future cold reader can re-run the judgment — or just leave it as the Decisions & Alternatives row it currently has. Which do you prefer?

Once you've ruled on the gaps and the decision doc, the next step is Phase 3: revising the EARS specs (`record-store-specs.md`) to the finished contract, with a consistency report, at its own stop.