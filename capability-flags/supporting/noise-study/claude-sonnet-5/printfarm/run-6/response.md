# printfarm — LID Coach Report

**Posture:** Well-shaped design layer, with an open tension in the queue's durability story and no code or tests to close the arrow yet.

**Scorecard**
- ✓ Design tree: HLD, two LLDs and two spec files line up. `QUEUE`/`REG` prefixes match the `prefix:` frontmatter and the HLD's two nodes.
- ✓ EARS specs: every spec is a single-trigger *When X, the system SHALL Y* line. IDs are unique, zero-padded and namespaced.
- ✓ Decisions & Alternatives: most rows name the rejected option and the accepted cost, e.g. shortest-job-first and UUIDs.
- ⚠ Design coherence: the HLD's "job is a promise" tenet and the in-memory queue pull in opposite directions.
- ⚠ Arrow completeness: no tests or code were found, though every spec is checked `[x]`.
- ⚠ Spec coverage: several LLD behaviors have no spec.

**Headline:** The design is clear and specific, with real tenets and honest tradeoff rows. The most valuable next step is to settle whether accepted jobs may be lost on restart. That choice contradicts the first tenet and isn't recorded as a decision.

**Findings (8 total · 2 high · 4 medium · 2 low)**
- **F1 (high):** The in-memory queue drops accepted jobs on restart, which cuts against the "a submitted job is a promise" tenet. The LLD accepts that cost and the HLD's goal says overnight, unattended · *intent leads; code is compiled output* (the design should state a consistent intent before code fixes one)
- **F2 (high):** The in-memory-queue choice appears only in Architecture prose, with no Decisions row for the rejected alternative (persisting like the registry's SQLite) or the accepted cost. A cold reader will want to reverse it · *docs carry current intent, written to be read cold* (decision-capture sweep). This stays separate from F1, which is the design concern.
- **F3 (medium):** All eight specs are marked `[x]`, but the project contains no tests or code carrying `@spec` annotations · *canonical arrow shape*, *tests carry `@spec` annotations*. If the implementation lives in another repo or path, consider noting where.
- **F4 (medium):** LLD behaviors with no spec: accept only if the class has a registered printer, staff-over-member priority with FIFO, the 90-day slug recycle, and content-hash file storage · *effective intent-tree alignment* (behavior with no spec is unnamed intent that drifts silently)
- **F5 (medium):** "Suspect" printer state is undefined. The queue marks printers suspect (QUEUE-003), but the registry, which owns printer state, lists only unreachable, idle and busy. Nothing says whether suspect printers still receive dispatches or how they clear · *intent attaches at the lowest node that dominates it; pause across boundaries*
- **F6 (medium):** Startup rebuild (QUEUE-004) has the queue polling printers directly. The registry owns addresses and heartbeats, and the registry LLD says "the queue asks the registry", while the queue LLD says the registry reports idle. The direction of the queue–registry interaction reads differently in each doc · *coherence is adjacency*, *cold-read pass*
- **F7 (low):** The three tenets could conflict (promise vs. "stay small") and are unordered. The conflict is live in F1 · *tenets capture forward-looking preference* (order them when more than two could collide)
- **F8 (low):** The HLD has no success metrics or explicit key-design-decisions section. Goals are stated but unmeasured · *HLD is architecture and rationale*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files (2 LLDs, 8 EARS specs)
- Cold-read pass and Decisions-table sweep: all 5 rows across both LLDs. The two design nodes plus the HLD were all read in full.
- Code and tests: none found in the project directory, so no arrow-path sampling or `@spec` metrics were possible
- Not present: `docs/arrows/index.yaml`. The arrow-maintenance overlay is not installed, so cascade and structural findings rest on the docs alone.
- Mode: Full, as declared in `CLAUDE.md`. Missing `## LID Scope` is expected and not a finding.
- Non-interactive defaults noted: no prompts were needed

**Offer to help**

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into. F1 and F2 pair well as a first session.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.