Phase 2 is drafted and I've run the LLD-level edge probe. Here's the record-store design, completed around whole-visit revisions, for your review.

## What the LLD now says

**Revisions.** Each submission carries a complete visit payload and names the **base revision** it started from. The server assigns every accepted revision an ID and records author, idempotency key, receipt time, and base, so a visit's revisions form a derivation tree. A revision with no successor is a **tip**.

**Current vs. unresolved.** One effective tip → that tip is the current state. More than one effective tip → the visit is **unresolved** and its tips are **competing revisions**. Retrieval never hands back a single "current" revision for an unresolved visit.

**Fast-forward vs. conflict.** A submission whose base is the sole current revision extends the chain (no review work). Otherwise it's recorded as an additional tip and the visit goes unresolved — both revisions preserved. A base that doesn't belong to the visit is rejected.

**Resolution.** A coordinator selects one competing revision as current (never a field-combine). A resolution record names the coordinator, the competing revision IDs resolved, and the winner; losers are superseded, not deleted.

**Contract + downstream notes.** I defined the four operations (submit / get current / get history / resolve) at contract level and left tablet-sync (retains base IDs, surfaces "went unresolved") and review-export (comparison screen, holds unresolved visits out of the CSV) as cascade notes only — per your "those come after." No specs or those nodes were touched.

I recorded the policy as a **Decisions & Alternatives** row (whole-visit chosen over field-aware merge, with your bigger-queue-over-silent-merge rationale). Because this choice stays live for a cold reader and tablet-sync + review-export will both be sized around it, I'd like to **offer to promote it to a full decision doc** (`docs/intent/record-store/decisions/concurrency-policy.md`) — options, criteria, and selection at re-runnable resolution. The row is the alternative if you'd rather keep it lightweight. **Which do you want?**

## Edge-probe gaps for you to triage (fix in the LLD now vs. defer)

A blind probe against the LLD's own internals surfaced these. I haven't resolved any — several admit more than one reading and are yours to settle:

1. **3+ competing tips** — does a third concurrent submission just join the set, and must a resolve name *all* current tips to clear the visit? (Doc reasons mostly in twos.)
2. **Stale/incomplete resolve set** — a resolve whose named competing-IDs don't match the visit's actual tips (new tip appeared, or an ID omitted). Reject? Partial? Error shape unspecified.
3. **Selected revision not a competing tip** — resolve picks a valid-but-interior/superseded/already-current revision. Accept or reject?
4. **Idempotency scope** — same key + identical payload but *different base revision* (or different visit UUID). Is the key scoped to the full envelope or just the payload?
5. **Idempotent retry after the visit moved on** — does the replayed acceptance echo the original current/unresolved flag, or report current state?
6. **Fast-forward race** — two submissions both naming the current revision as base. The serialization point ("still the sole current revision?") is unstated, so the outcome (one FF + one tip, vs. two tips) isn't pinned.
7. **Identical competing payloads** — two different authors submit byte-identical visits against the same base. Auto-collapse or force review?
8. **Resolution record shape** — does it get its own ID/time/ordering, can a visit hold several, and how does get-history interleave them with revisions?
9. **Base-absent submission into a non-empty visit** — an "initial" (no base) submission for a UUID that already has revisions. Reject, new tip, or conflict?
10. **Retrieval of unknown/empty visit UUID** — neither a current revision nor an unresolved indicator fits; not-found shape unspecified.

(The LLD already carries one deferred open question — whether a recorded resolution can be reopened — which overlaps #2/#3; I routed that to review-export since it owns the coordinator workflow. Tell me if you'd rather pin it here instead.)

## Notes

- The HLD's record-store status cell still reads "Drafted; concurrency choice open." I left the HLD untouched (it's upstream of this segment); I'll update that cell once you approve this LLD.
- Next phase after your sign-off is **Phase 3 (EARS)** — reconciling REC-001…006 with this model and adding specs for base-revision/fast-forward/conflict/resolution, with its own stop. tablet-sync and review-export stay deferred as you asked.

**To proceed, I need from you:** (a) decision doc or just the row? (b) which edge-probe gaps to fix in the LLD now vs. defer, and any resolutions for the ones that are genuinely your call (esp. #4, #6, #7, #9); and (c) approval of the LLD as-is or with those changes.