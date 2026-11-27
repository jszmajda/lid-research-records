**LID Coach — Field Notes**

## 1. Executive summary

**Posture:** Bootstrapping — arrow is well-formed through specs; the conflict-resolution decision is the live risk.

**Scorecard**
- ✓ Configuration — `## LID` block, Full mode, and version marker all present and well-formed
- ✓ Linkage shape — `prefix: SYNC` / `parent:` frontmatter, spec IDs grep-clean, LLD↔spec back-reference in place
- ⚠ Arrow completeness — the arrow ends at EARS; no tests or code phase yet
- ✗ Decision capture — the load-bearing conflict-resolution choice carries one word of rationale
- ⚠ Tenet/goal cascade — the merge mechanism works against the HLD's convergence goal under a condition the LLD itself names
- ⚠ Spec↔LLD coverage — several described behaviors have no spec

**Headline:** For a two-doc project this is unusually disciplined — the prefix frontmatter, the HLD→LLD parent link, and the EARS IDs are exactly the cheap linkage LID is built around, and the single tenet is a real tie-breaker rather than a platitude. The highest-value next move is the sync conflict decision: the LLD tells you device clocks are wrong by minutes and then resolves conflicts by device clock, and the Decisions row doesn't record what that trade cost.

## 2. Findings

**Findings (8 total · 3 high · 3 medium · 2 low)**
- **F1 (high):** `sync-design.md:17` resolves conflicts by device wall-clock while `:9` states device clocks are routinely minutes off — under that stated condition a stale edit wins and the fresher one is discarded, which pushes against the HLD goal *Convergent state after reconnect* and the spirit of *No blocked capture in the field*; no Decisions row or decision doc records the exception · *tenet cascade / keep the arrow coherent*
- **F2 (high):** the `Conflict resolution` row's rationale is "Simpler." — a cold reader holding this row plus the clock-skew context would still want to reverse the choice, and can't reconstruct what was given up (server-receipt ordering, logical/vector clocks, CRDT merge) or the cost accepted (silent edit loss) · *docs carry current intent — keep-side*
- **F3 (high):** both specs are marked `[x]` (landed) but the repo contains no tests and no code citing `SYNC-001`/`SYNC-002` · *intent leads; code is compiled output*
- **F4 (medium):** LLD behaviors with no spec — the non-conflicting merge path (`:13`), the fate of the discarded edit, and the NTP-resync-on-reconnect condition (`:9`) are described but unnamed in EARS · *effective intent-tree alignment*
- **F5 (medium):** the `Note storage — SQLite on device` decision sits in the sync leaf, but the HLD names the device-local store as its own architecture concept with no leaf of its own; consider whether the store is a sibling leaf or genuinely inside sync's subtree · *intent attaches at the lowest node that dominates it*
- **F6 (medium):** the arrow currently runs HLD → LLD → EARS and stops; the tests and code phases are absent · *canonical arrow shape* (expected pre-implementation — the note is that tests-first is the next phase, not that something was skipped)
- **F7 (low):** the HLD has no target-users or success-metrics sections, so "convergent state" has no measurable form to cascade against · *HLD is architecture and rationale*
- **F8 (low):** `high-level-design.md:13` — "reconciliation on the sync path" reads as shorthand for a reader who was in the conversation; the phrase isn't resolved anywhere downstream · *docs carry current intent, written to be read cold*

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 HLD, 1 LLD, 1 spec file, 2 EARS specs, 1 tenet, 2 Decisions rows
- Searched the whole repo for code, tests, and `@spec` annotations: none present (4 files total outside `.git`)
- Arrow-maintenance overlay: not installed (`docs/arrows/` absent), so no index-guided sampling; project is small enough for exhaustive reading rather than sampling
- Dispatch: fully configured (directives + `Mode: Full` + standard directories) → full review. Non-interactive run, so no clarifying questions were asked; Full mode was taken from the declared marker, and no out-of-scope section applies.

---

Want me to walk through any of these in detail, focus on a priority tier, or work through the conflict-resolution decision together? F1 and F2 are the same choice seen from two angles and are probably the most productive place to start.

If you have broader questions about using LID here — when to split the device-local store into its own leaf, how to sequence tests-first from a spec file that already exists, or what to do with `[x]` markers before implementation lands — I can help with those too.