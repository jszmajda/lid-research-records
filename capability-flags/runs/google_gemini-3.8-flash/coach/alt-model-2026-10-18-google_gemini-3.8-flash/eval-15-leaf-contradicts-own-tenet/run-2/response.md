# LID Coach Review: Shelfwise

### Executive Summary

**Posture:** Bootstrapping — design tree and specs cleanly structured; configuration and tenet alignment need attention.

**Scorecard**
- ⚠ Configuration — instruction file missing LID directive block
- ⚠ Tenet cascade — branch-first allocation mechanism conflicts with HLD sequence tenet
- ✓ Granularity & Structure — clean node-as-folder layout and focused LLDs
- ✓ EARS Syntax — well-formed, grep-anchored requirement statements
- ⚠ Status hygiene — specs marked `[x]` before tests or code exist
- ⚠ Arrow completeness — downstream phases (tests and code) not yet instantiated

**Headline:** The design tree and EARS specifications are clean, disciplined, and readable; the most valuable next steps are reconciling the instruction-file configuration and resolving the tenet conflict in hold allocation before implementing tests and code.

---

### Findings (6 total · 2 high · 3 medium · 1 low)

- **F1 (high):** Missing LID directives in `CLAUDE.md` · *modes are declared, not inferred* (explicit directives anchor agent workflow and gating discipline)
- **F2 (high):** Local-first allocation mechanism conflicts with HLD sequence tenet · *tenets capture forward-looking preference* (forward tie-breakers guide downstream design; adjacent levels must remain coherent)
- **F3 (medium):** Branch-priority routing decision uncaptured in Decisions & Alternatives table · *docs carry current intent* (tradeoffs must be captured so cold readers understand rejected alternatives and accepted costs)
- **F4 (medium):** All 13 EARS specs marked `[x]` despite absent tests and code · *intent leads; code is compiled output* (spec status markers reflect verified reality; `[x]` requires both code and tests)
- **F5 (medium):** Downstream arrow phases (tests and code) not yet instantiated · *canonical arrow shape* (canonical arrow walks HLD → LLDs → EARS → tests → code)
- **F6 (low):** HLD tenets lack priority ordering and include a triggered spec-shaped rule · *tenets capture forward-looking preference* (tenets are tie-breakers for unforeseen decisions rather than triggered rules or platitudes)

---

### What Was Audited

- **Read fully:** `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/hold-allocation/hold-allocation-design.md`, `docs/intent/hold-allocation/hold-allocation-specs.md`, `docs/intent/pickup-notices/pickup-notices-design.md`, `docs/intent/pickup-notices/pickup-notices-specs.md`
- **Enumerated:** 1 HLD, 2 leaf LLDs, 2 spec files, 13 EARS specs (7 `HOLDALLOC`, 6 `PICKUP`)
- **Code & test inspection:** 0 code files, 0 test files (0 `@spec` annotations present)
- **Sampling depth:** 100% of project artifacts read (small project)

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

---

*Non-interactive defaults taken:*
- **Mode dispatch:** Proceeded with full review anchored on existing artifacts under Full mode per `CLAUDE.md` despite missing instruction-file directives (skill dispatch default).
- **Advisory persistence:** Rendered report inline without persisting to disk (skill advisory posture default).