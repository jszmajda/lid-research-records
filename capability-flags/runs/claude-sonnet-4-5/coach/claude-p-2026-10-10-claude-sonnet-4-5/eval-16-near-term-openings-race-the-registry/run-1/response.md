# LID Coach Review — Visit Planner

## Executive Summary

**Bootstrapping — design complete, pre-implementation.** The arrow's intent phases (HLD, LLDs, EARS) are in place and well-formed; tests and code have not been authored yet.

**Scorecard**
- ✓ Arrow structure — HLD, 2 LLDs, 15 specs properly organized
- ✓ Tenet quality — 4 well-formed tie-breakers with defensible opposites
- ✓ Tenet cascade — leaf designs lean consistently with HLD tenets
- ✓ Mutation hygiene — docs read as current intent, no history residue
- ✓ Scope disambiguation — WHEN clauses properly scope conditional behaviors
- ⚠ Decision capture — key numeric parameters lack rationale
- ⚠ Linkage consistency — spec prefix naming inconsistent across components

**The design documentation is complete and disciplined; the fastest value is in capturing rationale for the specific thresholds and time windows, and considering whether spec prefixes should match component names consistently.**

## Findings (3 total · 0 high · 1 medium · 2 low)

- **F1 (medium):** Fulfillment's 36-hour threshold, 2-hour offer window, and 20-minute scan delay lack captured rationale · *decision capture*
- **F2 (low):** Spec prefix inconsistency — INTAKE- uses full component name while FILL- abbreviates Fulfillment · *effective intent-tree alignment*
- **F3 (low):** "Exact retries" phrase in Intake LLD assumes reader knows this means matching idempotency key · *docs carry current intent, written to be read cold*

## What Was Audited

- **Read fully:** CLAUDE.md, docs/high-level-design.md, both LLDs (intake, fulfillment), both spec files
- **Enumerated:** 2 LLDs, 2 spec files, 15 total specs (7 INTAKE, 8 FILL)
- **Project phase:** Pure design — HLD, LLDs, and EARS complete; no tests or code present yet
- **Linkage metric:** 15 unique spec IDs across 2 components; 0 `@spec` references (no code authored)

## What's Working

The project demonstrates strong LID discipline in its design phase:

- **Tenet quality and cascade** — The HLD's four tenets are well-formed tie-breakers with defensible opposites, and the leaf designs consistently honor them: `enteredAt` ordering implements "first asked, first served"; eligibility rechecking at claim enforces "clinical fit precedes utilization"; transactional outbox delivers "commit before communicating"; append-only events enable "explain from durable facts."

- **Mutation hygiene** — All docs read as if authored fresh today. No "was X, now Y" narration, no `[obsolete]` markers, no conversational fossils.

- **HLD discipline** — The HLD stays at the architecture level (problem, approach, tenets, goals, components) without bleeding into implementation detail like schemas or API shapes.

- **Scope disambiguation** — Specs properly scope conditional behaviors in WHEN clauses (36-hour threshold, published openings, delayed scans).

- **Decisions tables** — Both LLDs carry properly structured four-column tables capturing chosen approaches and accepted costs.

## Offer to Help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.