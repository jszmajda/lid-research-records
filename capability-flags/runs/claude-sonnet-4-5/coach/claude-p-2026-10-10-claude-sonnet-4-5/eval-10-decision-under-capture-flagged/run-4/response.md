# LID Coach Report

## Executive summary

**Posture:** Bootstrapping — arrow structure in place, intent layer complete, implementation phases not yet started.

**Scorecard**
- ✓ Configuration — Full mode declared, standard directories present
- ✓ Mutation hygiene — docs are clean, no accumulated residue
- ✓ Linkage structure — spec IDs follow EARS conventions
- ⚠ Decision capture — rationale exists but leaves critical tradeoffs implicit
- ⚠ LLD sufficiency — edges of the solution space left open
- ✗ Arrow completeness — Tests and Code phases absent

**Headline:** The intent layer is in place with clean structure and no accumulation drift; the most valuable next step is addressing the clock-accuracy contradiction in the sync design before moving to implementation.

## Findings inventory

**Findings (6 total · 2 high · 3 medium · 1 low)**

- **F1 (high):** Sync conflict resolution relies on device wall-clock timestamps, but the LLD's Context section states clocks are "frequently wrong by several minutes" — the design contradicts itself · *LLD sufficiency; decision capture*
- **F2 (high):** Tests and Code phases absent from the arrow · *arrow completeness*
- **F3 (medium):** Conflict resolution decision rationale ("Simpler") doesn't explain what was traded — a cold reader holding the clock-accuracy constraint would question this choice · *decision capture*
- **F4 (medium):** LLD leaves solution edges open: upload format/protocol unspecified, merge algorithm unspecified · *LLDs close enough of the solution space*
- **F5 (medium):** HLD is minimal on architecture — "Device-local store, sync service, reconciliation on the sync path" names components but doesn't explain their relationships or boundaries · *HLD is architecture and rationale*
- **F6 (low):** Only one tenet present — consider whether additional tie-breakers would help guide future decisions · *tenet quality*

## What was audited

- Read fully: CLAUDE.md, docs/high-level-design.md, docs/intent/sync/sync-design.md, docs/intent/sync/sync-specs.md
- Enumerated: 1 HLD, 1 LLD, 1 spec file with 2 EARS specs
- Arrow phases present: HLD → LLD → EARS (3 of 5 canonical phases)
- No arrow overlay detected
- No code or test files present

## Detail on F1 (the design contradiction)

The sync LLD establishes in its Context section that "Field devices' clocks are frequently wrong by several minutes; they resync NTP only when connectivity returns." But the Conflict handling section chooses "the edit with the later device wall-clock timestamp wins."

This is a correctness issue: if Device A's clock is 5 minutes fast and Device B's clock is accurate, an edit made on Device B at 14:00 could lose to an edit made on Device A at 13:59 actual time (but timestamped 14:04 by A's fast clock). The "later" edit by wall-clock isn't the later edit in real time.

A cold reader encountering this would either assume the clock-accuracy statement is outdated (and the clocks are actually reliable now), or would expect the Decisions & Alternatives table to acknowledge the tradeoff — why accept known-incorrect ordering in exchange for simplicity, and what failure modes does that create?

The Decisions table currently says only "Simpler" as rationale. That doesn't answer: simpler than what alternative? And does "simpler" mean the implementation is easier, or that explaining it to field staff is easier, or that reasoning about failure modes is easier? A future session revisiting this design won't know whether the clock issue was forgotten, accepted as low-impact, or whether conflict resolution is expected to be rare enough that occasional mis-ordering is tolerable.

Worth capturing: what alternatives were considered (server-assigned sequence numbers? vector clocks? accept-all-and-show-conflicts-to-user?), and why the known mis-ordering was acceptable.

## Next steps to consider

The design contradiction (F1) is the highest-value item to resolve before implementation begins. Once that's settled, the arrow can grow its downstream phases — tests that exercise SYNC-001 and SYNC-002, then code that makes those tests pass.

For the minimal HLD (F5), consider whether a sentence or two explaining the sync service's role (does it just store? does it broker between devices? does it have its own reconciliation logic beyond what the LLD describes?) would help a future session understand the system's boundaries. The current HLD reads more like a summary than architecture.

The open solution edges in the LLD (F4) can mature as implementation starts — the question is whether they're deliberate flexibility ("any reasonable upload protocol works") or just not-yet-specified. If the former, the LLD could say so; if the latter, tightening before tests are written helps the tests exercise the actual intended behavior rather than one plausible guess.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.