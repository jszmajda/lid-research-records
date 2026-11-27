**Phase 1 — HLD check: done. Stopping for your review.**

`docs/high-level-design.md` needed two edits to stop reporting an open question you've closed:

| Section | Was | Now |
|---|---|---|
| Architecture table, `record-store` row, State | `Drafted; concurrency choice open` | `Drafted` |
| Paragraph after the table | "…depend on that node's **unresolved choice**… Those two designs **must wait for** its contract." | "…**are sized around** that node's contract… **Neither node may invent its own concurrency semantics.**" |

Nothing else in the HLD moves. The concurrency mechanism stays delegated to record-store — the choice itself gets recorded there (Phase 2), not lifted into the HLD, since the sibling nodes only inherit downstream obligations. Tenets, Goals, and Non-Goals read unchanged under whole-visit revisions.

Two questions before I draft the record-store LLD:

1. **Where does your rationale live?** "Take a bigger review queue over merge rules that can silently combine scientifically related edits" passes the tenet tests — the opposite is a choice another project could reasonably make, and it's a lean, not a triggered rule. It's also forward-looking for review-export, which will soon face "can we auto-approve this low-risk resolution?" questions record-store's Decisions row won't reach.
   - (a) Add it as a fifth HLD tenet — e.g. *"Prefer visible review work over automatic combination that cannot see scientific relationships."*
   - (b) Keep it as the rationale in record-store's Decisions & Alternatives row only.

2. **Decision doc?** You're settling a two-criterion trade-off (review volume vs. merge-rule maintenance + whole-visit integrity) that tablet-sync and review-export are about to size themselves around, and a cold reader is likely to ask why unrelated edits each cost a review slot. That clears the bar for a standalone doc at `docs/intent/record-store/decisions/`. I'll write one if you want it; otherwise a Decisions row with the full rationale, no doc.

Reply with numbered feedback (or "looks good") and I'll proceed to Phase 2 — the record-store LLD.