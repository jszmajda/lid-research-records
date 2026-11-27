# LID Coach — printfarm

## Executive summary

**Healthy docs, incomplete arrow.** The intent layer here is unusually clean — no residue, no dangling references, disciplined IDs — but the arrow stops two rungs short: every spec is marked implemented while the repository contains no tests and no code, and several behaviors described in the LLDs have no spec at all.

**Scorecard**
- ✓ Mutation hygiene — every doc reads as if authored today; no changelog, no obsolete markers, no "was X, now Y"
- ✓ Linkage hygiene — 8 unique IDs that match each LLD's `prefix:` frontmatter exactly; no dangling references
- ✗ Arrow completeness — all specs marked `[x]` (implemented), but no tests and no code exist anywhere in the repo
- ⚠ Intent-tree alignment — excellent ID hygiene, but key LLD behaviors have no spec, and printer state is claimed by two nodes
- ⚠ HLD depth — clean and implementation-free, but missing Target Users, Key Design Decisions, and Success Metrics
- ⚠ Tenets — present and genuinely project-specific, but one pair can conflict and no order is recorded

The docs are in good shape; the fastest wins are bringing the status markers back in line with reality and closing the spec-coverage gaps, then settling who owns printer state.

## Findings (11 total · 3 high · 5 medium · 3 low)

- **F1 (high):** All 8 specs are marked `[x]` ("implemented"), but the repo has no tests and no code — the markers assert an implementation the arrow doesn't contain (`docs/intent/job-queue/job-queue-specs.md:3-7`, `docs/intent/printer-registry/printer-registry-specs.md:3-5`) · *canonical arrow shape — every phase exists; coherence is adjacency — each level agrees with its neighbor*
- **F2 (high):** LLD behaviors with no EARS spec: class-eligibility on upload (`job-queue-design.md:20`), the staff/member priority classes (`job-queue-design.md:25`), queue loss on restart and content-hash resubmission (`job-queue-design.md:14`), 90-day slug recycling (`job-queue-design.md:32`), staff *registering* a printer and how class is assigned (`printer-registry-design.md:10,14`) · *effective intent-tree alignment — LLD behaviors with no specs are unnamed intent that drifts silently*
- **F3 (high):** Two nodes claim the same state: job-queue "rebuilds its picture of the farm" by polling printers directly (`job-queue-design.md:14`, QUEUE-004) while the registry is the node that "knows which printers exist… reachable and idle" (`docs/high-level-design.md:16`) — a fact that dominates both siblings belongs at their shared parent · *intent attaches at the lowest node that dominates it; cascade within a segment, pause across*
- **F4 (medium):** "Suspect" (`job-queue-design.md:21`, QUEUE-003) is an undefined state that overlaps the registry's "unreachable" (REG-001), with no path back to dispatch eligibility and no spec saying who clears it · *semantic legibility as cheap linkage — code and docs should speak the spec's vocabulary*
- **F5 (medium):** Tenets are unordered and one pair can conflict — "a submitted job is a promise" against "staff override members" — when staff reorder a member's overnight job, the queue defeats the promise, and nothing records which tenet wins · *tenets capture forward-looking preference — order them so the higher one wins*
- **F6 (medium):** The tenet leans are thin: one reads as a goal ("a promise"), one as a hardware constraint, and one ("no silent reordering") as a triggered rule rather than a tie-breaker — each should name which way to lean when a spec doesn't cover the case · *tenets capture forward-looking preference — a lean, not a rule*
- **F7 (medium):** HLD omits Target Users, Key Design Decisions, and Success Metrics; Full mode expects every section filled, and "fair access to the popular printer classes" (`docs/high-level-design.md:27`) is a goal with no falsification signal · *HLD is architecture and rationale*
- **F8 (medium):** The two-tier staff/member priority is a live choice a cold reader would question — it sits against the HLD's fair-access goal — yet it survives as one prose line with no Decisions row and no recorded tradeoff · *docs carry current intent — keep-side: a choice that stays live needs a record a reader can reconstruct*
- **F9 (medium):** Neither LLD has an Open Questions & Future Decisions section, though several edges are genuinely open: which printer of a class receives the head job, whether printer "class" means hardware model, G-code retention, and slug collision handling at recycle · *LLDs close enough of the solution space — under-specified edges get filled in by the agent*
- **F10 (low):** Specs rely on cross-file concepts without the parenthetical that makes a grep-isolated line safe — "the registry reports a printer idle" (QUEUE-002), "rebuild farm state" (QUEUE-004), "visibly in the queue view" (QUEUE-005, also unverifiable wording) · *scope disambiguation — every line must stand alone when found by grep*
- **F11 (low):** `CLAUDE.md:11-16` adds a shallow second navigation axis over a two-node tree, while the HLD's Architecture section doesn't carry the QUEUE/REG prefixes, so a prefix grep doesn't land one hop from the HLD · *verticalize intent — keep one navigation axis; minimum surface, maximum discipline*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files — all 6 tracked files in the repository
- Enumerated: 2 LLDs, 2 spec files, 8 EARS specs (5 `QUEUE-*`, 3 `REG-*`), 3 Decisions rows per LLD
- Linkage metric: 0 `@spec` annotations in code or tests — no implementation exists yet
- Overlay: no `docs/arrows/` present, so no index.yaml or segment-status signals to consult
- Git: a single commit ("fixture"), so there is no commit history from which to read tests-first evidence
- Not reviewed (no code exists): implementation entry points, test placement, annotation hygiene

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.