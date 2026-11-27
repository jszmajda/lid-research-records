## LID Coach report

**Posture: a clear design foundation, with important intent gaps to close.**

**Scorecard**
- ✓ Design structure — the HLD leads to two identifiable components with corresponding specs.
- ✓ Decision capture — most recorded choices explain alternatives and accepted costs.
- ⚠ Tenet cascade — local-first allocation conflicts with the stated waiting-order tenet.
- ⚠ Spec coherence — some conditions and lifecycle transitions need clarification.
- ✗ Arrow completeness — tests and implementation are not present in the repository.
- ⚠ Configuration — Full mode is declared, but the instruction file lacks LID directives.

The design gives future work a useful starting point; the most valuable next step is to resolve the waiting-order conflict before carrying allocation into tests and code.

### Findings

- **F1 (high):** `CLAUDE.md` declares Full mode but lacks LID directives; consider `/update-lid` · *modes are declared, not inferred* — sessions need explicit workflow instructions.
- **F2 (high):** Both spec files mark requirements complete, but no tests or code are present · *canonical arrow shape* — the behavioral arrow cannot yet be walked through tests to implementation.
- **F3 (high):** `hold-allocation-design.md` prioritizes a newer local hold over an older remote hold, contrary to the HLD’s waiting-order tenet · *tenet cascade* — a described operating condition defeats the project’s stated preference.
- **F4 (high):** The local-first choice has no Decisions & Alternatives row explaining the trade against waiting order · *decision capture* — a future reader cannot tell why that consequential exception is acceptable.
- **F5 (high):** Allocation considers “open holds” without saying whether an already allocated hold remains eligible for another copy · *LLDs close enough of the solution space* — multiple check-ins could be interpreted to assign multiple copies to one hold.
- **F6 (medium):** The pickup design describes closing a hold when its window lapses, while `PICKUP-005` closes it when staff scan the copy off the shelf · *coherence is adjacency* — design and spec leave the deletion time ambiguous.
- **F7 (medium):** `HOLDALLOC-004` also matches when no holds exist, overlapping `HOLDALLOC-005` · *scope disambiguation* — one check-in can appear to require both allocation and no slip.
- **F8 (medium):** Staff calls after failed delivery can use a channel other than the patron’s choice, but the decision row does not explain that exception to the HLD’s one-channel tenet · *tenet cascade* — the intended trade is hard to apply consistently.
- **F9 (medium):** Several HLD tenets read as fixed rules rather than ordered decision preferences · *tenets capture forward-looking preference* — clearer tie-breakers help future sessions resolve cases the specs do not cover.

### What was audited

- Read `CLAUDE.md`, the HLD, both component designs, and both spec files in full, including a cold read and Decisions & Alternatives sweep.
- Reviewed 13 specs across two components. No code, tests, `@spec` annotations, or arrow overlay were present to sample.
- **Default applied:** Full-mode review for missing LID directives, matching the explicitly declared Full mode. The report is inline; no files were changed.

Want me to walk through the findings in detail or focus on specific items? I can also help with broader questions about using LID in this project.