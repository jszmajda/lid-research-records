**/lid-coach report**

**Executive summary**

*Posture:* Healthy structure, drifting coverage — a clean two-node arrow carrying real intent, with one tenet conflict and a few spec gaps.

**Scorecard**
- ✓ Mutation hygiene — docs read as current intent; no history residue or obsolete markers
- ✓ Configuration — LID directives present, Full mode declared, standard directories in place
- ✓ Linkage naming — spec IDs (`QUEUE-NNN`, `REG-NNN`) are grep-friendly, namespaced, and match leaf `prefix:` frontmatter
- ⚠ HLD completeness — architecture and rationale present, but Key Design Decisions and Success Metrics are missing
- ⚠ EARS coverage — some leaf behaviors (prioritization, registration) have no specs
- ⚠ Tenet cascade — the in-memory queue works against the HLD's "a submitted job is a promise" tenet

*Headline:* The arrow is clean, well-named, and captures genuine current intent; the fastest wins are recording the queue-persistence decision and closing the EARS gaps in prioritization and printer registration.

**Findings (8 total · 2 high · 5 medium · 1 low)**
- **F1 (high):** the in-memory queue drops accepted jobs on restart, contradicting the HLD tenet *"a submitted job is a promise"* and the *"morning pickup — no member present"* goal · *tenet cascade* (designs should lean the way the tenets and goals say)
- **F2 (high):** in-memory-vs-persisted queue is stated as flat fact in job-queue Architecture with no Decisions & Alternatives row naming the alternative or its cost · *docs carry current intent* (decision capture)
- **F3 (medium):** the Prioritization section (staff/member classes, FIFO within a class) has no spec — a cold test-writer can't tell what ordering to protect · *effective intent-tree alignment*
- **F4 (medium):** "accepted only if its target class has a registered printer" and the content-hash upload dedup have no specs · *effective intent-tree alignment*
- **F5 (medium):** printer **registration** is unspec'd (retirement is covered by REG-003, registration is not) · *effective intent-tree alignment*
- **F6 (medium):** HLD has no `## Key Design Decisions` or `## Success Metrics` section · *HLD is architecture and rationale*
- **F7 (medium):** Tests and Code phases are absent, yet every spec is marked `[x]` — if the marker denotes verified, the arrow is incoherent; if it denotes active, the convention is undefined · *canonical arrow shape*
- **F8 (low):** cold-read pass — the `[x]` marker's meaning isn't stated anywhere, so a fresh reader can't tell live from implemented · *docs carry current intent*

**What was audited**
- Read fully: CLAUDE.md, docs/high-level-design.md, both LLDs (job-queue, printer-registry) and both spec files
- Enumerated: 2 LLDs, 2 spec files, 8 specs (QUEUE-001…005, REG-001…003)
- No arrow-maintenance overlay present; no code or test files exist in the project (0 `@spec` references)
- No `docs/arrows/index.yaml`, so sampling followed judgment on a small docs-only tree

**Offer**
Want me to walk through the findings in detail, focus on a theme or priority (the tenet conflict F1/F2 is the load-bearing one), or work through specific items together?

If you have broader questions about using LID for your project — where PRDs fit, mode transitions, what to do when a segment grows too large, or how to sequence tests-first for a greenfield service — I can help with those too.