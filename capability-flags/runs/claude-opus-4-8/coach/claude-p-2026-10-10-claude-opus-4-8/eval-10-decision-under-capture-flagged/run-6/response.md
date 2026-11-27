No arrows overlay, and the capability-flags file carries no flagged rows (template only), so that section is omitted. Here is the review.

---

## LID Coach — Field Notes

### Executive summary

**Posture:** *Clean foundation; the arrow stops at specs, and one load-bearing design decision needs a second look.*

**Scorecard**
- ✓ **Linkage** — specs grep-anchored (`SYNC-001/002`), `prefix: SYNC` frontmatter and `parent: high-level-design` both present
- ✓ **HLD discipline** — architecture-and-rationale only; no schemas or signatures bleeding upstream
- ✓ **Mutation hygiene** — docs read cold cleanly; no history residue or planning text
- ✓ **Tenet quality** — "Boring over clever" is a real tie-breaker with a defensible opposite
- ⚠ **Decision capture** — the conflict-resolution choice is under-recorded given the design's own stated conditions
- ⚠ **Arrow completeness** — design and specs are in place; tests and code phases are not yet present

**Headline:** The sync arrow is real, well-named, and correctly linked from HLD down to EARS — strong bones for a small project. The highest-value next step is the conflict-resolution decision: the LLD names a clock-skew problem and then picks a mechanism that depends on those same clocks, with no record of the trade.

### Findings (4 total · 2 high · 2 medium)

- **F1 (high):** Conflict resolution is wall-clock last-writer-wins, yet the same LLD states device clocks are "frequently wrong by several minutes" — under that stated condition the winner is arbitrary and the losing edit is silently discarded · *docs carry current intent* (keep-side — a decision that reads as live still needs its reasoning on the page). This surfaces because the choice is live: a cold reader would question it immediately.
- **F2 (high):** That decision's capture leaves out the trade — the Decisions & Alternatives rationale is only "Simpler," naming neither the clock-skew it has to survive nor what correctness is given up for simplicity · *docs carry current intent*. A fuller row (or, if this was a real deliberation, a short decision doc) lets the next session see why wall-clock was chosen *despite* the skew.
- **F3 (medium):** The HLD architecture names a device-local store and the goal "no blocked capture in the field," but only the reconciliation half has an LLD and specs — the capture/local-store path has no design node or spec of its own · *effective intent-tree alignment* (a goal with no downstream drifts silently because there is nothing to test against).
- **F4 (medium):** Both specs are marked `[x]` done, but no tests cite `SYNC-001/002` and no code carries `@spec` anywhere in the repo — the arrow is not yet walkable past the EARS layer · *tests before code* / *canonical arrow shape*. If the implementation lives outside this tree the linkage is missing; if it is not built yet, the `[x]` markers overstate status.

### What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Mode: Full (declared); LID directives present; standard directories present
- No `docs/arrows/` overlay; no code or test files present in the repository
- Enumerated: 1 LLD, 1 spec file, 2 EARS specs

### Want to go further?

Want me to walk through any of these in detail, start with the conflict-resolution decision (F1/F2), or work through fixes together? Pick a finding and we'll dig in — note that for configuration changes the path is `/update-lid`, and I'll surface recommendations rather than edit files directly.

If you have broader questions about using LID on this project — where PRDs fit, when to split the sync LLD as the design grows, or how to bootstrap the tests-and-code phases of the arrow — I can help with those too.