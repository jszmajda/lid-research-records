# LID Coach Review — printfarm

## Executive Summary

**Posture:** Bootstrapping — arrow structure solid, awaiting implementation.

**Scorecard**
- ✓ Configuration — Mode: Full declared, standard directories in place
- ✓ HLD discipline — architecture-level with no implementation detail bleeding in
- ✓ Linkage structure — spec IDs follow conventions, grep-friendly
- ✓ LLD granularity — two components appropriately scoped
- ⚠ Decision capture — tenet-mechanism conflict not recorded
- ⚠ Mutation hygiene — one cold-read gap where reasoning is implicit

**Headline:** The design foundation is clean and well-structured for a two-component system; the most valuable next step is capturing the restart/promise tradeoff that currently sits implicit, and then moving into tests-first implementation.

## Findings (6 total · 2 high · 3 medium · 1 low)

- **F1 (high):** Tenet-mechanism conflict not captured — the HLD tenet "A submitted job is a promise" conflicts with the job-queue architecture that drops undelivered jobs on restart; no Decisions row explains which tenet was traded and why · *decision capture*
- **F2 (high):** Arrow incomplete — Tests and Code phases absent (expected in bootstrapping, but blocks arrow walkability) · *arrow completeness*
- **F3 (medium):** Spec status markers informal — using markdown checkboxes `[x]` rather than formal EARS status markers · *linkage hygiene*
- **F4 (medium):** Decision table includes parameters — entries like "Upload size limit: 64 MB" and "Heartbeat interval: 15 s" are parameter choices, not design alternatives · *decision capture*
- **F5 (medium):** Circular decision rationale — printer-registry heartbeat decision says "fast enough... slow enough" without naming what was traded · *decision capture*
- **F6 (low):** Spec file LLD pointers informal — using bold text rather than frontmatter to link back to parent LLD · *linkage hygiene*

## What Was Audited

- Read fully: CLAUDE.md, docs/high-level-design.md, all 2 LLDs, all 2 spec files
- Enumerated: 2 LLDs, 2 spec files, 8 EARS specs (5 QUEUE, 3 REG)
- Code/test sampling: none present (pre-implementation phase)
- Arrow overlay: not installed

## Detail on F1 — The Restart/Promise Conflict

A cold reader seeing "A submitted job is a promise: members should be able to upload and walk away" in the HLD, then reading that "jobs that were accepted but not yet dispatched before a restart are gone" in the job-queue LLD, would question whether this design honors its own tenet. The implicit reasoning — that restarts are rare (just OS updates and power blips), and persistent queue state would conflict with the "stays small" tenet and in-memory architecture — never appears on the page. This is exactly the kind of tenet tradeoff that belongs in a Decisions & Alternatives row: name the tenet being traded against, the operating condition where the conflict surfaces, and why the cost was accepted.

The fact that G-code files are kept on disk makes the conflict sharper: files persist, but queue state doesn't, which looks inconsistent without the design rationale.

## Offer to Help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.