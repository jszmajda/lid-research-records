## LID Coach — printfarm

**Posture:** Bootstrapping — arrow in place through EARS, nothing realized below it.

**Scorecard**
- ✓ Linkage — clean, greppable IDs; `prefix:` frontmatter matches every spec ID
- ✗ Arrow completeness — the arrow stops at EARS; no tests, no code, no `@spec` anywhere
- ⚠ Spec status — all 8 specs marked `[x]` (implemented) with nothing implemented
- ⚠ Intent-tree alignment — the web UI is required by the HLD and QUEUE-005 but has no node
- ⚠ HLD discipline — no Key Design Decisions, Target Users, or Success Metrics
- ⚠ Tenets — unordered, one conflicts with the queue design, one is spec-shaped
- ✓ Mutation hygiene — no obsolete markers, changelog residue, or obsolete prose
- ✓ Mode fit — Full is a fair declaration for a two-node project this young

*The arrow is real and well-formed at the top: two leaves, unique stable IDs, matching `prefix:` frontmatter, clean prose with no history residue. The fastest wins are status honesty and closing the named-but-unowned gaps.*

**Findings (13 total · 4 high · 6 medium · 3 low)**

- **F1 (high):** all 8 specs carry `[x]` (implemented) though the repo has no code and no tests — consider flipping to `[ ]` until Phase 5/6 lands · *docs carry current intent; canonical arrow shape*
- **F2 (high):** the in-memory-only queue drops accepted jobs on restart/power blip (`job-queue-design.md:14`), against tenet 1 "a submitted job is a promise" and the overnight goal — no Decisions row records the trade-off · *tenet cascade; decision capture*
- **F3 (high):** "printer class" is never defined or enumerated, yet per-class queueing and dispatch are the core mechanism · *LLDs close enough of the solution space*
- **F4 (high):** the web UI (member upload, staff reorder, "queue view") appears in the HLD, `job-queue-design.md:10`, and QUEUE-005, but has no design node and no specs · *effective intent-tree alignment*
- **F5 (medium):** "suspect" printer state is introduced by the queue (QUEUE-003) while printer state is owned by the registry, whose LLD enumerates only idle/busy/unreachable — no spec defines suspect · *intent attaches at the lowest node that dominates it*
- **F6 (medium):** QUEUE-002 says "the head job of that printer's class" while the LLD defines two priority classes, and nothing says how a job enters the staff class · *scope disambiguation*
- **F7 (medium):** LLD behaviors with no EARS — accept-only-if-class-has-a-printer, priority ordering, content-hash dedup, printer registration, heartbeat interval · *effective intent-tree alignment*
- **F8 (medium):** the HLD records no Key Design Decisions — a cold reader would ask why queues are per-class rather than per-printer or global, and why the whole service sits on one mini-PC · *decision capture*
- **F9 (medium):** the HLD omits Target Users and Success Metrics, so "how do we know this works" is unanswered (e.g. overnight completion rate) · *HLD is architecture and rationale*
- **F10 (medium):** tenets are unordered despite a live conflict (promise vs. modest hardware), and "no silent reordering" is a triggered rule already carried by QUEUE-005 · *tenets capture forward-looking preference*
- **F11 (medium):** no tests and no code exist, so nothing cites the 8 specs — the arrow is not yet walkable end-to-end · *tests before code; `@spec` annotations*
- **F12 (low):** QUEUE-005's "record the reordering visibly in the queue view" is hard to test as written — consider naming what is recorded and who sees it · *LLDs close enough of the solution space*
- **F13 (low):** the slug-recycling rule (90 days) and the "printer LCDs" rationale both assume capabilities no doc establishes; the Decisions tables also fold alternatives into Rationale rather than a separate column · *docs carry current intent*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files
- Enumerated: 2 LLDs, 2 spec files, 8 spec IDs (all unique, all prefix-matched), 0 `@spec` references, 0 code files, 0 test files
- Arrow-path sampled: 0 end-to-end segments — nothing exists below EARS to sample
- Git history: 1 commit (all six files at once), so no tests-first vs. code ordering evidence available
- Overlay: `docs/arrows/` not installed — for the precise enumeration behind F5/F7, `/arrow-maintenance` is the faster instrument

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.