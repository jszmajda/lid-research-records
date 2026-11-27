# LID Coach — Shelfwise

## Executive summary

**Posture:** Healthy design-stage arrow — clean, cold-readable docs and strong decision tables; one tenet quietly traded without a record, and implementation not yet begun.

**Scorecard**
- ✓ LLD granularity — one LLD per intent component; the two leaves match the HLD's two components exactly
- ✓ HLD discipline — architecture and rationale only, no schema or signature bleed
- ✓ Mutation hygiene — docs read present-tense and cold, no history residue or obsolete markers
- ⚠ Tenet cascade — branch-local allocation runs against the *waiting is honored in sequence* tenet
- ⚠ Decision capture — rich tables, but the branch-priority trade-off has no row
- ⚠ Configuration — the instruction file carries a `## LID` mode block but no linked-intent-dev directive block
- ⚠ Downstream arrow — specs authored; Tests and Code phases not yet present (bootstrapping)

**Headline:** The arrow is real and coherent from HLD through two well-scoped spec files, the decision tables are genuinely strong, and the docs stand on their own cold — the single most valuable next step is to record (and confirm) one allocation choice that currently trades against a tenet with no note on the page.

## Findings (7 total · 3 high · 2 medium · 2 low)

- **F1 (high):** Branch-local allocation lets a later requester at the scanning branch take a copy ahead of an earlier county-wide requester, which runs against the tenet *waiting is honored in sequence* — "nobody's wait is lengthened by a patron who asked after them" (`hold-allocation-design.md:11`, HOLDALLOC-003/004). No Decisions row records this as a deliberate exception · *tenet cascade — design nodes should lean the way the HLD's tenets say to lean; when a mechanism defeats a tenet under a describable condition, the exception gets recorded*
- **F2 (high):** That branch-priority choice is the most load-bearing decision in the allocation design, yet it lives only in prose — and the prose justifies it by courier-van cost, never naming the sequence trade-off a cold reader would immediately question · *decision capture — docs carry current intent; a live decision a reader would still question needs a row showing what was given up*
- **F3 (high):** `CLAUDE.md` has the `## LID` block (Mode: Full, Version 1.4.0) but no linked-intent-dev directive block, so the methodology the project clearly follows isn't declared in its instruction file · *modes are declared, not inferred* → run `/update-lid` to reconcile
- **F4 (medium):** Every spec is marked `[x]` with no legend, while no tests or code exist — a cold reader can't tell whether `[x]` means authored, accepted, or implemented, and it reads as "done" against an unbuilt system · *coherence is adjacency — each level should agree with the next*
- **F5 (medium):** The arrow currently terminates at specs; Tests and Code phases aren't present yet. This is bootstrapping, not drift — but it means the tests-first discipline is still ahead of you · *tests before code — the test is the first consumer of the behavior, so lead with tests citing these spec IDs when you build*
- **F6 (low):** The HLD has no Non-goals section; the *hold history is not kept* tenet already implies non-goals (reading history, recommendations) worth stating explicitly to bound scope · *HLD is architecture and rationale*
- **F7 (low):** The hold-cap row justifies capping but not the specific value 15; a cold reader might ask "why 15?" · *decision capture*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 13 EARS specs (HOLDALLOC-001–007, PICKUP-001–006)
- Cold-read pass: all five LID docs read standalone; decisions-table sweep across all 6 Decisions & Alternatives rows
- No arrow overlay (`docs/arrows/` absent), no code or test files present — linkage and tests-first dimensions assessed against design intent only
- Dispatch: instruction file has the mode marker but no LID directive block; LID-shaped artifacts present, so this ran as a full review in default Full mode (no `## LID Scope`, so no scope question arose)

## Offer to help

Want me to walk through any of these in detail, focus on a theme or priority, or work through specific items together? F1 and F2 are the same allocation choice seen from two angles and are worth unpacking first — I can help you draft the Decisions row and decide whether branch priority is the intent you want to keep.

If you have broader questions about using LID for Shelfwise — when to split a component into a sub-HLD, how status markers should work before code exists, or when to move off Full mode — I can help with those too.