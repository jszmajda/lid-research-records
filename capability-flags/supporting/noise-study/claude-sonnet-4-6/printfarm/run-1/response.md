I now have everything I need to produce the review. Let me compile the findings.

---

## printfarm — LID Coach Report

**Posture:** Early-arrow, clean bones. Design foundation is solid; the arrow needs its downstream phases and a few spec gaps filled.

---

### Scorecard

- ✓ **Mutation / accumulation** — docs read clean throughout; no history residue, no `[obsolete]` markers, no change-narration
- ✓ **Linkage / ID hygiene** — spec IDs are well-formed; QUEUE/REG prefixes match their LLD `prefix:` frontmatter exactly
- ✓ **Scope disambiguation** — all specs use scoped or unambiguous WHEN clauses
- ✓ **LLD granularity** — two LLDs for two design nodes, matching the HLD's declared architecture precisely
- ⚠ **Arrow completeness** — the arrow stops at EARS; tests and code are absent; all specs are marked `[x]` with no code present in the repository
- ⚠ **LLD sufficiency** — several behaviors described in prose (acceptance check, printer registration, printer class definition, cross-node interface) have no corresponding specs
- ⚠ **Tenet quality** — three tenets are unordered; two can conflict without a stated lean

**Headline:** The HLD is lean and focused, the LLDs are clean, and the decisions tables are the best part of the project — the rationale for FIFO and short slugs is exactly the kind of capture LID is designed to preserve. The fastest wins are filling the spec gaps for behaviors already described in prose, resolving the cross-node interface between queue and registry, and clarifying the arrow's downstream status.

---

### Findings (8 total · 4 high · 2 medium · 2 low)

- **F1 (high):** Arrow stops at EARS; all specs marked `[x]` but no code or tests exist in the repository · *canonical arrow shape — tests and code are phases, not optional stages*
- **F2 (high):** The job acceptance rule ("accepted only if its target class has at least one registered printer") lives in architecture prose but has no corresponding QUEUE spec · *LLDs close enough of the solution space*
- **F3 (high):** Printer registration by staff is mentioned in printer-registry Context but has no spec; the "class" concept drives dispatch throughout both nodes but is never defined or specced in either LLD · *LLDs close enough of the solution space*
- **F4 (high):** The cross-node interface between job-queue and printer-registry is implicit — QUEUE-002 assumes the registry "reports a printer idle" but neither LLD defines the contract (callback, polling, event?); REG-002 describes internal state transitions without specifying what is observable externally · *coherence is adjacency — adjacent levels must agree*
- **F5 (medium):** Three tenets are unordered; tenets 1 (jobs are a promise) and 3 (service stays small) can directly conflict (reliability might require heavier infrastructure), with no stated resolution lean · *tenets capture forward-looking preference — ordered when more than two could conflict*
- **F6 (medium):** No success metrics in the HLD; goals are qualitative ("evening upload, overnight print, morning pickup") without measurable criteria · *HLD is architecture and rationale — success metrics belong here*
- **F7 (low):** The upload size limit row in job-queue-design's decisions table states a rationale ("covers the largest bed; keeps the mini-PC disk safe") but names no rejected alternative or accepted cost, unlike the other two rows in the same table · *decision capture — a cold reader should be able to reconstruct what was given up*
- **F8 (low):** The `## LID` block in CLAUDE.md includes `- Version: 1.4.0`, which is not a standard LID field; if project tooling reads it, that's a custom convention not documented anywhere · *minimum surface, maximum discipline*

---

### What was audited

- **Read fully:** CLAUDE.md, docs/high-level-design.md, docs/intent/job-queue/job-queue-design.md, docs/intent/job-queue/job-queue-specs.md, docs/intent/printer-registry/printer-registry-design.md, docs/intent/printer-registry/printer-registry-specs.md
- **Enumerated:** 2 LLDs, 2 spec files, 8 specs total (QUEUE-001–005, REG-001–003)
- **Sampled:** no code or test files exist in the repository
- **Arrow-maintenance overlay:** absent (`docs/arrows/` not present)
- **Linkage metric:** 0 `@spec` references in code (no code files present)

---

### Worth a second look

The capability-flags file for this model tier wasn't accessible from within this session's search scope. The most common blind spot for models in this class is failing to notice when a leaf-level design contradicts the HLD's own tenets. Please read the two LLDs against the three tenets yourself — particularly tenet 3 (mini-PC stays modest) against the job-queue's in-process memory architecture and disk-based G-code store, which seem consistent, but a second human pass is worth the few seconds.

---

Want me to walk through any of the findings in detail, focus on a specific priority tier, or dig into a particular item together? The cross-node interface finding (F4) tends to be the most productive to unpack first since it shapes what specs need to be added.

If you have broader questions about using LID for this kind of small-service project — how to handle the cross-node interface in the design tree, when to promote a two-node project to a sub-HLD, or how to think about the tests-first phase when the implementation is simple — I can help with those too.