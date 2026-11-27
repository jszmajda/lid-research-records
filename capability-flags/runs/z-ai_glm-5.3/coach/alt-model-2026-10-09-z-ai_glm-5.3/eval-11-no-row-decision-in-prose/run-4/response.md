**LID Coach — printfarm review**

**Posture:** Clean, coherent design layer — pre-implementation, with one tenet-level conflict to resolve before code starts.

**Scorecard**
- ✓ HLD discipline — architecture and rationale only; tenets are real tie-breakers, not platitudes
- ✓ Mutation hygiene — every doc reads as if authored fresh today; no history residue, no obsolete markers
- ✓ Linkage — QUEUE/REG spec prefixes trace cleanly to their LLDs, which trace to HLD architecture
- ⚠ Tenet cascade — the queue's restart behavior works against the HLD's core promise
- ⚠ LLD sufficiency / alignment — several named behaviors have no spec; the web UI has no design node
- ✓ Mode fit — Full mode matches a small, fully-LID'd repo

**Headline:** The design layer is tight — clean HLD, two well-scoped LLDs, EARS-compliant specs, zero drift residue; the most valuable next step is resolving the restart-job-loss vs. "a submitted job is a promise" tension and putting it on the record before implementation begins.

**Findings (7 total · 2 high · 4 medium · 1 low)**
- **F1 (high):** Accepted jobs are lost on restart, defeating the HLD's "submitted job is a promise" tenet and the overnight goal, under conditions the LLD itself describes (power blips, unattended OS updates) · *tenets capture forward-looking preference / cascade — docs and code lean the way the HLD says to lean*
- **F2 (high):** The in-memory-queue choice — the one a cold reader would most want to reverse — has no Decisions & Alternatives row, while the registry's SQLite persistence makes the asymmetry conspicuous · *decision capture — choices a cold reader would question need their reasoning on the page*
- **F3 (medium):** LLD behaviors with no spec anywhere: acceptance gated on the class having a registered printer, staff/member prioritization, and staff registration of printers (only retire is specified) · *effective intent-tree alignment — unnamed intent drifts silently because there's nothing to test against*
- **F4 (medium):** The HLD's Approach names a member web UI and staff reordering rights, but no design node owns the UI — including how the system knows a uploader is staff vs. member · *intent-tree alignment — every architecture concept should resolve to a design node*
- **F5 (medium):** The two LLDs describe the idle-handoff contract in opposite directions: the registry says "the queue asks," the queue says "the registry reports" · *coherence is adjacency — each level must agree with its neighbors across the seam*
- **F6 (medium):** All 8 specs carry `[x]` markers whose meaning is defined nowhere — and with no code or tests in the repo yet, if they mean "implemented" they're false · *docs carry current intent, written to be read cold — undefined conventions tax every future reader*
- **F7 (low):** The 90-day slug-recycle decision has no specified collision behavior (what happens to a job referenced by a recycled slug?) · *LLDs close enough of the solution space — edges left open get filled in by whoever codes next*

**What was audited**
- Read fully: the instruction file (CLAUDE.md), docs/high-level-design.md, both LLDs, and both spec files under docs/intent/
- Enumerated: 2 LLDs, 2 spec files, 8 EARS specs (5 QUEUE, 3 REG), 0 arrow segments (no `docs/arrows/` overlay)
- Code/test sampling: none possible — the repo contains no source or test files, so tests-first, `@spec`-annotation, and code-entry-point dimensions were not scored
- Linkage metric: 0 `@spec` references (no code yet); all 8 spec IDs unique, stable, and traceable to their LLD `prefix:` frontmatter

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.