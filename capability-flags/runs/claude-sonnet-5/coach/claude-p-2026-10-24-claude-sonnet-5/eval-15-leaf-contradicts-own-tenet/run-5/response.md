# Shelfwise — LID Coach Report

## Executive summary

**Posture: Bootstrapping, with one tenet/mechanism conflict to resolve.** The design layer is disciplined and the arrow hasn't been walked into tests and code yet.

**Scorecard**
- ✓ HLD discipline — architecture and rationale only; no schemas or request shapes crept upstream
- ✓ LLD granularity — hold-allocation and pickup-notices are cleanly separated, no overlapping scope
- ✓ Decision capture — most tradeoffs are tabled with real alternatives and costs, several tied explicitly back to the HLD's goals
- ⚠ Tenet cascade — one allocation mechanism works against a stated tenet under a describable condition, and the tradeoff isn't recorded anywhere
- ✗ Arrow completeness — all 13 EARS specs are checked off `[x]` as done, but no tests or code exist anywhere in the repo to back that up
- ⚠ Configuration — the instruction file's `## LID` block never actually states the project uses linked-intent-dev

**Headline:** the HLD and both LLDs show real discipline — tight tenets, specs with correctly scoped WHEN clauses, and decision tables that already link costs back to the stated goals (the expiry-handling row is a good example). The most valuable next step is resolving the branch-priority allocation mechanism against the "waiting is honored in sequence" tenet before code gets written against it — right now a locally-waiting patron can receive a copy ahead of a longer-waiting patron at another branch, and that tradeoff isn't on the record anywhere.

## Findings (5 total · 2 high · 2 medium · 1 low)

- **F1 (high):** Branch-priority allocation (serving the oldest *local* hold before checking county-wide) can hand a copy to a patron who asked *after* a still-waiting patron at another branch — directly against the tenet *"Waiting is honored in sequence... nobody's wait is lengthened by a patron who asked after them."* No Decisions & Alternatives row names this exception. · *tenets capture forward-looking preference* / *docs carry current intent*
- **F2 (high):** 7 of 7 `HOLDALLOC-*` and 6 of 6 `PICKUP-*` specs are marked `[x]` complete, but the repo contains no test files and no implementation code anywhere — there's nothing to check that status against. · *tests before code* / *coherence is adjacency*
- **F3 (medium):** The branch-priority-vs-county-wide-pool choice itself (hold-allocation-design.md, "This keeps most copies off the courier van...") lives only in Design prose, not in the Decisions & Alternatives table, even though it has a real alternative (always serve the oldest hold county-wide) and a real cost (the F1 sequencing tradeoff). · *docs carry current intent — decision capture*
- **F4 (medium):** HOLDALLOC-007's choice to re-run allocation at the *arrival* branch when an in-transit hold is cancelled (rather than returning the copy to its origin branch) has a real alternative and isn't captured in the Decisions & Alternatives table. · *docs carry current intent — decision capture*
- **F5 (low):** CLAUDE.md's `## LID` block declares `Mode: Full` and `Version: 1.4.0` but never states that the project uses linked-intent-dev / LID — a cold reader can't confirm what methodology the block is declaring for. Consider `/update-lid` to add the directive text. · *modes are declared, not inferred*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/hold-allocation/*`, `docs/intent/pickup-notices/*`
- Enumerated: 2 components (2 LLDs, 2 spec files), 13 EARS specs (7 HOLDALLOC + 6 PICKUP), 0 test files, 0 code files
- No `docs/arrows/index.yaml` overlay present
- Git history is a single commit ("fixture"), so no cascade timeline was available to sample

## Offer to help

Want me to walk through any of these findings in more detail, focus on the tenet-cascade conflict first, or work through the decision-capture gaps together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — when to add a sub-HLD, how EARS prefixes should extend as components grow, or how to sequence the move from design-only to tests-and-code — I can help with those too.