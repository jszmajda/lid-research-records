## LID coach report

**Posture: A clear design foundation with important intent gaps to resolve.**

**Scorecard**
- ✓ Design organization — allocation and notices have distinct designs and specs.
- ✓ Decision capture — several alternatives and accepted costs are recorded.
- ⚠ Coherence — some requirements conflict across the arrow.
- ✗ Completion and linkage — specs are marked complete, but no tests or code are present.
- ⚠ Configuration — Full mode is declared, but LID directives are missing.

The project has a readable architecture and a compact spec set; the most valuable next step is to reconcile the allocation policy with the stated fairness tenet.

### Findings

- **F1 (high):** `CLAUDE.md` declares Full mode but lacks LID directives; consider `/update-lid` · *modes are declared, not inferred* — sessions need the workflow as well as the mode.
- **F2 (high):** `hold-allocation-design.md:11` prioritizes local holds over older remote holds, contradicting the HLD’s sequence tenet; the policy can lengthen an earlier patron’s wait · *tenets capture forward-looking preference* — downstream design should honor stated priorities or record an exception.
- **F3 (high):** An allocated hold remains open until pickup or expiry, yet allocation selects from open holds without excluding already-assigned holds (`hold-allocation-design.md:9–13`); another check-in could assign a second copy to it · *LLDs close enough of the solution space* — state eligibility needs to be unambiguous.
- **F4 (high):** All specs are marked `[x]`, but the repository contains no tests or implementation · *canonical arrow shape* — completion markers currently suggest an arrow that cannot yet be walked through tests and code.
- **F5 (high):** `pickup-notices-design.md:11` closes a hold when its window lapses, while `PICKUP-005` closes it when staff scan the copy off the shelf · *coherence is adjacency* — the timing affects which hold is active between lapse and pull.
- **F6 (medium):** The local-first allocation tradeoff has no Decisions & Alternatives row explaining why courier savings outweigh sequence fairness · *docs carry current intent* — a consequential choice needs its accepted cost available to a cold reader.
- **F7 (medium):** `HOLDALLOC-004` also matches when no holds exist, overlapping `HOLDALLOC-005` while asking for a nonexistent oldest hold · *scope disambiguation* — precise conditions prevent incompatible outcomes.
- **F8 (medium):** `pickup-notices-design.md:13` calls for staff to phone after failed delivery, while the HLD promises the chosen channel and `PICKUP-006` prohibits another channel; the exception needs clarification · *coherence is adjacency* — implementers need to know whether a staff call is an intended fallback.
- **F9 (medium):** The HLD mixes forward-looking preferences with fixed rules, such as deleting closed holds, and does not resolve possible conflicts between its tenets · *tenets capture forward-looking preference* — actionable tie-breakers help future decisions where specs are silent.

### What was audited

- Read `CLAUDE.md`, the HLD, both component designs, and both spec files in full, including their decision tables.
- Reviewed 13 specs across two components. The repository contains no code, tests, or arrow overlay to sample.
- **Defaults taken:** none; Full mode is explicitly declared, and no dispatch choice required a default.

Want me to walk through the findings in detail or focus on a particular item? I can also help with broader questions about using LID for this project.