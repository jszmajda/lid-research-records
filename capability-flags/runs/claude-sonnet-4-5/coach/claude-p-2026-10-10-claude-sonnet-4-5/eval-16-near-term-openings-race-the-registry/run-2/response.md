# LID Coach Review: Visit Planner

## Executive Summary

**Bootstrapping — intent is clear, implementation not yet started.**

**Scorecard**
- ✓ HLD discipline — clean architecture, no implementation detail
- ✓ Tenet quality — four real tie-breakers, well-ordered
- ✓ Mutation hygiene — docs are current-intent only, no residue
- ✓ Tenet cascade — design decisions lean the way tenets direct
- ⚠ LLD sufficiency — some validation and eligibility rules left open
- ✗ Arrow completeness — Tests and Code phases missing entirely

**The HLD and LLD layer are solid and well-structured. The most valuable next step is to begin the Tests phase — the specs are ready to drive test authoring, and tests-before-code will keep the arrow coherent from the start.**

## Findings (5 total · 3 high · 2 medium · 0 low)

- **F1 (high):** Specs marked [x] as implemented but no tests or code exist · *arrow completeness*
- **F2 (high):** Tests phase missing — no test files anywhere in the project · *tests before code*
- **F3 (high):** Code phase missing — no implementation files exist · *arrow completeness*
- **F4 (medium):** LLD under-specification leaves validation and eligibility rules implicit · *LLDs close enough of the solution space*
- **F5 (medium):** Spec files lack frontmatter with `prefix:` declaration · *specs are grep-anchored linkage*

## What Was Audited

- Read fully: CLAUDE.md, docs/high-level-design.md, both LLDs (intake and fulfillment), both spec files
- Enumerated: 2 LLDs, 2 spec files, 15 total specs (7 INTAKE-*, 8 FILL-*)
- Linkage metric: 0 `@spec` references (no code exists to annotate)
- Arrow segments: Design layer complete (HLD → 2 LLDs → 2 spec files); Tests and Code phases absent
- Cold-read pass: All docs are clear without conversation context — no implicit assumptions or in-conversation-only meaning detected

## Detail

**F1: Specs marked [x] as implemented but no tests or code exist**  
All 15 specs carry the `[x]` checkbox marker, which conventionally signals implementation. However, the project contains no test files and no code files. The checkbox in EARS specs should reflect *implementation status*, not *authorship status*. When specs are authored but not yet implemented, they should remain `[ ]` until tests exist that exercise them.

**F2: Tests phase missing**  
The arrow is designed to flow `HLD → LLDs → EARS → Tests → Code`. This project has reached the EARS phase — two spec files with 15 well-formed specs — but has no test files. *Tests before code* is load-bearing: tests preload the *use* of the target system before implementation exists, which keeps the API shape disciplined and prevents tests from mirroring what the code happens to do rather than what the specs require. Starting tests now, while the specs are fresh, gives the strongest coherence guarantee.

**F3: Code phase missing**  
No implementation exists. This is expected in a bootstrapping project and is not itself drift — the finding is here to make the arrow state explicit. Once tests are authored for a spec, code follows to satisfy them.

**F4: LLD under-specification**  
Several LLD sections describe behaviors but leave key decision edges open, which will force future agents (or developers) to guess:

- **Intake**: "service, site, or time window is invalid" (INTAKE-002) — what makes them valid? Are there allowed site codes, time granularities, or service catalog constraints?
- **Fulfillment**: "compatible active entries" (FILL-001, FILL-005) — what makes an entry compatible with an opening? Does it check service match, site match, time overlap, accessibility needs?
- **Fulfillment**: "eligible signed-in account" (FILL-004) — what makes an account eligible to claim an opening? Age? Service restrictions? Geographic constraints?

A good LLD is specific enough that two agents reading it would land on compatible implementations. These edges are currently under-specified. Consider closing them — either by adding a subsection to each LLD explaining the rules, or by adding specs that lock down the validation and matching logic.

**F5: Spec files lack frontmatter**  
Neither `intake-specs.md` nor `fulfillment-specs.md` has frontmatter declaring its `prefix:`. While the current IDs (`INTAKE-*`, `FILL-*`) are unambiguous because the project is small, frontmatter makes the prefix authoritative and helps tooling (including future arrow-maintenance overlays) resolve boundaries without parsing ID strings. Consider adding:

```yaml
---
prefix: INTAKE
---
```

to `intake-specs.md`, and similarly for fulfillment.

## What Is Working

The design documentation is in strong shape:

- **Tenets are real tie-breakers.** Each of the four HLD tenets has a defensible opposite and is phrased as a lean, not a triggered rule. They're ordered so that when "first asked, first served" could conflict with "clinical fit precedes utilization," the ordering makes the priority clear.
- **Tenet cascade is clean.** The fulfillment design leans the way the tenets direct: `enteredAt` ordering honors fairness, eligibility rechecks honor clinical fit, transactional outbox honors commit-before-communicating, and event logging honors explain-from-durable-facts.
- **HLD stays architectural.** No schemas, function signatures, or algorithm pseudocode — the HLD carries why, and the LLDs carry what.
- **Mutation discipline.** No history residue, no "was X now Y" language, no `[obsolete]` markers. The docs read as current intent.
- **Cold-read clarity.** All docs are understandable without conversation context. A fresh agent reading them would know what to build.

## Next Steps

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.