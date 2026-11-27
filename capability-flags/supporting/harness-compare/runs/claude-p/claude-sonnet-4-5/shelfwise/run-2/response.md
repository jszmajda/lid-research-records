# LID Coach Report — Shelfwise

## Executive Summary

**Posture:** Bootstrapping — intent layer complete, implementation layer absent.

**Scorecard**
- ✓ HLD discipline — architecture and rationale, no implementation detail
- ✓ Tenet quality — four real tie-breakers with defensible opposites
- ✓ Decision capture — clear tradeoffs in every Decisions table row
- ✓ LLD granularity — two components, two LLDs, both well-scoped
- ✓ Mutation hygiene — no accumulation, no residue
- ✓ Linkage structure — spec IDs are grep-friendly and align with LLDs
- ⚠ Configuration — mode marker present but missing LID directive block
- ✗ Arrow completeness — specs marked implemented but no tests or code exist

**Headline:** The intent layer is solid — clear HLD, well-specified LLDs, and 13 behavioral specs aligned to two components. The fastest wins are configuration reconciliation and clarifying spec implementation status.

## Findings (2 total · 2 high)

- **F1 (high):** CLAUDE.md missing LID directive block · *modes are declared, not inferred*
- **F2 (high):** All 13 specs marked [x] but no tests or code exist · *canonical arrow shape*

## What was audited

- Read fully: CLAUDE.md, docs/high-level-design.md, both LLDs (hold-allocation, pickup-notices), both spec files
- Enumerated: 2 LLDs, 2 spec files, 13 EARS specs, 4 tenets, 7 decision rows
- Linkage: 2 spec-ID prefixes (HOLDALLOC, PICKUP), both resolving to leaf LLDs
- Code/test sampling: none found (0 source files, 0 test files, 0 `@spec` annotations)
- Arrow-maintenance overlay: not installed (docs/arrows/ absent)

## Detailed Findings

**F1 — High. CLAUDE.md has the mode marker but is missing the LID directive block.** The file carries `## LID` with `- Mode: Full`, but `grep` finds no occurrence of "linked-intent-dev" or "Linked-Intent Development." Under *modes are declared, not inferred* — and more broadly, under the principle that the instruction file carries the directives agents use to dispatch LID workflows — this gap means the harness doesn't know this is a LID-configured project. Skills like `/linked-intent-dev` won't auto-trigger on relevant prompts, cascade behaviors won't fire, and future sessions won't load the LID context they need. The fix is mechanical: run `/update-lid` to reconcile the instruction file. That skill state-dispatches: it will detect the existing LID structure (mode marker + docs/) and add the missing directive block without disrupting what's already in place.

**F2 — High. All 13 specs are marked [x] as implemented, but the project contains no test files and no code files.** Every spec in `hold-allocation-specs.md` and `pickup-notices-specs.md` carries the `[x]` checkbox, signaling "this behavior is implemented." The project directory has 6 files total — CLAUDE.md and 5 docs/ files — and zero source or test files of any kind. Under *canonical arrow shape* — `HLD → LLDs → EARS → Tests → Code` — the arrow has its first three phases and stops. The consequence depends on intent: if these specs describe behaviors you plan to implement, the `[x]` markers are misleading — they tell future sessions the work is done when it hasn't started, and an agent asked to "add a new hold constraint" will try to edit code that doesn't exist. If the tests and code do exist but live elsewhere (a separate repo, a parent directory outside this project root), the arrow is structurally broken — an agent can't walk from spec to test to code because the path doesn't resolve within the project. If this is a greenfield project and implementation hasn't started, change every `[x]` to `[ ]` so the spec status reflects reality. If code exists elsewhere, either bring it into this tree or document the split in CLAUDE.md so agents know where to look. If this is a specification-only deliverable (no implementation planned), that's legitimate — but then the [x] markers should still be `[ ]`, since "implemented" in LID means tests pass and code exists, not "the spec is written."

## Offer to help

Want me to walk through these findings in more detail, or work through how to address them? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.