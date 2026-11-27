# LID Coach: Field Notes

## Executive summary

**Posture:** Bootstrapping — design tree in place and well linked, downstream phases not started, and one live decision under-captured.

**Scorecard**
- ✓ Configuration and mode fit — directives and `Mode: Full` are declared, and the standard directories are present.
- ✓ Linkage — the `SYNC` prefix resolves to its LLD, IDs are unique, and the HLD, LLD and specs agree with each other.
- ✓ Mutation hygiene — the docs read as current intent, with no history residue or obsolete markers.
- ⚠ Decision capture — the conflict-resolution choice is recorded, but its reasoning is not.
- ⚠ LLD sufficiency — the sync design leaves several edges open, and the device-local store has no design node.
- ✗ Arrow completeness — both specs are marked `[x]`, but the repository has no tests or code.

**Headline:** The top of the arrow is clean and coherent: the HLD has a real tie-breaker tenet and explicit non-goals, and the LLD and EARS specs match line for line. The most valuable next step is to revisit the last-writer-wins row in `sync-design.md`, both what it says and whether the choice survives the clock skew the same doc describes.

## Findings (6 total · 3 high · 2 medium · 1 low)

- **F1 (high):** The conflict-resolution row's whole rationale is "Simpler." It does not say what was given up (merge, server-ordered or vector-clock approaches, keeping the losing edit) or why silently discarding a technician's edit is an acceptable cost · *docs carry current intent, written to be read cold* (a decision a cold reader would still question needs its trade-off on the page).
- **F2 (high):** The sync LLD's own Context says device clocks are "frequently wrong by several minutes", yet the winner is picked by device wall-clock (`sync-design.md` line 17, SYNC-002). Under that condition the edit that is kept may not be the later one. This is a design concern separate from F1, and it is what makes F1 live · *LLDs close enough of the solution space* (a design should be specific enough, and sound enough, that agents don't have to guess or patch around it).
- **F3 (high):** SYNC-001 and SYNC-002 are marked `[x]`, but no tests or code exist, so there are no `@spec` annotations to walk to. Consider resetting the markers, or landing tests first and then code · *canonical arrow shape* (HLD → LLDs → EARS → Tests → Code, each phase present) and *tests before code* (tests are the first consumer of a spec).
- **F4 (medium):** The device-local store is an HLD architecture element and carries the goal "No blocked capture in the field", but it has no LLD and no specs. Its only trace is a "SQLite on device" row inside the sync LLD · *one LLD per intent component* (each "thing" a user would name gets its own design node) and *effective intent-tree alignment* (HLD concepts trace down to specs).
- **F5 (medium):** The sync LLD leaves edges open that two agents would close differently: what a "pending edit" is (whole note or field), equal timestamps, deletes, a failed or partial upload, and whether the technician learns their edit was discarded · *LLDs close enough of the solution space* (open edges are where intent drift enters).
- **F6 (low):** The HLD is thin on rationale. Architecture is a single line, and there are no target users, key design decisions or success metrics, so "convergent state" has no measurable meaning yet · *HLD is architecture and rationale* (the HLD carries the long-lived *why*).

No tenet-cascade conflict was found: last-writer-wins leans the way "Boring over clever" says to lean, and it is deterministic, so it does converge. The concern in F2 is about which edit wins, not about convergence.

## What was audited

- **Read fully:** `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`. That is every tracked file in the repository.
- **Enumerated:** 1 HLD, 1 LLD, 1 spec file with 2 EARS specs, and 2 Decisions & Alternatives rows. There are 0 test files, 0 code files and 0 `@spec` references.
- **Passes run:** dimension review, a cold-read pass over all three LID docs, and a Decisions-table sweep. The SQLite row passes the sweep; the conflict-resolution row is F1.
- **Not present:** the arrow overlay (`docs/arrows/`), so no structural audit applies.
- **Dispatch:** the project is fully configured, so this was a full review. This was a non-interactive run; no dispatch question arose and no defaults had to be taken.
- **Git history:** a single commit, so there is no ordering evidence for tests versus code or for cascade timing.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into; F1 and F2 are best taken together.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.