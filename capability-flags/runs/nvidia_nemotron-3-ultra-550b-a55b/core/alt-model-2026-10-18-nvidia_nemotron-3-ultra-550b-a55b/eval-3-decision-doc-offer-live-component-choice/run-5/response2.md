Done. The record-store design now includes:

1. **Complete decision record** in the Decisions & Alternatives table — captures why whole-visit revisions was selected, the full rationale, and what the field-aware three-way merge alternative offered (including its limitations: partial review reduction since manual approval still required, risk of scientifically incoherent merges)

2. **Specific downstream contract requirements** for both tablet-sync and review-export:
   - **Tablet-sync**: base revision ID storage, idempotency-key retry machine, competing-revision display, conflict UI, offline draft retention
   - **Review-export**: revision comparison screen, coordinator winner/combine actions, resolution recording, export eligibility (clean/resolved only), CSV column fidelity, provenance trail

The EARS specs (REC-001 through REC-015) already encode the whole-visit revision behavior. Ready for Phase 4 edge-audit resolution if you want to address the forks I surfaced, or we can proceed to Phase 5 (tests-first).