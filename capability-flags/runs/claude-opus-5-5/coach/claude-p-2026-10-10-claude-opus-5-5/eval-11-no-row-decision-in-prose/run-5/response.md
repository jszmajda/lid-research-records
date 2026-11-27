# LID Coach — printfarm

## Executive summary

**Posture:** *Clean design layer with one live tenet conflict; the arrow stops at the specs.*

**Scorecard**
- ✓ Configuration & mode fit — directives, `Mode: Full` and the standard directories are all in place, and Full suits a two-node project.
- ✓ Mutation hygiene — every doc reads as current intent, with no changelog residue, obsolete markers or "as discussed" leftovers.
- ✓ Linkage & tree alignment — IDs are unique and EARS-shaped, and `QUEUE` and `REG` each resolve to a leaf through `prefix:` frontmatter.
- ⚠ Tenet cascade — one queue mechanism works against the first tenet and the first goal.
- ⚠ Design ↔ spec coherence — several designed behaviors have no spec, and a few specs have no design behind them.
- ✗ Arrow completeness — there are no tests or code in the repository, yet every spec is marked `[x]`.

**Headline:** The HLD, both LLDs and both spec files are short, cold-readable and well linked, and the Decisions tables mostly name what was rejected and what cost was accepted. The most valuable next step is to settle the in-memory queue against "a submitted job is a promise", either by changing the design or by recording the exception.

## Findings (9 total · 3 high · 4 medium · 2 low)

- **F1 (high):** The job queue lives only in process memory and drops accepted-but-undispatched jobs on restart, on a mini-PC the same LLD says takes unattended OS updates and power blips. An overnight restart defeats the tenet "a submitted job is a promise" and the goal of evening upload with no member present. · *tenet cascade* — leaf designs should lean the way the HLD's tenets say to lean, or record the exception.
- **F2 (high):** The in-memory choice has no Decisions & Alternatives row in `job-queue-design.md`. A cold reader would want to reverse it and cannot tell what was weighed, especially with SQLite already in use next door. · *decision capture* — a choice a reader would still question needs its alternative and accepted cost on the page.
- **F3 (high):** All eight specs are marked `[x]`, but the repository holds no tests, no code and no `@spec` annotations. Consider resetting the markers, or bringing the tests and code into this repo. · *canonical arrow shape* — HLD → LLDs → EARS → tests → code, each phase present.
- **F4 (medium):** Several designed behaviors in `job-queue-design.md` have no spec:
  - staff-before-member ordering and FIFO within a class;
  - acceptance only when the target class has a registered printer;
  - content-hash file storage;
  - 90-day slug recycling;
  - the restart-loss behavior itself.
  
  · *coherence is adjacency* — specs should match the LLD, or unnamed intent drifts with nothing to test against.
- **F5 (medium):** Three specs have little or no design behind them. QUEUE-005 (visible reorder record) has no mechanism in the LLD, though it carries the "queue explains itself" tenet. REG-002 (recovery) and REG-003 (retire) appear only in passing. · *LLDs close enough of the solution space* — two agents reading the LLD should land on compatible implementations.
- **F6 (medium):** The queue "marks the printer suspect" (QUEUE-003), but the registry owns printer state and defines no suspect state, no effect on dispatch and no way to clear it. Consider settling it in printer-registry, or in the HLD if it is a shared contract. · *intent attaches at the lowest node that dominates it* — a decision spanning siblings belongs where both can see it.
- **F7 (medium):** A failed dispatch returns the job to the head of its class queue with no retry limit. A job that every printer rejects would hold its class all night with nobody present. · *tenet cascade* — same lens as F1, here against the fair-access and overnight goals.
- **F8 (low):** The three tenets are unordered, and F1 is exactly where "a job is a promise" meets "the service stays small". Ranking them would have pre-answered it. · *tenets capture forward-looking preference* — tie-breakers need an order when they can conflict.
- **F9 (low):** QUEUE-001 is scoped to "a member uploads", which leaves it open whether the 64 MB limit binds staff uploads. · *scope disambiguation* — a spec's trigger should say exactly where it applies.

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`.
- Enumerated: 2 LLDs, 2 spec files, 8 specs (5 `QUEUE`, 3 `REG`) and 5 Decisions rows, each given a cold-read check.
- Code and tests: none tracked in the repository, so there were no `@spec` references to sample.
- Arrow overlay: `docs/arrows/` is not present, so no structural audit was available.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding to dig into. F1 and F2 are the natural pair to start with.

If you have broader questions about using LID for this project, I can help with those too. Examples are where tests and code should live relative to these docs, when a node deserves a decision doc, and how to handle a contract shared between job-queue and printer-registry.