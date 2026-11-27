## Phase 1 — HLD check (done, awaiting your review)

**Pre-flight:** no code, tests, or `docs/arrows/` overlay exist yet — this is a docs-only project, so the coherence checks reduce to HLD↔LLD↔EARS. `CLAUDE.md` declares Full mode 1.4.0; no bootstrap needed.

**What changed in `docs/high-level-design.md`:**

1. Architecture table row for `record-store`: `Drafted; concurrency choice open` → `Drafted; whole-visit revisions selected`.
2. The paragraph below the table (lines 22) previously described the concurrency mechanism as an *unresolved* choice. It now states the selected mechanism in one sentence — an edit names the revision it started from, concurrent edits become competing complete revisions resolved by a coordinator — and keeps tablet-sync / review-export explicitly waiting on record-store's contract.
3. New tenet added to `## Tenets`: *"Prefer a larger human review queue over automatically combining edits that may be scientifically related."* I placed it after "Keep the path from a submitted observation to an exported value inspectable" and before the coordinator-operability tenet. It reads as a genuine tenet (its reverse — prefer automatic combination over review volume — is a defensible opposite, not an absurd one) and it encodes your stated reason for choosing revisions: merge rules can combine scientifically related edits without noticing. No other tenet is affected.

**What I deliberately did *not* put in the HLD:** the concurrency mechanism's substance belongs to `record-store`, so no HLD-level Key Design Decisions row and no HLD-owned decision doc. Downstream effects on tablet-sync and review-export are obligations those segments inherit from record-store's contract, not co-ownership.

## Two things I need from you

**1. Decision doc — offer, not a fait accompli.** Applying the landed-state test to the whole-visit-revisions choice: a cold reader of the result *would* re-litigate it (it looks like obvious over-engineering until you know that merge rules can silently combine a revised species ID with an unrelated cover estimate), the decision turned on a scientific-correctness-vs-review-volume trade that the rest of the system's intent leans on, and tablet-sync and review-export are about to be sized around its contract. That clears the bar for a full decision doc rather than a table row. It would live at `docs/intent/record-store/decisions/whole-visit-revisions.md` (owned by record-store, since the mechanism is record-store's), with a Decisions & Alternatives row in the record-store LLD linking to it. **Do you want that doc, or just the table row?** (If you decline, the row alone carries the rationale.)

**2. A note, not yet a question.** There is no source code, no language, and no test runner in the repo. Phases 5–6 will therefore need a stack decision (language, persistence, test runner) that nothing in the project currently implies. I'll bring you that choice at the Phase 5 stop rather than inventing it now — phases 1–4 artifacts don't depend on it.

Reply with approval (and any numbered changes to the three HLD edits), plus your answer on the decision doc, and I'll proceed to Phase 2 — rewriting `docs/intent/record-store/record-store-design.md` to settle whole-visit revisions and define the submission envelope, current-state response, unresolved-work representation, and resolution operation.