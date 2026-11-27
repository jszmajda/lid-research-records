# LID Coach — printfarm

## Executive summary

**Posture:** Well-formed design layer with nothing downstream yet, and one design choice that works against the project's lead tenet.

**Scorecard**
- ✓ Configuration and mode fit — Full mode is declared, and both HLD nodes have a design doc and a spec file
- ✓ Spec hygiene — clean EARS, unique stable IDs, and prefixes that resolve to their LLDs' `prefix:` frontmatter
- ✓ Mutation hygiene — the docs read cold, with no history residue or chat-dependent phrasing
- ⚠ Decision capture — most rows name the alternative and the accepted cost, but the most consequential choice has no row
- ⚠ LLD → spec coherence — several behaviors described in the LLDs have no spec
- ✗ Tenet cascade — the job-queue design contradicts "a submitted job is a promise"
- ✗ Arrow completeness — there are no tests and no code, yet every spec is marked `[x]`

**Headline:** The HLD is lean and architectural, the tenets are real tie-breakers, and the Decisions tables are mostly well formed. The most valuable next step is to settle whether the in-memory queue is a deliberate trade against "a submitted job is a promise", then either record that or change the design.

## Findings (9 total · 3 high · 4 medium · 2 low)

- **F1 (high):** The queue is held only in process memory, and accepted-but-undispatched jobs "are gone" on restart (`job-queue-design.md:14`). The same doc says the mini-PC takes unattended OS updates and power blips (`:10`). An overnight restart therefore defeats the tenet "upload and walk away" and the goal "morning pickup with no member present". · *tenet cascade* — leaf designs lean the way the HLD's tenets say to lean, or record the exception.
- **F2 (high):** That same choice has no Decisions & Alternatives row. A cold reader will question it, especially since the registry next door already persists to SQLite on the same machine, and cannot tell what was weighed. · *decision capture* — a choice a reader would want to reverse needs its alternative and accepted cost on the page.
- **F3 (high):** All eight specs are marked `[x]`, but the repo has no tests, no code and no `@spec` annotations. · *canonical arrow shape* — HLD → LLDs → EARS → Tests → Code; a status marker should reflect a walkable path down to code.
- **F4 (medium):** Several job-queue LLD behaviors have no spec:
  - the accept-only-if-the-class-has-a-registered-printer rule (`:20`);
  - staff-before-member and FIFO ordering (`:25`);
  - the loss of queued jobs on restart, with members resubmitting (`:14`);
  - content-hash storage of uploads (`:14`);
  - slug recycling after 90 days (`:32`).

  · *coherence is adjacency* — specs match the LLD; unspecified behavior has nothing to test against.
- **F5 (medium):** Two printer-registry behaviors have no spec: the 15 s heartbeat interval and printer registration. REG-003 covers retirement, but nothing covers adding a printer or idle/busy reporting for a reachable printer. · *coherence is adjacency* — same gloss as F4.
- **F6 (medium):** "Suspect" is set by the queue (QUEUE-003) but printer state is owned by the registry, whose LLD and specs never mention it. What it means, whether it blocks dispatch and how it clears are all open. · *intent attaches at the lowest node that dominates it* — a contract spanning two siblings belongs where both can see it.
- **F7 (medium):** The three tenets are unordered, and two of them ("a submitted job is a promise" and "the service stays small") pull in opposite directions on exactly the F1 question. · *tenets capture forward-looking preference* — tie-breakers need an order when they can conflict.
- **F8 (low):** Two specs leave edges open. QUEUE-001 scopes the size limit to "a member", so it is unclear whether staff uploads are exempt. QUEUE-005's "record the reordering visibly" does not say what a reader of the queue sees. · *scope disambiguation* / *LLDs close enough of the solution space* — two agents should land on compatible implementations.
- **F9 (low):** The HLD has no target users, key design decisions or success metrics. "Fair access" in particular has no measurable form to design against. · *HLD is architecture and rationale* — the HLD carries the long-lived "why".

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/` (the whole repo is six files).
- Enumerated: 2 LLDs, 2 spec files, 8 specs (QUEUE-001 to 005, REG-001 to 003), 5 Decisions rows.
- Code and tests: none in the repo, so there was nothing to sample, and there are 0 `@spec` references.
- Arrow overlay: `docs/arrows/` is not present.
- Passes run: the dimension review, a cold read of each doc, and a sweep of the Decisions tables. The other four rows (scheduling order, slugs, upload limit, heartbeat interval, registry store) pass as written.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding to dig into. F1 and F2 are the natural pair to start with.

If you have broader questions about using LID for this project — where tests-first fits when you start implementing, what the `[x]` markers should mean, or when a node should split — I can help with those too.