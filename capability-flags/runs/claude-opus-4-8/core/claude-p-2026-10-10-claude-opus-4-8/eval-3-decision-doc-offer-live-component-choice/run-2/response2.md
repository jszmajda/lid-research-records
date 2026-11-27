Done. The decision doc is written and linked.

## `docs/intent/record-store/decisions/concurrency-policy.md`

Written to be read cold — present tense, no narration of our session. It lays out:

- **Decision Elements** — five weighted criteria (scientific-intent protection as the major one, turning on the *infer-scientific-intent* non-goal and *don't-discard* tenet), plus the **reviewer-fatigue** criterion surfaced explicitly *because* it cuts against the choice.
- **Both options** in their strongest honest form, each analysed element-by-element — so the field-aware merge case stands on its own.
- **Selection** — why whole-visit wins today, and crucially **why the merge approach stays live for a cold reader**: it becomes correct the moment review-queue volume is the binding constraint, and since every original submission is retained with its base, the policy is revisitable without data loss.
- **Downstream obligations**, as you asked — what tablet-sync must accommodate (persist/send base revision IDs, preserve them on retry, signal "unresolved" to the worker) and what review-export must accommodate (comparison-and-designate workflow, resolution recording, holding unresolved visits out of the CSV — and that the fatigue risk is mitigated there).

The LLD's Decisions row now points to it.

---

**Still open before I move to Phase 3 (EARS)** — from my last message, these are yours to call and I haven't touched specs or tests:

- **The edge-probe triage (item 2):** which of the 7 gaps to fold into this LLD now vs. leave as open questions. My suggestion stands — pin 1, 2, 4, 5 (and 7 as a small addition), one line each for 3 and 6. Your answers shape the new REC specs.
- **The HLD status line (item 3):** OK to update record-store's *"Drafted; concurrency choice open"* to reflect the resolved choice when we close this phase? Only that one line changes.

Give me the triage and the HLD go-ahead and I'll take record-store into Phase 3.