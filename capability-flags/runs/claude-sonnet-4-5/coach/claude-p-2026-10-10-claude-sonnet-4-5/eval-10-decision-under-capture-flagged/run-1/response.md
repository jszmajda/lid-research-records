Now I'll perform a complete review of this project's LID usage.

---

# LID Coach Report

## Executive Summary

**Posture:** Bootstrapping — arrow foundation is clean, Tests and Code phases not yet built.

**Scorecard**
- ✓ Configuration — properly declared Full mode with standard directory structure
- ✓ Linkage hygiene — spec IDs align with LLD prefix, proper frontmatter
- ✓ Mutation discipline — docs carry current intent, no residue
- ✗ Arrow completeness — HLD → LLD → EARS present; Tests and Code phases missing
- ✗ Design coherence — conflict resolution contradicts stated constraints
- ⚠ Decision capture — critical choice under-documented

**Headline:** The intent layer is cleanly structured with good linkage discipline; the highest-value work is addressing the clock-based conflict resolution (which contradicts your own Context) and building out the arrow's downstream phases.

## Findings (5 total · 3 high · 1 medium · 1 low)

- **F1 (high):** Arrow incomplete — Tests and Code phases missing · *canonical arrow shape*
- **F2 (high):** Tenet conflict — sync design uses device wall-clock for conflict resolution when Context states clocks are "frequently wrong by several minutes" · *tenet cascade*
- **F3 (high):** Decision under-captured — conflict resolution rationale is "Simpler." without explaining the alternative considered or why unreliable clocks are acceptable · *decision capture*
- **F4 (medium):** LLD under-specified — conflict handling describes behavior but leaves edit format, metadata, and merge mechanics unspecified · *LLDs close enough of the solution space*
- **F5 (low):** Single tenet — HLD carries one tenet; additional tie-breakers could strengthen future design choices · *tenets capture forward-looking preference*

## What Was Audited

- Read fully: CLAUDE.md, docs/high-level-design.md, docs/intent/sync/sync-design.md, docs/intent/sync/sync-specs.md
- Enumerated: 1 HLD, 1 LLD, 1 spec file, 2 specs (SYNC-001, SYNC-002)
- Arrow coverage: HLD → LLD → EARS verified for the sync component
- Tests and code: none present (arrow terminates at EARS layer)
- Verified: no arrows overlay, no code files, no test files

## Detail on Key Findings

### F2: Tenet conflict (high priority)

Your HLD's tenet says "Boring over clever. Prefer well-worn solutions to novel ones unless the novel one is decisively better."

The sync LLD's Context explicitly states: "Field devices' clocks are frequently wrong by several minutes; they resync NTP only when connectivity returns."

Yet the Conflict handling section chooses: "When two devices edited the same note while offline, the edit with the later device wall-clock timestamp wins."

**Why this matters:** Using timestamps from clocks known to be wrong produces arbitrary conflict resolution — the "later" edit may actually be earlier. This contradicts the tenet's preference for working solutions. The mechanism undermines the stated goal "Convergent state after reconnect" when clock skew makes convergence unpredictable.

A cold reader holding your Context and your tenet would question why wall-clock is the basis when you've documented it as unreliable.

### F3: Decision capture (high priority)

The Decisions & Alternatives table entry for conflict resolution:

| Decision | Chosen | Rationale |
|---|---|---|
| Conflict resolution | Last-writer-wins by device wall-clock | Simpler. |

**Why this matters:** The rationale "Simpler." doesn't capture what was traded off or why accepting unreliable clocks is acceptable. A future reader (or agent) can't reconstruct:
- Simpler than what alternative? (Vector clocks? Server-assigned sequence? Merge?)
- What cost was accepted by choosing wall-clock despite documented unreliability?
- Under what conditions is this acceptable vs. problematic?

This is a foundational design choice that shapes all conflict behavior, yet the reasoning exists only in the conversation that produced it (if anywhere). When implementation begins or a variant is added, this gap becomes an intent-drift entry point.

### F1: Arrow completeness (high priority)

The arrow stops at EARS (specs). No tests cite the specs; no code implements them.

**Why this matters:** The Tests and Code phases are where coherence gets tested. Without them, the specs are untested intent — you can't verify they're implementable, unambiguous, or complete. The missing phases are the normal next step for a project at this stage, not drift — flag this as "work ahead" rather than a quality issue.

### F4: LLD under-specified (medium priority)

The sync LLD's Conflict handling and Architecture sections describe the flow ("device uploads pending edits", "sync service merges") but leave solution edges open:
- What's the structure of a "pending edit"? (timestamp? edit type? note ID?)
- What does "merge" mean mechanically given last-writer-wins?
- How does the service determine which edit is "later" if clocks are wrong?

**Why this matters:** Two agents reading this LLD could land on incompatible implementations — one might use device-supplied timestamps, another might assign server-side receive order. Under-specified LLDs are where implementation drift enters quietly.

The line between "enough" and "too much" is: would two reasonable readers converge on compatible implementations? Here, the timestamp reliability question pulls that into focus.

### F5: Single tenet (low priority)

The HLD has one tenet. It's a good one — defensible opposite, clear lean — but additional tenets could provide tie-breaking guidance for future choices (e.g., when to favor simplicity vs. correctness, user control vs. automation).

**Why this matters:** Tenets answer the decisions no spec anticipated. One tenet is fine for a focused project; as the system grows, more tenets reduce the solution space agents sample from when making unspecified choices.

## Want Me to Help?

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.