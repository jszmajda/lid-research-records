I've reviewed the project against LID's principles. Here's the report.

---

## LID Coach — printfarm

### Executive summary

**Posture:** Clean design layer; the arrow stops at specs, and the headline tenet is in tension with the queue's own durability design.

**Scorecard**
- ✓ **HLD discipline** — architecture and rationale, no schema/signature bleed into the HLD
- ✓ **Linkage** — specs are grep-anchored; unique IDs, clean `prefix:`/`parent:` frontmatter on both nodes
- ✓ **Mutation hygiene** — docs read as current intent; no history residue or planning text
- ✗ **Arrow completeness** — every spec is marked done, but there are no tests and no code
- ⚠ **Tenet cascade** — the in-memory queue works against "a submitted job is a promise"
- ⚠ **Decision capture** — the queue's durability trade-off lives in prose, not in a Decisions row

**Headline:** The design layer is in genuinely good shape — two well-scoped nodes, clean EARS specs, and Decisions tables that name real alternatives and accepted costs. The most valuable next step is resolving the tension between your lead tenet and the queue's in-memory design, which the restart conditions in your own docs will trigger.

### Findings (5 total · 3 high · 2 medium)

- **F1 (high):** All 8 specs are marked `[x]` complete, but the arrow has no Tests or Code phases anywhere in the project · *canonical arrow shape* & *tests before code* — the completion markers assert a coherence (code passing tests that cite specs) that nothing downstream can back.
- **F2 (high):** The job-queue holds accepted jobs in process memory and loses undispatched ones on restart — under the unattended OS updates and power blips the LLD itself names — which defeats the tenet *"a submitted job is a promise: upload and walk away"* and the goal *"evening upload, overnight print, morning pickup"* · *tenets capture forward-looking preference* (tenet cascade).
- **F3 (high):** The in-memory-vs-persisted queue choice, and its accepted cost of lost jobs on restart, lives in the Architecture prose but has no row in job-queue's Decisions & Alternatives table · *docs carry current intent* (decision capture) — a cold reader would question this exact choice and can't see what was weighed.
- **F4 (medium):** Printer polling is split across both nodes — the queue polls printers directly on startup (QUEUE-004) while the registry owns printer reachability/state via heartbeats · *intent attaches at the lowest node that dominates it* — worth confirming the boundary is deliberate rather than two polling paths drifting apart.
- **F5 (medium):** The HLD's three tenets are an unordered list, yet "the service stays small" and "a submitted job is a promise" pull opposite ways — which is precisely the unresolved conflict behind F2 · *tenets capture forward-looking preference* — ordering them states which wins.

### What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design nodes (`job-queue`, `printer-registry`) and both `*-specs.md` files.
- Enumerated: 2 LLDs, 8 EARS specs (QUEUE-001–005, REG-001–003), all marked `[x]`.
- Not found: any test files or source code; no `docs/arrows/` overlay (arrow-maintenance not installed).
- Mode: Full (declared in the `## LID` block), which matches the project's breadth.

---

Want me to walk through any of these in detail, focus on a theme or priority, or work through specific items together? F2 and F3 are closely linked and would be a natural place to start.

If you have broader questions about using LID here — when to add the Tests/Code phases, whether to install the arrow overlay as the farm grows, or how to record a durability trade-off cleanly — I can help with those too.