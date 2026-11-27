# LID Coach Report

## Executive Summary

**Posture:** Bootstrapping — arrow structure in place, one component specified, no implementation yet.

**Scorecard**
- ✓ Configuration — Full mode declared, standard structure in place
- ✓ Arrow structure — HLD + LLD + EARS present for sync component
- ✓ Linkage hygiene — spec IDs follow conventions (no code to check yet)
- ⚠ Design coherence — conflict resolution contradicts stated constraints
- ⚠ Decision capture — sparse rationales leave key trade-offs unexplained
- ✗ Implementation — tests and code phases not yet started

**Headline:** The arrow structure is correctly established with clean LID configuration; the most valuable next step is resolving the design contradiction in conflict resolution before implementation begins.

## Findings (5 total · 2 high · 2 medium · 1 low)

- **F1 (high):** Sync conflict resolution contradicts its own constraints · *docs carry current intent, written to be read cold*
- **F2 (high):** Conflict resolution decision under-captured · *decision capture*
- **F3 (medium):** Tests and code phases missing · *canonical arrow shape*
- **F4 (medium):** Note storage decision rationale too terse · *decision capture*
- **F5 (low):** HLD Architecture section sparse · *HLD is architecture and rationale*

## What Was Audited

- Read fully: CLAUDE.md, docs/high-level-design.md, docs/intent/sync/sync-design.md, docs/intent/sync/sync-specs.md
- Enumerated: 1 LLD, 1 spec file (2 EARS specs: SYNC-001, SYNC-002)
- Arrow-path coverage: 1 segment reviewed (HLD → sync LLD → sync specs)
- Linkage metric: 0 `@spec` references (no implementation yet)
- Code/test sampling: none (no code or tests present)

## Details

### F1 (high): Design contradiction in conflict resolution

The sync LLD's Context states: "Field devices' clocks are frequently wrong by several minutes; they resync NTP only when connectivity returns."

Yet the Conflict handling section chooses: "the edit with the later device wall-clock timestamp wins."

A cold reader sees the constraint (unreliable clocks) immediately followed by a solution that depends on reliable clocks. The design contradicts itself. Either:
- The clock skew is tolerable for this conflict strategy (in which case the Context overstates the problem), or
- The conflict strategy needs a different approach (sequence numbers, vector clocks, or explicit merge), or  
- There's a hidden reason this works despite the clocks (e.g., "wrong by minutes" is acceptable for conflict resolution at day+ granularity)

The current state leaves future sessions unable to tell whether this is a known trade-off or an oversight.

*Principle: docs carry current intent, written to be read cold* — a fresh author knowing the current design wouldn't write both statements without reconciling them.

### F2 (high): Conflict resolution decision under-captured  

The Decisions & Alternatives table has this row:

| Decision | Chosen | Rationale |
|---|---|---|
| Conflict resolution | Last-writer-wins by device wall-clock | Simpler. |

A cold reader holding this design and the stated clock-skew constraint would question this choice and be tempted to reverse it. The row doesn't explain:
- What was given up (correctness? user intent preservation?)
- What constraint made "simpler" win over alternatives
- Whether alternatives were even considered (sequence numbers, CRDTs, manual merge)

The rationale captures that the choice favored simplicity but not what cost was accepted or why that trade was sound.

*Principle: decision capture* — decisions that would still be questioned by a cold reader need enough record that the reasoning can be reconstructed.

### F3 (medium): Tests and code phases missing

The arrow has HLD → LLD → EARS but stops there. No tests exercise the specs; no code implements them.

This is expected for a bootstrapping project, but it means the arrow isn't yet walkable end-to-end. SYNC-001 and SYNC-002 are both marked `[x]` (completed), but without tests or code, that status may be premature.

*Principle: canonical arrow shape* — the full arrow is `HLD → LLDs → EARS → Tests → Code`.

### F4 (medium): Note storage decision rationale terse

The row:

| Decision | Chosen | Rationale |
|---|---|---|
| Note storage | SQLite on device | Standard embedded store. |

"Standard embedded store" explains the category of the choice but not what was considered or ruled out (Realm? file-per-note? custom format?). For a decision that shapes data durability in an offline-first system, a cold reader might want to know what constraints led here.

This one is borderline — SQLite is such a common choice that the rationale may be sufficient — but in a system where sync correctness matters, the storage decision carries downstream obligations (transaction boundaries, schema migration strategy) that aren't visible from this row.

*Principle: decision capture* — if a future reader would question the choice, the reasoning should be recoverable.

### F5 (low): HLD Architecture section sparse

The current Architecture section reads: "Device-local store, sync service, reconciliation on the sync path."

This names the components but doesn't explain their boundaries, responsibilities, or how they interact. A slightly fuller treatment — even one more sentence per component — would give future LLDs clearer attachment points and help a cold reader understand the system's shape before dropping into a leaf design.

*Principle: HLD is architecture and rationale* — the HLD carries *why* and the structure that lives longer than implementation.

## Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.