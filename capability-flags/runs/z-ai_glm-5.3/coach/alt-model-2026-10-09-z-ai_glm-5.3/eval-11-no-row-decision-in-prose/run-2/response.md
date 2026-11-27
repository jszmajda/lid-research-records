**/lid-coach review — printfarm**

**Posture:** Bootstrapping — the arrow is authored and clean; drift is concentrated in the spec layer's status markers, a handful of unspecced behaviors, and one tenet conflict.

**Scorecard**
- ✓ Configuration — directives, `Mode: Full`, and `Version: 1.4.0` present and current
- ✓ HLD discipline — architecture and rationale only; real tenets; no implementation detail bleeding upstream
- ✓ LLD granularity — two leaves, one per component, each well-sized; prefixes (`QUEUE`, `REG`) match frontmatter
- ✗ Linkage hygiene — every spec claims "Implemented," but no code or tests exist
- ⚠ Tenet cascade — the queue-persistence mechanism works against the HLD's own promise tenet
- ✓ Mutation hygiene — all docs read as if written fresh today; no history residue

**Headline:** The design layer is in genuinely good shape — a tight HLD, two well-scoped LLDs, and clean, unique, grep-friendly EARS. The most valuable next steps are repairing the spec-status markers, speccing the three unspecced behaviors, and resolving the queue-persistence question before any code is written.

**Findings (9 total · 3 high · 3 medium · 3 low)**
- **F1 (high):** All 8 specs are marked `[x]` ("Implemented: code and tests exist") but the repository contains no code and no tests · *coherence is adjacency* — each arrow level must agree with its neighbors; an arrow-walker reading these specs today concludes the work is done and skips it
- **F2 (high):** The in-memory queue loses accepted-but-undispatched jobs on restart, and the LLD's own Context says the mini-PC "takes unattended OS updates and the occasional power blip" — landing exactly in the overnight window the tenet "a submitted job is a promise... upload and walk away" and the goal "morning pickup — no member present" describe · *tenets capture forward-looking preference* — a tenet cascade; the tenet and the mechanism share no wording, and no Decisions row records the exception
- **F3 (high):** Three LLD behaviors have no spec anywhere: the acceptance rule ("a job is accepted only if its target class has at least one registered printer"), staff-before-member priority with FIFO within class (central to the "fair access" goal — and "head job" in QUEUE-002 can't be interpreted without it), and restart job-loss ("jobs... are gone, and members resubmit") · *effective intent-tree alignment* — LLD behaviors with no specs are unnamed intent that drifts silently, with nothing to test against
- **F4 (medium):** The persistence choice itself has no Decisions & Alternatives row — a cold reader holding the promise tenet and the SQLite file already in printer-registry would question it and can't reconstruct what was given up · *docs carry current intent* — decision capture
- **F5 (medium):** "Suspect" printer state appears in job-queue (QUEUE-003) but the registry — the node that owns printer state — never defines it (its states are idle/busy/unreachable) and no spec covers how suspect clears · *intent attaches at the lowest node that dominates it* — a concept spanning two siblings belongs at their shared parent or in the owning node
- **F6 (medium):** Design docs restate EARS content instead of citing IDs — job-queue's "Dispatch behavior" bullet duplicates QUEUE-003 and defines the uncited acceptance rule; printer-registry's "Heartbeat behavior" restates REG-001 with divergent wording ("until it responds again" isn't in the spec) · *coherence is adjacency* — two statements of one behavior will drift apart; LID 1.4.0's misplaced-EARS guard says design docs cite, never define
- **F7 (low):** "Printer class" is never defined against "three hardware models" — a cold reader can't tell whether class *is* the model or an independent staff-assigned grouping · *docs carry current intent, written to be read cold*
- **F8 (low):** HLD tenets are unordered, and tenet 1 (the promise) and tenet 3 (service stays small) already conflict in the persistence choice — consider stating precedence · *tenets capture forward-looking preference*
- **F9 (low):** The instruction file is `CLAUDE.md`-only; LID 1.4.0 treats `AGENTS.md` as canonical (with a `CLAUDE.md` alias) — `/update-lid` can reconcile this · *modes are declared, not inferred* — the instruction file is LID's visible foundation

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files — the entire repository (6 files)
- Enumerated: 2 design nodes, 8 EARS specs (5 QUEUE, 3 REG), 5 Decisions & Alternatives rows
- No code or test files exist to sample; git history is a single commit
- No arrow overlay (`docs/arrows/` absent); no capability-flag rows apply to this review

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID for this project — how to sequence the first implementation pass, whether an arrow overlay is worth adding yet, mode transitions, or what to do when a segment grows — I can help with those too.