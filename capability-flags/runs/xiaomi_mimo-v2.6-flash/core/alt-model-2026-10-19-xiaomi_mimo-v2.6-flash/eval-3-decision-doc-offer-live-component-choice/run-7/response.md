**Coherence pre-flight:** EARS specs REC-001–006 trace to the current record-store LLD (retention, idempotency, concurrent-submission preservation, unresolved-work indicator, resolution audit — all policy-neutral, still valid under whole-visit revisions). No tests exist yet; the repo is docs-only. LLD ↔ HLD coherent except for the status lines below, which your selection just made stale.

---

## Phase 1 — HLD check (complete)

The HLD exists and already locates the concurrency mechanism inside record-store, so your selection requires no architectural change at the HLD level — only stale status text. Two edits applied to `docs/high-level-design.md`:

**1. Architecture table — record-store state:**
```
- | ... | Drafted; concurrency choice open |
+ | ... | Drafted |
```

**2. Dependency paragraph rewritten (was narrating the open choice):**
```
- The concurrency mechanism belongs to record-store, not this HLD. Tablet-sync and
- review-export depend on that node's unresolved choice: it determines submission
- metadata, the shape of review work, and which record states can enter an export.
- Those two designs must wait for its contract.

+ The concurrency mechanism belongs to record-store, not this HLD. Tablet-sync and
+ review-export depend on that node's contract: it determines submission metadata,
+ the shape of review work, and which record states can enter an export. Those two
+ designs are written after that contract.
```

The mechanism name (*whole-visit revisions*) stays out of the HLD — per the HLD itself, that decision belongs to record-store and will be recorded there in Phase 2.

---

**Three questions before I proceed to Phase 2 (finish the record-store LLD around whole-visit revisions, then run the LLD edge-case probe):**

1. **Approve the two HLD edits above?** (or give numbered feedback)

2. **Tenet candidate.** Your rationale — a bigger review queue over merge rules that silently combine scientifically related edits — leans a class of future decisions beyond concurrency (auto-validation, import dedup, CSV cleanup). Candidate one-liner for the HLD's `## Tenets`:
   > *Prefer visible review queues over automation that might silently reshape scientific meaning.*

   The existing tenets (don't silently discard; keep the path inspectable) and the non-goal on automated botanical validation partially cover it; the reverse is still a defensible choice a different project could make. **Add it, or leave the tenet list as-is?**

3. **How to record the whole-visit-revisions choice.** It clears the decision-doc bar: credible options traded on multiple criteria, and tablet-sync/review-export are about to be sized around it — a cold reader would re-litigate "why not auto-merge disjoint fields?" without the tradeoffs on the page. Options:
   - **Full decision doc** at `docs/intent/record-store/decisions/whole-visit-revisions.md` (context, gates/criteria, both options with strongest representations, selection), linked from the LLD's Decisions row; or
   - **Decisions row only** in the record-store LLD.

   **Doc, or row?**

Reply with answers (e.g. "1. yes, 2. add it, 3. row") and I'll proceed to Phase 2.