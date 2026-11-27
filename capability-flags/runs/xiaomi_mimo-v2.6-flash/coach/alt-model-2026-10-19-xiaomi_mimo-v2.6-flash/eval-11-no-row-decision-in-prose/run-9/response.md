# LID Coach — printfarm

**Posture: Bootstrapping — configuration is clean and the arrow is real through EARS; status markers and two cross-node seams need attention.**

**Scorecard**
- ✓ Configuration — directive block, `Full` mode marker, and `## Navigation` all present; `- Version: 1.4.0` matches the installed plugin
- ✓ HLD discipline — architecture and rationale only (problem, approach, tenets, goals, non-goals); zero implementation detail leaked upstream
- ✓ Mutation hygiene — no history residue, no obsolete markers, no changelog prose; every Decisions row carries a rejected alternative *and* an accepted cost
- ✓ Linkage shape — 8 unique IDs, `QUEUE`/`REG` prefixes match each LLD's `prefix:` frontmatter, all specs event-driven and WHEN-scoped
- ⚠ Status markers — every spec claims `[x]` while the repo contains no code and no tests
- ⚠ Intent-tree seams — a printer state and a couple of behaviors each live on only one side of a seam

**Headline:** The design layer is in genuinely good shape — two LLDs that map 1:1 to the HLD's design nodes, and Decisions tables that are a model of the accepted-cost pattern. The fastest win is reconciling the `[x]` markers with the fact that nothing has been implemented yet; the most consequential is the queue-persistence choice, which quietly works against your own top tenet.

**Findings (8 total · 3 high · 3 medium · 2 low)**

- **F1 (high):** the in-memory queue drops accepted jobs on restart — under the power-blips-and-OS-updates condition your own Context states — yet no Decisions row records the trade against "a submitted job is a promise" or the no-member-present goal · *tenet cascade* (design mechanisms shouldn't defeat a tenet without a recorded exception) + *decision capture* (a live choice a cold reader would question, with no row saying what was given up)
- **F2 (high):** QUEUE-003 tells the system to "mark the printer suspect," but `printer-registry` never defines that state — its design and specs know only idle/busy/unreachable, with no rule for whether suspects take dispatches or how they clear · *intent attaches at the lowest node that dominates it* (substance governing a sibling lodged in one leaf)
- **F3 (high):** all 8 specs are marked `[x]`, which in LID means "code and tests exist," while the repository has neither; if `[x]` means something else here, the instruction file never says so · *intent leads; code is compiled output* (the marker tells every future session the arrow has been walked when it hasn't)
- **F4 (medium):** three LLD behaviors have no spec anywhere — accepting a job only when its class has a registered printer, staff printer registration, and the 15 s heartbeat cadence · *effective intent-tree alignment* (behavior described at design level with nothing to test against)
- **F5 (medium):** QUEUE-005 ("record the reordering visibly") has no supporting mechanism in its owning LLD — its only basis is the HLD tenet · *coherence is adjacency* (the spec↔LLD seam is thin; two agents could implement very different "visible")
- **F6 (medium):** the tenets can conflict — "upload and walk away" versus "the service stays small" — with no stated precedence, and that collision has already happened (F1) · *tenets capture forward-looking preference* (an unordered list when more than two tenets can conflict)
- **F7 (low):** spec markers are written as `` `[x]` `` (backticked) rather than the standard `- [x]` line, so checkbox rendering and the mechanical audit screens used by `/arrow-maintenance` won't match them · *minimum surface, maximum discipline* (a project-local format variant that silently overrides the standard)
- **F8 (low):** QUEUE-001 is scoped to "a member" uploads — if staff can also upload, the 64 MB limit's relationship to that path is unstated · *scope disambiguation* (litmus: a second variant would make this ambiguous)

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, and all four files under `docs/intent/`
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 8 EARS specs (QUEUE-001–005, REG-001–003)
- Repository totals 6 files; **no source or test files exist**, so `@spec` annotation placement, tests-first evidence, and semantic legibility were not assessable this run (0 `@spec` references found)
- No arrow overlay (`docs/arrows/` absent), so structural enumeration — reverse orphans, `index.yaml` drift — was out of reach; nothing structural is claimed here beyond what sampled reads show
- Cold-read pass and Decisions-table sweep run over every LLD; all five existing decision rows passed the cold-reader test

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.