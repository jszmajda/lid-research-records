## LID coach review

**Posture: Intent is in place; the arrow needs completion and a durability decision.**

**Scorecard**
- ✓ Design structure — two clearly named components with traceable spec prefixes
- ✓ HLD focus — concise architecture, goals, and tenets
- ⚠ Design coherence — restart behavior conflicts with the unattended-job promise
- ⚠ Specification coverage — some design behaviors and edge cases remain unpinned
- ✗ Tests and code — specs are marked implemented, but neither is present in the repository

The design and spec structure provide a strong starting point. The most valuable next step is to resolve what acceptance promises when the service restarts.

## Findings

- **F1 (high):** Accepted, undispatched jobs disappear on restart, undermining the upload-and-walk-away tenet during documented updates or power blips · *tenet cascade* — downstream design should honor the project’s stated preferences.
- **F2 (high):** The in-memory queue’s restart-loss tradeoff has no decision rationale, although a cold reader could reasonably question it · *decision capture* — preserve the reasoning behind choices that remain open to challenge.
- **F3 (high):** Both spec files mark requirements `[x]`, meaning implemented, although this repository contains no code or tests · *canonical arrow shape* — implementation status should reflect the full spec-to-test-to-code path.
- **F4 (high):** Queue acceptance and staff/member priority are described in the design but lack corresponding behavioral specs · *effective intent-tree alignment* — design behavior needs named requirements to be testable.
- **F5 (high):** Dispatch and recovery leave consequential cases open: an idle printer with an empty queue, priority selection, and what makes a suspect printer eligible again · *LLDs close enough of the solution space* — readers need enough detail to reach compatible implementations.
- **F6 (medium):** `QUEUE-002` calls for dispatch whenever an idle printer is reported without stating that an eligible job must exist · *scope disambiguation* — a spec should carry the conditions needed to interpret it on its own.
- **F7 (medium):** The 64 MB per-file limit is described as keeping disk safe, but retained uploads have no documented aggregate limit or cleanup behavior · *LLDs close enough of the solution space* — resource bounds need enough detail to support the stated rationale.

## What was audited

- Read `CLAUDE.md`, the HLD, both design documents, and both spec files in full.
- Reviewed two design segments and eight EARS requirements; checked the declared Full mode and spec status-marker convention.
- No code, tests, or arrow overlay are present to sample. The repository has one fixture commit, so tests-first history cannot be assessed.

Want me to walk through the findings in detail, focus on a theme or priority, or work through a specific item together?

I can also help with broader questions about using LID for this project.