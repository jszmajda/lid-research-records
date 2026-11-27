**lid-coach — printfarm review**

## Executive summary

**Posture:** Bootstrapping — intent layer is in place and well-shaped, but the arrow stops at specs.

**Scorecard**
- ✓ HLD discipline — architecture and rationale only; real tenets with defensible opposites; no implementation bleed
- ✓ LLD granularity — one node per component, right-sized; Decisions & Alternatives tables are genuinely filled in
- ✓ Alignment — `QUEUE` and `REG` prefixes resolve cleanly to the two design nodes
- ⚠ LLD sufficiency — a couple of solution edges left open (see F4)
- ✗ Arrow completeness — tests and code phases don't exist yet
- ⚠ Cascade health — every spec is marked `[x]` with nothing downstream to back it

**Headline:** The intent layer is a strong start — clean HLD, two focused LLDs with real decision capture — and the most valuable next step is walking the arrow forward: tests and code behind the eight specs, at which point the `[x]` markers stop being claims.

## Findings (5 total · 2 high · 2 medium · 1 low)

- **F1 (high):** All 8 specs are marked `[x]` complete, but the repo contains no tests and no code — docs only. Per *tests before code* (tests preload the use of the system before implementation exists) and *intent leads; code is compiled output*, either the markers are premature or the arrow's downstream phases were skipped. Consider moving to `[ ]` until a test exercises each spec.
- **F2 (high):** Design behaviors with no specs — job acceptance requires "target class has at least one registered printer" (job-queue-design.md:20), and uploaded files are stored under a content hash with 64 MB files on disk (job-queue-design.md:14), yet no EARS covers either. Per *effective intent-tree alignment*, LLD behaviors with no specs are unnamed intent that drifts silently.
- **F3 (medium):** Tenet tension, unrecorded — the restart story ("jobs not yet dispatched before a restart are gone, and members resubmit them", job-queue-design.md:14) works against the tenet "A submitted job is a promise: members should be able to upload and walk away" under exactly the power-blip condition the Context section describes. Per *tenets capture forward-looking preference* / cascade: either record the accepted trade in a Decisions row, or revise the mechanism.
- **F4 (medium):** Open edge in the dispatch story — on failure the printer is "marked suspect" (job-queue-design.md:21), but nothing specifies how a suspect printer is cleared (does it re-enter dispatch after a probe? on registry idle?). Per *LLDs close enough of the solution space*, two agents reading this would land on different implementations.
- **F5 (low):** HLD has Tenets, Goals, and Non-Goals but no success metrics — "evening upload, morning pickup" is quantifiable (upload latency, unattended-print success rate) and would sharpen tenet-cascade checks later.

## What was audited

- Read fully: `CLAUDE.md` (Full mode, directives present), `docs/high-level-design.md`, both LLDs, both spec files — the complete LID doc set.
- No code or test files exist to sample; no `docs/arrows/` overlay installed.
- Counts: 2 LLDs, 2 spec files, 8 specs (5 QUEUE, 3 REG), 5 Decisions & Alternatives rows swept.

No capability flags apply to this configuration; nothing to add there.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.