## printfarm: LID coach report

**Posture:** Solid skeleton, with one design that cuts against the HLD's top tenet.

**Scorecard**
- ✓ Configuration: the `## LID` block declares Full mode, and the HLD, both LLDs and both spec files are in the standard places.
- ✓ Intent-tree alignment: the `QUEUE` and `REG` prefixes match each LLD's `prefix:` frontmatter, and both nodes are named in the HLD's Architecture section.
- ✓ Spec form: all eight specs are well-formed EARS with unique, stable IDs.
- ✓ Mutation hygiene: no changelog residue, `[obsolete]` markers, or "was X, now Y" narration in any doc.
- ⚠ Tenet cascade: the in-memory queue works against the HLD's first tenet and its first goal.
- ⚠ Arrow completeness: the specs are all marked `[x]`, but no tests or code are in the repo.

**Headline:** The design layer is clean and compact, and the Decisions & Alternatives tables carry real "accepted cost" reasoning. The most valuable next step is to reconcile the volatile in-memory queue with the "a submitted job is a promise" tenet.

**Findings (7 total · 2 high · 3 medium · 2 low)**
- **F1 (high):** The job-queue holds accepted jobs only in memory, and jobs not yet dispatched are lost on restart, which the LLD's own Context says the mini-PC does (unattended OS updates, power blips). That works against the HLD tenet "a submitted job is a promise… upload and walk away" and the goal "evening upload, overnight print, morning pickup — with no member present". A restart overnight silently drops a member's job. · *tenet cascade: do designs lean the way the tenets say to lean?*
- **F2 (high):** Nothing records that exception. There is no Decisions row for "in-memory queue, members resubmit", so a cold reader cannot tell whether losing jobs was a deliberate trade against the "service stays small" tenet or an oversight. The reasoning appears only as a one-line statement in the Architecture prose. · *decision capture: a live decision should be in a Decisions row with what was given up*
- **F3 (medium):** The tenets are an unordered list, and the first and third can conflict (F1 is exactly that case). An ordering would pre-narrow the tie-breaker for future sessions. · *tenets capture forward-looking preference*
- **F4 (medium):** Some job-queue behaviors have no specs. "Accepted only if the target class has at least one registered printer" and "two priority classes, FIFO within a class" appear in the LLD but have no `QUEUE-` spec, so nothing anchors tests to them. · *effective intent-tree alignment: LLD behaviors with no spec are unnamed intent*
- **F5 (medium):** Edges are left open across the two nodes. `QUEUE-003` marks a printer "suspect", but the registry's states (unreachable, idle, busy) have no "suspect" and nothing says how it clears. `REG-003` retires a printer without saying what happens to queued jobs when it was the last printer in its class. · *LLDs close enough of the solution space*
- **F6 (low):** All eight specs are checked `[x]`, but the repo has no tests, no code and no `@spec` annotations. If that is intentional (the code lives elsewhere, or this is design-first), a one-line note would help. Otherwise the markers claim more than a cold reader can verify. · *tests before code; tests carry `@spec` annotations*
- **F7 (low):** REG's heartbeat interval (15 s) and "three consecutive misses" are split between the LLD's Decisions table and `REG-001`. That is fine today, but keep the spec and the row in step when either changes. · *coherence is adjacency*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files.
- Enumerated: 1 HLD, 2 LLDs, 8 specs (5 `QUEUE`, 3 `REG`), no arrow overlay (`docs/arrows/` absent).
- Code and tests: none present to sample.
- Cold-read pass: all five docs. The only context-dependent bit was the undefined "suspect" state (F5).

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into, and F1/F2 are the ones I'd start with.

If you have broader questions about using LID for your project (multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large), I can help with those too.