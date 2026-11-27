---

## LID Coach Review: Visit Planner

**Posture:** Healthy arrow in place; strong design discipline with one decision-capture gap.

**Scorecard**
- ✓ Arrow structure — canonical HLD → LLDs → EARS shape; two components fully specified
- ✓ Tenet quality — four genuine tie-breaker tenets, well-defined and non-redundant
- ✓ Tenet cascade — mechanisms in design actively carry through HLD tenets and goals
- ⚠ Decision capture — architectural 36-hour threshold drives two algorithms but records no rationale
- ⚠ LLD sufficiency — "compatible" matching criteria are implicit, not explicit in design
- ✓ Linkage hygiene — spec IDs follow grep-friendly pattern; clean alignment to components
- ✓ Mutation hygiene — docs read fresh; no accumulated history, planning text, or obsolete markers
- ✓ Mode fit — Full mode matches two-component scope

**Headline:** The design foundation is solid and well-aligned; the tenets genuinely constrain the solution space. The fastest win is capturing the 36-hour threshold decision and making "compatible" entry criteria explicit in Fulfillment.

---

## Findings (2 total · 1 high · 1 medium)

**F1 (high):** The 36-hour threshold in fulfillment-design.md drives two entirely different matching algorithms (advance auto-match vs. public search with delayed scan), but this architectural boundary and its rationale appear only in prose. Consider adding a Decisions & Alternatives row naming the threshold choice, the rejected alternative (a different boundary, or a single algorithm), and why 36 hours was chosen · *decision capture* — decisions that would survive cold-reader scrutiny should be recorded where the tree captures them.

**F2 (medium):** Fulfillment specs reference "compatible active entries" repeatedly (FILL-001, FILL-005), but the definition of compatibility — which service/site/time combinations match — is implicit. The Fulfillment LLD doesn't spell out whether it's assumed from Intake design or computed at match time. Consider a brief "Compatibility" paragraph in fulfillment-design.md explaining the matching criteria · *LLDs close enough of the solution space* — edges left open become implementation guesses.

---

## What was audited

- Read fully: CLAUDE.md, docs/high-level-design.md, docs/intent/intake/ (intake-design.md, intake-specs.md), docs/intent/fulfillment/ (fulfillment-design.md, fulfillment-specs.md)
- Enumerated: 1 HLD, 2 LLDs, 2 spec files (7 intake specs, 8 fulfillment specs; 15 total)
- Arrow depth: 2 leaf LLDs under one HLD; no sub-HLDs or intermediate hierarchy
- Implementation: No code, tests, or arrow-maintenance overlay yet (bootstrapping phase)
- Scope: Full mode, project-wide review; no Scoped zones

---

Want me to walk through the findings in detail, focus on the decision-capture issue or matching-criteria gap, or help you work through them?

If you have broader questions about using LID — what belongs in Decisions & Alternatives vs. in design prose, when to write explicit matching rules vs. rely on code as spec, or how to structure matching-logic specs across intake and fulfillment — I can help with those too.