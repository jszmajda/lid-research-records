The capability-flags file lists no actual flagged configurations (template only), so that section is omitted. I have everything needed for the review. Here is the report.

---

## LID Coach — Field Notes

### Executive summary

**Posture:** *Healthy and coherent — one load-bearing design decision needs capturing.*

**Scorecard**
- ✓ Configuration — `## LID` block well-formed; Mode: Full declared, version marked
- ✓ Linkage — spec IDs grep-anchored, `prefix: SYNC` matches the `SYNC-*` IDs, EARS-clean
- ✓ Mutation hygiene — docs are terse and current; no history residue
- ⚠ Decision capture — the conflict-resolution choice reads as questionable but is barely recorded
- ⚠ Arrow completeness — arrow stops at specs; Tests and Code phases absent
- ⚠ LLD granularity — the device-local store is named in the HLD but has no LLD of its own

**Headline:** The arrow is real and clean from HLD → LLD → EARS — tight specs, honest tenet, no accumulation. The single most valuable move is to capture *why* last-writer-wins by device wall-clock was chosen, since the LLD's own context makes a cold reader want to reverse it.

### Findings (4 total · 2 high · 2 medium)

- **F1 (high):** The conflict-resolution row (`Last-writer-wins by device wall-clock` / "Simpler.") doesn't record the cost accepted — yet the same LLD's Context says device clocks are "wrong by several minutes" · *docs carry current intent* — a cold reader would question the choice and can't reconstruct what was traded.
- **F2 (high):** Design concern (pairs with F1): under the skewed-clock condition the LLD itself describes, wall-clock LWW can silently discard the genuinely-later edit — worth weighing against the *convergent state after reconnect* goal · *intent attaches at the lowest node that dominates it* / goal-conflict lens.
- **F3 (medium):** `SYNC-001`/`SYNC-002` are marked `[x]` (done), but no tests cite them and no code carries `@spec` — the arrow's Tests and Code phases are absent · *canonical arrow shape*; *tests carry `@spec` annotations* (an agent can't walk spec → test → code).
- **F4 (medium):** The HLD names a "device-local store" as an architecture element, but it has no LLD — and its one decision (`SQLite on device`) is lodged in the *sync* LLD · *one LLD per intent component* (intent for one component living in another node's doc).

### What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 HLD, 1 LLD, 1 spec file (2 specs), 0 test files, 0 code files
- Arrow-path sampled: the single sync segment end-to-end (HLD Architecture → SYNC LLD → `SYNC-001/002`) — path intact through EARS, then stops
- Overlay: none (`docs/arrows/` absent) — no structural audit attempted; cascade/coherence enumeration would be `/arrow-maintenance`'s job if installed

### How I'd like to help

Want me to walk through any finding in detail, start with the F1/F2 pair on conflict resolution, or work through them together? Pick a finding and I'll dig in.

And if you have broader questions about using LID here — whether the device-local store deserves its own LLD now or later, how the status markers should track implementation, or when Full mode is worth the overhead on a project this size — I'm glad to talk those through too.