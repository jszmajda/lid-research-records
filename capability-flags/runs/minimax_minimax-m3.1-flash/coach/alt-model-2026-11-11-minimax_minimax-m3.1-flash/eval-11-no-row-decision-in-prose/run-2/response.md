# LID Coach — `printfarm`

**Posture:** Healthy design tree, real specs — but the arrow is claimed complete where the repo is not, and the riskiest decision is undocumented.

**Scorecard**
- ✓ Design tree — one leaf LLD per component, `parent:`/`prefix:` frontmatter consistent, no lumping or orphan nodes
- ✓ Mutation hygiene — no change-narration, no `[obsolete]` residue, no `[inferred]` markers to triage
- ✓ Linkage hygiene — 8 unique, grep-friendly spec IDs, zero-padded, no reuse or collisions
- ⚠ Arrow completeness — no tests and no code in the repo, yet every spec is marked implemented; a UI component has no node
- ⚠ Decision capture — the queue's durability trade-off is captured nowhere
- ⚠ Tenets & cascade — tenets are unordered, and the in-memory queue works against the "submitted job is a promise" tenet

**Headline:** The design layer is clean, well-named, and residue-free — the fastest wins are reconciling the instruction file with the current LID template, correcting the implementation markers to match reality, and recording the one decision a future reader would most want to reverse.

## Findings (12 total · 5 high · 5 medium · 2 low)

- **F1 (high):** `CLAUDE.md` is a condensed pointer ("Consult the linked-intent-dev skill") rather than the canonical directive block — no `## Linked-Intent Development (MANDATORY)` section, no workflow-doc pointer, no `@spec`/terminology guidance, and no `AGENTS.md` with `CLAUDE.md` as an alias · *modes are declared, not inferred* / *minimum surface, maximum discipline* — run `/update-lid` to reconcile
- **F2 (high):** all 8 specs carry `[x]` (implemented) but the repo contains no tests and no code — the markers claim an implementation that isn't here · *intent leads; code is compiled output* / *tests before code*
- **F3 (high):** the queue's core trade-off — "held entirely in process memory; accepted jobs are gone after a restart" — has no Decisions row, no rationale, and no spec · *docs carry current intent* (a decision doc/row captures a choice that stays live) · *decision capture*
- **F4 (high):** the HLD tenet "a submitted job is a promise: members should be able to upload and walk away" is defeated by the restart-loss design under the power-blip condition the LLD itself names; no row records the exception, and the tenets are an unordered list so the competing "the service stays small" tenet has no stated priority · *tenets capture forward-looking preference* (order them so the higher one wins) · *tenet cascade*
- **F5 (high):** the member/staff web UI (upload, queue view, reordering) has no design node, yet `QUEUE-005` requires a visibly recorded reordering and the HLD Approach and tenets depend on it — intent with no owning LLD · *effective intent-tree alignment* (LLD behaviors with no specs drift silently)
- **F6 (medium):** behaviors described in the LLDs but specified nowhere: class-acceptance rule, the two priority classes and their FIFO rule, printer registration, the 90-day ID recycle, the 15 s heartbeat interval, and content-hash dedup · *effective intent-tree alignment*
- **F7 (medium):** "the head job of that printer's class" (`QUEUE-002`) and "the head of its class queue" (`QUEUE-003`) are ambiguous once two priority classes exist, and no retry/backoff or poison-job rule is stated for a repeatedly failing job · *LLDs close enough of the solution space*
- **F8 (medium):** `QUEUE-003` has the queue "mark the printer suspect," but `suspect` appears nowhere in the registry's state model (idle/busy/unreachable) and the registry LLD and specs never mention it — no rule for when a suspect printer becomes eligible again · *intent attaches at the lowest node that dominates it* (printer state belongs to the registry node; this is a cross-boundary cascade that didn't pause)
- **F9 (medium):** `REG-002` says to "mark it idle or busy per its reported state" without defining the mapping for error, paused, or printing states · *LLDs close enough of the solution space*
- **F10 (medium):** the HLD omits `## Target Users`, `## Key Design Decisions`, and `## Success Metrics` — all of which Full mode expects filled — and names its architecture section `## Architecture` rather than `## System Design` · *HLD is architecture and rationale*
- **F11 (low):** the HLD says "three hardware models" while the queue and registry say "printer class" — a cold reader can't tell whether class = model · *docs carry current intent* (written to be read cold)
- **F12 (low):** `QUEUE-004` says the service rebuilds "farm state" at startup but doesn't say how the three-miss rule applies to printers that are already offline at boot · *LLDs close enough of the solution space*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`
- Enumerated: 2 leaf LLDs, 2 spec files, 8 EARS IDs, 0 arrow segments (`docs/arrows/` absent — overlay not installed)
- Code and tests: none present in the repository — the arrow stops at EARS, so `@spec` placement, annotation hygiene, and tests-first evidence could not be assessed
- Cross-checked against the current `linked-intent-dev` conventions (installed version 1.4.0; project `- Version: 1.4.0` matches) and the canonical instruction-file template

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.