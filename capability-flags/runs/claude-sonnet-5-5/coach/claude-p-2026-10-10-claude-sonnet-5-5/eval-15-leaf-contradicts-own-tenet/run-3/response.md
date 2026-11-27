**Shelfwise LID coach report**

## Executive summary

**Posture:** Solid, well-kept docs with one tenet-vs-design tension and a missing downstream half of the arrow.

**Scorecard**
- ✓ Doc hygiene: current-intent prose, no change-narration, no `[obsolete]` residue
- ✓ Spec quality: EARS-shaped, uniquely numbered, prefixes match their LLDs
- ✓ Decisions tables: most rows name the rejected option and the accepted cost
- ✓ Mode fit: Full mode matches a two-component project
- ⚠ Tenet cascade: one allocation rule pulls against the first tenet
- ⚠ Configuration: the instruction file declares a mode but carries no LID directives
- ⚠ Arrow completeness: no tests or code are visible below the specs

**Headline:** The HLD, both LLDs and the specs are concise and agree with each other, and the Decisions rows (especially the expiry one, which owns its cost against Goal 1) are unusually honest. The most valuable next step is to reconcile "oldest hold wins" with the branch-first allocation rule.

## Findings (5 total · 2 high · 2 medium · 1 low)

- **F1 (high):** Branch-first allocation (HOLDALLOC-003/004/007) can hand a copy to a later asker at the scanning branch ahead of an older county-wide hold, which cuts against the first tenet · *intent attaches at the lowest node that dominates it; tenets capture forward-looking preference* (a tenet is a tie-breaker leaves should lean with)
- **F2 (high):** `CLAUDE.md` has a `## LID` block with mode and version but no LID directives (no `linked-intent-dev` reference) · *modes are declared, not inferred*. Run `/update-lid` to reconcile.
- **F3 (medium):** The branch-first choice appears only in design prose, with no Decisions row naming the rejected option (strict county-wide sequence) and the accepted cost · *docs carry current intent, written to be read cold* (decision capture)
- **F4 (medium):** All 13 specs are marked `[x]`, but the project contains no tests or code carrying `@spec` annotations, so the arrow can't be walked past the specs · *canonical arrow shape; tests carry `@spec` annotations*
- **F5 (low):** Hold cancellation is described in the design and relied on by HOLDALLOC-007, but no spec covers the cancel action itself, including cancelling while the copy sits on the holds shelf · *coherence is adjacency*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 13 specs (7 HOLDALLOC, 6 PICKUP)
- No arrow overlay (`docs/arrows/`) present, so no structural audit was applicable
- Code and tests: none found in the repository to sample

## Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.