# printfarm — LID Coach Report

## Executive Summary

**Posture**: Bootstrapping — arrow in place, content sparse, awaiting implementation.

**Scorecard**
- ✓ Configuration — Full mode declared, proper directory structure
- ✓ HLD discipline — architecture-level focus, clean tenets
- ✓ LLD granularity — two clear components, appropriate decomposition
- ⚠ EARS format — specs use simplified checkboxes rather than full WHEN/SHALL structure
- ⚠ LLD sufficiency — design nodes are terse; could close more of the solution space
- ✗ Arrow completeness — tests and code phases not yet present (expected for bootstrap)

**Headline**: The arrow structure is solid and the HLD carries real design decisions. The fastest wins are migrating specs to proper EARS format and expanding the LLDs so future sessions have less guesswork when implementation begins.

---

## Findings (5 total · 2 high · 2 medium · 1 low)

- **F1 (high):** Specs use simplified checkbox format instead of full EARS structure · *specs are grep-anchored linkage*
- **F2 (high):** Instruction file directive is informal rather than standard LID block · *modes are declared, not inferred*
- **F3 (medium):** LLDs are terse and leave solution edges open · *LLDs close enough of the solution space*
- **F4 (medium):** HLD lacks a Key Design Decisions section · *HLD is architecture and rationale*
- **F5 (low):** No tests or code yet · *canonical arrow shape*

---

## What was audited

- Read fully: CLAUDE.md, docs/high-level-design.md, docs/intent/job-queue/job-queue-design.md, docs/intent/job-queue/job-queue-specs.md, docs/intent/printer-registry/printer-registry-design.md, docs/intent/printer-registry/printer-registry-specs.md
- Enumerated: 2 LLDs, 2 spec files carrying 8 total specs
- No code or test sampling (none present yet)
- No arrow overlay detected

---

## Detail

### F1 — High. Specs use simplified checkbox format instead of full EARS structure.

Both `job-queue-specs.md` and `printer-registry-specs.md` list specs as checkboxed bullets with a simplified structure: `[x] **QUEUE-001**: When a member uploads...`. Under *specs are grep-anchored linkage*, proper EARS format uses a structured template per spec with explicit ID, status, scope (WHEN), requirement (SHALL), and rationale sections. The simplified format you're using blurs these elements together and makes it harder for agents to parse scope disambiguation (a universal-sounding spec vs. one scoped to a mode), status markers (active vs. deprecated), and rationale. The checkpoint-style `[x]` markers also muddy the distinction between "this spec exists" and "this spec is satisfied by code" — the latter is what tests and `@spec` annotations establish, not a checkbox in the spec file itself. Try migrating each spec to the full EARS template: a heading per spec ID, with `## Status`, `## Scope`, `## Requirement`, and `## Rationale` subsections. The payoff is that future agents can grep for a spec ID and land on a self-contained block that answers "what does this mean, when does it apply, why does it exist?" without reading the entire file.

### F2 — High. Instruction file directive is informal rather than standard LID block.

CLAUDE.md line 5 reads "Consult the linked-intent-dev skill." — a plain instruction rather than the standard LID directive naming. Under *modes are declared, not inferred*, the instruction file should explicitly state that this project uses Linked-Intent Development (or "linked-intent-dev") so future agents recognize the methodology by name. The abbreviated form you're using works for someone who already knows what LID is, but leaves a cold reader guessing. Try replacing line 5 with a proper directive: "This project uses Linked-Intent Development. See the linked-intent-dev skill for workflow guidance." or similar. This also sets up better alignment with `/update-lid`, which keys off the directive text when reconciling configuration. Run `/update-lid` to reconcile the instruction file to the current LID template — it will offer to expand the directive block to the standard form.

### F3 — Medium. LLDs are terse and leave solution edges open.

Both `job-queue-design.md` (33 lines) and `printer-registry-design.md` (25 lines) sketch the architecture but leave key edges unspecified. Under *LLDs close enough of the solution space*, a good LLD is specific enough that two reasonable agents reading it would land on compatible implementations. Examples of open edges in the current LLDs: job-queue doesn't specify what happens when a job is dispatched and the printer accepts it but then fails mid-print (does the job stay "dispatched" forever, or does the registry report failure and the queue re-enqueues it?); printer-registry doesn't specify the schema of the SQLite table beyond "id, class, network address, state" (are there timestamps? created_at? last_heartbeat_at? what's the primary key?). These aren't code-level details — they're design choices that shape the behavior agents will implement. Without them, each agent session fills in the gaps differently, and intent drifts silently. Try expanding each LLD with a few more subsections: Error Handling, State Transitions, Persistence Schema (just the columns and their meaning, not SQL), whatever closes the edges you notice a cold reader would pause at.

### F4 — Medium. HLD lacks a Key Design Decisions section.

The HLD has strong tenets ("A submitted job is a promise" is a real tie-breaker with a defensible opposite) and the architecture is clear, but there's no `## Key Design Decisions` section capturing the foundational choices that shaped the system. Under *HLD is architecture and rationale*, the HLD should carry the "why" that lives longer than any specific implementation — and decisions like "why a single service on the mini-PC rather than distributed?" or "why event-driven dispatch rather than polling the queue?" are that kind of rationale. The Decisions & Alternatives tables in the LLDs capture component-level choices (FIFO vs. shortest-job-first, short slugs vs. UUIDs), but the system-level decisions — the ones that set the constraints the LLDs inherit — belong in the HLD. Try adding a `## Key Design Decisions` section to the HLD (between Tenets and Goals is a natural spot) with one or two entries for the architecture-level calls: single-service vs. distributed, event-driven dispatch, why the mini-PC is the deployment target. You already have some of this in the Problem and Approach sections ("the mini-PC is modest hardware; the service stays small"), but surfacing it as explicit decisions makes it easier for future sessions to understand what's load-bearing.

### F5 — Low. No tests or code yet.

The arrow currently stops at the spec layer; no tests or code are present. Under *canonical arrow shape*, a complete arrow runs HLD → LLDs → EARS → Tests → Code. The absence of tests and code is expected for a bootstrap project — you're at the "design skeleton ready, implementation not yet started" stage — so this isn't drift, just incomplete. When you begin implementation, follow the tests-before-code discipline: write tests that cite the specs (with `@spec` annotations) before writing the code that satisfies them. That preloads the use of the target system into the context window before implementation exists, which keeps the code honest to the spec rather than the other way around.

---

## Offer to help

Want me to walk through any of these findings in more detail, focus on a specific priority, or work through fixes together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.