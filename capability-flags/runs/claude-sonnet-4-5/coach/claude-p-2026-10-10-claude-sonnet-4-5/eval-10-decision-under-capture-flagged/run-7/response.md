# LID Coach Report

## Executive Summary

**Posture:** Bootstrapping — clean intent docs with a critical design contradiction.

**Scorecard**
- ✓ Configuration — properly declared Full mode with version
- ✓ Intent-tree alignment — spec IDs trace cleanly to LLD and HLD
- ✓ Mutation hygiene — docs are fresh with no accumulated history
- ✗ Design coherence — conflict resolution contradicts stated constraints
- ✗ Arrow completeness — specs marked implemented but Tests and Code phases missing
- ⚠ Decision capture — key tradeoffs under-documented

**Headline:** The LID structure is in place and properly configured; the most urgent issue is a design that uses wall-clock timestamps for conflict resolution despite stating that device clocks are frequently wrong by several minutes.

## Findings (5 total · 3 high · 2 medium)

- **F1 (high):** Sync conflict resolution contradicts stated constraints · *coherence is adjacency; tenets cascade*
- **F2 (high):** Specs marked `[x]` as implemented with no test or code files · *canonical arrow shape*
- **F3 (high):** Missing Tests and Code phases · *canonical arrow shape*
- **F4 (medium):** "Simpler" rationale doesn't capture what was given up or why the cost is acceptable · *decision capture*
- **F5 (medium):** Single tenet leaves most decisions without guidance · *tenets capture forward-looking preference*

## What Was Audited

- Read fully: CLAUDE.md, docs/high-level-design.md, docs/intent/sync/sync-design.md, docs/intent/sync/sync-specs.md
- Enumerated: 1 HLD, 1 LLD, 1 spec file, 2 specs
- Project structure: confirmed LID configuration (Full mode, version 1.4.0)
- Code/test sampling: none found (0 source files, 0 test files, 0 `@spec` annotations)

## Finding Details

**F1 - Design contradiction (high priority)**

The LLD Context states: "Field devices' clocks are frequently wrong by several minutes; they resync NTP only when connectivity returns." Yet the Conflict Handling section specifies: "the edit with the later device wall-clock timestamp wins."

This design cannot achieve the HLD's goal of "Convergent state after reconnect" — if clocks are wrong by minutes, last-writer-wins by wall-clock will produce incorrect ordering and non-convergent results. Two devices editing at nearly the same actual time could have timestamps minutes apart.

*Why it matters:* This contradiction means the design as documented won't work. Either the constraint is wrong (clocks are actually reliable), the design needs to change (use logical clocks, vector clocks, or server-assigned timestamps), or there's a mitigation not yet documented. A cold reader following this design would implement a broken conflict resolution system.

This also violates *tenets cascade* — the HLD tenet "Boring over clever" would suggest using a well-worn solution like CRDTs or server-assigned timestamps rather than device wall-clocks when clocks are unreliable.

**F2 & F3 - Arrow incompleteness and status incoherence (high priority)**

Both specs (SYNC-001, SYNC-002) are marked `[x]` indicating implementation, but the project contains no code files, no test files, and no `@spec` annotations. The arrow should be `HLD → LLD → EARS → Tests → Code`, but Tests and Code are absent.

*Why it matters:* Status markers communicate what's real versus planned. Marking specs as implemented when there's no code creates false confidence and breaks the arrow's coherence check. Either the specs should be `[ ]` (not yet implemented), or tests and code should exist.

The missing Tests phase also bypasses *tests before code* — when tests are written after code, they tend to verify what the code happens to do rather than what the spec requires, letting intent drift enter silently.

**F4 - Decision under-capture (medium priority)**

The Decisions table row "Last-writer-wins by device wall-clock" gives rationale "Simpler" without capturing what alternative was considered or why accepting unreliable clocks is acceptable.

*Why it matters:* A cold reader holding this row and the docs above it would question this choice — the Context section flags clock unreliability as a known constraint, yet the chosen design depends on clock accuracy. The row doesn't explain what was given up (what alternative was "simpler" than?) or document the reasoning for accepting the clock-accuracy cost.

Without this capture, future sessions can't tell if this is a deliberate tradeoff, an oversight, or a decision made before the clock constraint was discovered. The decision either needs fuller capture (naming the alternative, explaining why the simpler path is worth the reliability cost) or the design needs to change.

**F5 - Tenet sparseness (medium priority)**

The HLD has only one tenet ("Boring over clever"). While this is a well-formed tenet with a defensible opposite, a single tenet leaves many decision spaces unconstrained.

*Why it matters:* Tenets are tie-breakers for decisions no spec anticipated. With only one, most future choices won't have guidance — the agent samples from its own distribution rather than the user's preferences. Common second tenets in offline-first systems might address data loss ("never lose user input over sync conflicts"), UX responsiveness ("field experience over server complexity"), or operational concerns ("observable over opaque").

A project can function with one tenet, but 2-4 tenets typically guide more of the decision space and reduce intent drift in uncovered areas.

## Offer to Help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? F1 (the design contradiction) is the most urgent — I can help think through alternatives like logical clocks, server timestamps, or CRDTs if you'd like.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.