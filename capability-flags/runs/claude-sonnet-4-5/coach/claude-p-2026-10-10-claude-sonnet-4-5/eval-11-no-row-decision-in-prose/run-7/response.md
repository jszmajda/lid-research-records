Now I'll produce the LID coach review report.

---

# LID Coach Review — printfarm

**Bootstrapping — design complete, implementation not yet started.**

## Scorecard

- ✓ **HLD discipline** — clean architecture with no implementation detail
- ✓ **LLD granularity** — two well-scoped components, appropriate boundaries
- ✓ **Mutation hygiene** — docs are clean present-tense intent
- ✓ **Tenet quality** — three real tie-breakers with defensible opposites, well-ordered
- ✓ **Intent-tree alignment** — spec prefixes trace cleanly to LLDs
- ⚠ **Arrow completeness** — design phases solid, implementation phases not started
- ✗ **Status-marker coherence** — specs marked done without tests or code

**Headline:** The design layer is well-formed and ready to drive implementation. The single highest-priority action is fixing the spec status markers before starting tests-first work.

## Findings (3 total · 1 high · 2 medium)

- **F1 (high):** Specs marked `[x]` (complete) but no tests or code exist — *coherence is adjacency* (adjacent arrow levels must agree; status markers reflect implementation state)
- **F2 (medium):** Tests phase not yet started — *tests before code* (tests preload the use of the target system before implementation)
- **F3 (medium):** Code phase not yet started — canonical arrow expects EARS → Tests → Code (normal for early-stage design work)

## What was audited

- Read fully: CLAUDE.md, docs/high-level-design.md, all 2 LLDs, all 2 spec files
- No code or tests present to sample
- No arrow overlay (docs/arrows/) installed
- Spec count: 8 total (5 QUEUE, 3 REG)

## Strengths worth keeping

Your design layer shows discipline across several dimensions:

- **Clean architecture separation.** The HLD stays at the architecture level — problem, approach, tenets, goals. No schemas, no function signatures, no implementation detail. This is exactly what keeps an HLD valuable over time.

- **Well-chosen granularity.** Two LLDs for two intent components (job-queue, printer-registry) with clear boundaries and no overlap. Neither is lumped nor fragmented. Each owns exactly one EARS prefix.

- **Strong tenets.** All three tenets have defensible opposites (you could build a different system that prioritized differently), they're tie-breakers rather than triggered rules, and they're ordered for when they conflict. These will guide implementation decisions the specs don't cover.

- **Mutation over accumulation.** The docs read as current intent, written fresh — no "was X, now Y" residue, no planning text, no conversational fossils. This is the discipline that keeps LID docs cheap to load in future sessions.

- **Decision capture that passes the cold-read test.** The Decisions & Alternatives tables in both LLDs record choices a future reader would still want to know about (FIFO vs shortest-job-first, base32 slugs vs UUIDs, 15s heartbeat interval). Each explains the alternative considered and the accepted cost, giving a cold reader what they need to understand why the system is shaped this way.

## Detail on F1: Status-marker incoherence

Every spec in both files is marked `[x]`, indicating completion. But there are no tests exercising these specs and no code implementing them. This breaks a load-bearing LID principle: *coherence is adjacency* — each level of the arrow must agree with its adjacent level.

**Why this matters:** Status markers are how agents (and humans) know what's real vs. what's planned. When specs show `[x]` but tests and code don't exist, every future session has to second-guess the markers. The next agent reading QUEUE-002 sees `[x]` and assumes it's implemented and tested; when they grep for `@spec QUEUE-002` and find nothing, they have to decide whether the marker is wrong or the implementation is missing. That decision tax compounds every session.

**What to do:** Change all spec markers from `[x]` to `[ ]`. Once you write a test for a spec (and the test passes), that's when the spec earns `[x]`. The marker tracks *tested and implemented*, not *designed*.

## On F2 and F3: Tests and code phases

These are normal states for early design work. You've built the intent layer; the implementation phases come next. The canonical LID arrow is *Tests → Code* — write the test that exercises the spec before writing the code that satisfies it. This keeps tests honest (they verify the spec's intent rather than mirroring whatever the code happens to do) and surfaces interface design issues before implementation details have time to calcify.

When you start implementation, QUEUE-001 through QUEUE-005 and REG-001 through REG-003 are your roadmap.

---

Want me to walk through any of these findings in detail, or help you think through how to start the tests-first phase? You can also ask about specific items.

If you have broader questions about using LID for your project — adding more design nodes as the system grows, how to handle G-code storage decisions that might deserve their own LLD, or what happens when a printer model needs special handling — I can help with those too.