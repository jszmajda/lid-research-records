The decision doc is written, and the record-store design links to it. I've stopped at the Phase 1 boundary again, so the LLD and EARS work hasn't started.

**Written**
- `docs/intent/record-store/decisions/whole-visit-revisions.md` is a full decision doc. It covers:
  - **Why we'd still consider the other approach.** Field-aware merge gives fewer coordinator decisions and more visits ready for Friday export. The cost is merge rules to maintain and combined states that no single worker submitted. The doc records the revisit triggers: a Friday export held back by an unclearable review queue, or most competing pairs differing only in non-overlapping fields.
  - **What tablet-sync must accommodate.** Base revision IDs on every submission, full-visit storage per pending submission, a conflict reported as a successful acceptance, and retained local copies until the server acknowledges each one.
  - **What review-export must accommodate.** Coordinators resolve competing revisions as a set, a field-level comparison view for display only, exclusion of unresolved visits from the CSV with a held-back report, and resolution records that name the coordinator and submission IDs.
  - **Tenet tension.** The decision is taken partly against *Prefer workflows two coordinators can operate without a dedicated systems administrator*. The doc says so plainly.
- `docs/intent/record-store/record-store-design.md` has a Decisions & Alternatives row that links to the doc. Its open-choice section now says the choice is selected. The alternatives bullets below that line still describe the choice as open, and I've left them for the Phase 2 rewrite.
- `docs/high-level-design.md` (edited in the previous step) shows the record-store state as "Drafted; whole-visit revisions selected."

**Still open from my last message**
- Whether the tenet tension should also appear in the HLD. I haven't touched the HLD's tenets.

**Next**
- Phase 2 rewrites the record-store design around the chosen policy. It defines the submission envelope, the current-state response, the unresolved-work representation, and the resolution operation.
- Phase 3 then rewrites REC-004, which still says "regardless of the concurrency policy's outcome," and checks REC-005 and REC-006 against the new contract.

Reply to approve Phase 2 and say whether the HLD should record the tenet tension.