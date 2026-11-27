All inputs are read — the entire repo is four files plus one commit, so this is a full read, not a sample. Dispatch resolved automatically: CLAUDE.md carries the LID directives and `Mode: Full`, `docs/high-level-design.md` and `docs/intent/` exist, no arrow overlay, no code or tests anywhere. The review below follows the skill's dimensions, cold-read pass, and decisions-table sweep; capability-flags lists no flagged configurations, so that section is omitted, and Full mode means no out-of-scope section. The skill's advisory posture forbids file edits, so this run changes nothing on disk.

---

# /lid-coach — Field Notes

**Posture:** Bootstrapping — the arrow is real, clean, and cold-readable; the spec status markers overclaim, and one load-bearing decision contradicts the project's own stated operating condition.

**Scorecard**
- ✓ Linkage — IDs unique, grep-friendly, leaf prefix `SYNC` matches the LLD's `prefix:` frontmatter; specs cite their LLD
- ✓ Mutation hygiene — every doc reads as authored fresh today; no history residue, no obsolete markers
- ✓ Tenet cascade — the design's choices (LWW, SQLite) lean exactly the way "boring over clever" points
- ✗ Spec status coherence — both specs marked `[x]` with zero code or tests in the repo
- ⚠ Decision capture — "Simpler." doesn't engage the clock-skew fact the same doc states
- ⚠ Intent-tree coverage — the HLD's device-local store has no LLD and no specs

**Headline:** What's working is the discipline you can see — minimal, coherent docs that a cold reader can walk without help. The two most valuable moves are flipping the spec status markers to tell the truth, and pressure-testing last-writer-wins against the clock-skew fact the LLD itself records.

---

**Findings (5 total · 2 high · 2 medium · 1 low)**

- **F1 (high):** SYNC-001 and SYNC-002 are marked `[x]`, but the repo contains no code and no tests · *coherence is adjacency* (each level of the arrow must agree with its neighbor). In LID's marker semantics, `[x]` means code and tests exist; unimplemented intent belongs at `[ ]` (active gap). The markers are the arrow's work queue — marked done, the work becomes invisible to every future session, and an agent landing on the spec via grep goes hunting for an implementation that isn't there. Consider flipping both to `[ ]` — or, if implementation lives in another repo, saying so on the page.
- **F2 (high):** The sync LLD states devices' clocks are "frequently wrong by several minutes" — then builds conflict resolution on those same clocks: last-writer-wins by device wall-clock · *docs carry current intent* (the doc fails its own cold read), with the design concern under *LLDs close enough of the solution space*. Timestamps are captured while devices are offline — precisely the condition in which the design says clocks are wrong — so a device running fast wins conflicts it should lose, and the losing edit is *disclosed-to-be-discarded*. SYNC-002 then freezes the mechanism into a spec. Worth resolving before tests and code cascade from it; well-worn alternatives exist (server receive-time, per-device counters), so revisiting stays well inside the "boring over clever" tenet.
- **F3 (medium):** The Decisions row records "Simpler." with no alternative named and no cost acknowledged · *decision capture* (docs carry current intent — a cold reader holding the Context would question this choice, and the row can't reconstruct what was given up). If accepting unfair conflicts under clock skew is the deliberate price of simplicity, the rationale should say exactly that — a reader who can see the trade accepted won't try to reverse it.
- **F4 (medium):** The HLD names three architecture concepts (device-local store, sync service, reconciliation), but only sync has an LLD and specs — the store, which the first goal ("no blocked capture in the field") rests on, has none · *intent attaches at the lowest node that dominates it* / *effective intent-tree alignment*. Telling evidence: the "Note storage: SQLite" decision sits in the sync LLD's table, though it governs the store, not sync. Consider authoring a store LLD (its own folder, prefix, and specs), or marking the gap deliberately.
- **F5 (low):** The HLD is thinner than a Full-LID HLD — no Target Users, Key Design Decisions, or Success Metrics sections ("Architecture" stands in for System Design) · *HLD is architecture and rationale*. Fine at bootstrap; worth filling as the project grows so architecture-level "why" has a home above the LLDs.

**What was audited**
- Read fully: the entire repository — CLAUDE.md, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md` (4 files, 1 commit)
- Enumerated: 1 LLD, 1 spec file, 2 EARS specs, 2 Decisions rows, 1 tenet
- No code or test files exist — `@spec` annotation review not applicable (0 references)
- No arrow overlay (`docs/arrows/` absent) — no index or segments to sample
- References consulted: EARS syntax, LLD templates, HLD template, capability flags (no flagged configurations)

**Run notes.** lid-coach is advisory by design — it produces this report and makes no file edits, so nothing on disk changed during this run (application routes: edit directly; `/update-lid` for configuration; `/arrow-maintenance` if you later add the overlay and want structural enumeration). No user-decision points were reached: dispatch resolved automatically to a full review (fully configured, Full mode), and the report renders inline per the skill's default rather than persisting.

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding — F2 has the most to unpack — and we can dig in.

If you have broader questions about using LID for this project — when to author the store LLD, how tests-first kicks in once code starts, whether the arrow overlay is worth installing at this size — I can help with those too.