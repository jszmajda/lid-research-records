# LID Coach — Field Notes

**Bootstrapping — arrow in place, design-stage, one live tension in the sync segment.**

**Scorecard**
- ✓ Configuration — instruction file carries the `## LID` block, `Mode: Full`, correct directives
- ✓ Arrow shape — canonical phases in order: HLD → LLD → EARS, with `parent:`/`prefix:` frontmatter properly linking the LLD into the tree
- ✓ Mutation hygiene — every doc reads as if authored fresh today; no history residue, no obsolete markers
- ✓ Spec hygiene — well-formed EARS, unique `SYNC-001`/`SYNC-002` IDs matching the LLD's `prefix: SYNC`, WHEN clauses present, LLD back-link present
- ⚠ Decision capture — the load-bearing conflict-resolution row doesn't survive a cold read
- ⚠ Design coherence — the LLD's own Context undercuts its central design choice

The arrow is real and cleanly configured end to end, and the tenet ("boring over clever") is a genuine tie-breaker with a defensible opposite; the single most valuable next step is resolving the clock-skew tension in the sync LLD **before** code lands on it.

---

**Findings (5 total · 2 high · 1 medium · 2 low)**
- **F1 (high):** The sync LLD's conflict design contradicts its own Context — the doc states devices' clocks are "frequently wrong by several minutes," then makes device wall-clock the winner-take-all arbiter (sync-design.md:9 vs :17); under the doc's own operating condition, the *actually later* edit can be the one discarded (and equal timestamps are an undefined tie) · *LLDs close enough of the solution space* — edges left open get filled in by whoever implements, exactly where intent drift enters
- **F2 (high):** The Decisions row "Last-writer-wins by device wall-clock — Simpler." omits the reasoning a cold reader needs; anyone holding this row *and the Context above it* would immediately question or want to reverse the choice, and can't reconstruct what was accepted (risk of losing the later edit) or why it was worth it · *docs carry current intent* — decisions a cold reader would still question need a fuller row (a hybrid clock, server-side arbitration, or a stated tolerance for skew)
- **F3 (medium):** Both specs carry `[x]` status markers but the repo contains no code or tests — either the marker doesn't mean what a cold reader would guess ("done"), or it misstates current state; the convention is documented nowhere · *intent leads; code is compiled output* — spec status asserting a compiled result that doesn't exist yet
- **F4 (low):** SYNC-001's "the system SHALL upload" could name the acting component (the device client) — sharper for grep-landings if a second variant ever exists · *scope disambiguation* — ubiquitous-sounding specs should say who acts
- **F5 (low):** The HLD covers Problem/Approach/Tenets/Goals/Non-Goals but not target users or success metrics — fine at this stage, worth growing as the project lands · *HLD is architecture and rationale*

---

**What was audited**
- Read fully: the instruction file (`CLAUDE.md`), `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md` — the entire repo is 4 files
- Enumerated: 1 LLD, 1 spec file, 2 EARS specs, 0 code files, 0 test files, 0 `@spec` references (repo is pre-implementation; tests-first and `@spec` linkage become live review dimensions once code starts landing)
- No arrow overlay (`docs/arrows/` absent) — structural enumeration via `/arrow-maintenance` isn't applicable yet
- Cold-read pass: performed on all three LID docs; the clock-skew tension above is exactly what that pass exists to catch
- Decisions-table sweep: 2 rows reviewed; the SQLite row passes as terse-but-clear, the LWW row flagged (F2)

---

**Defaults taken (non-interactive run):** the project state itself determined the dispatch — fully configured (directives + mode marker + standard directories) → full review, Full mode, so no out-of-scope section. The skill's advisory posture is also its default: no files were edited; findings are surfaced for you to apply (F1–F2 by strengthening the LLD's Decisions row directly, configuration-shaped items via `/update-lid`, structural items via `/arrow-maintenance` once the overlay exists). Report rendered inline, not persisted.

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? F1/F2 are the ones I'd dig into first — they're the decision a future implementation session will inherit cold.

If you have broader questions about using LID for your project — when to add the arrow overlay, how tests-first should kick off for the first component, mode transitions, what to do when a segment grows — I can help with those too.