All inputs read: the entire repo (CLAUDE.md, HLD, one LLD, one spec file), cross-checked against the linked-intent-dev conventions (EARS syntax, LLD templates, capability flags). Dispatch: fully configured — LID directives + `Mode: Full` + `docs/intent/` + HLD all present — so a **full review** runs. No overlay, no code files; the cold-read and decisions-sweep both done. Findings rendered per the skill.

---

# LID Coach — Field Notes

**Posture:** Early and promising — arrow authored cleanly through specs, with drift concentrated in implementation-status markers, one load-bearing design seam, and one missing component design.

**Scorecard**
- ✓ Tenets — "Boring over clever" is a real tie-breaker: defensible opposite, a lean not a triggered rule
- ✓ HLD discipline — problem, approach, architecture, goals, non-goals; no implementation detail creeping upstream
- ✓ Linkage structure — spec IDs unique and grep-able; spec file backlinks its LLD; `prefix: SYNC` frontmatter resolves SYNC-001/002 to the sync leaf
- ⚠ Implementation status — both specs marked `[x]` with no code or tests in the repo
- ⚠ Design coherence — conflict resolution leans on device wall-clocks the same doc says are wrong by minutes
- ⚠ Intent-tree coverage — the device-local store, named in the HLD, has no LLD; its storage decision is lodged in the sync doc

**Headline:** The authored layers are in genuinely good shape — a disciplined HLD, a real tenet, clean spec↔LLD linkage; the fastest wins are flipping the status markers to `[ ]`, resolving the clock-skew seam before tests encode it, and giving the device-local store its own design home.

**Findings (6 total · 3 high · 2 medium · 1 low)**
- **F1 (high):** SYNC-001/002 are marked `[x]` ("code and tests exist") but the repo contains no code or tests — a future session reading the spec file cold would believe sync is already realized · *docs carry current intent* (docs state present intent accurately; git keeps history). Consider flipping both to `[ ]` (active gap) until code and tests exist.
- **F2 (high):** Last-writer-wins by *device wall-clock* is undermined by the LLD's own Context ("clocks are frequently wrong by several minutes") — under that stated condition the genuinely later edit can lose and be discarded; the system still converges, but possibly onto the wrong edit · *coherence is adjacency* (adjacent levels — here the mechanism and its own stated constraint — should agree). The mechanism is encoded in SYNC-002, so a fix should move the LLD §Conflict handling, the spec, and the Decisions row together (all within the one sync segment — cascade runs freely there).
- **F3 (medium):** The conflict-resolution Decisions row records only "Simpler." — no alternatives named, no cost accepted; a cold reader holding that row plus the clock-skew Context would question the choice and can't reconstruct what was given up (server receive-time ordering? logical clocks?) · *docs carry current intent* (decision capture — a fresh author choosing this design records the alternatives and the why). Consider adding the missing "Alternatives Considered" column and filling this row.
- **F4 (high):** The device-local note store — named in the HLD's Approach and Architecture — has no LLD and no specs, and its SQLite storage decision is lodged in the sync LLD's Decisions table only because no closer home exists · *intent attaches at the lowest node that dominates it* (decisions live where their whole effect is owned) and *effective intent-tree alignment* (architecture concepts trace to design nodes). Consider authoring a store LLD (`docs/intent/store/`, its own prefix) and re-homing the storage row — otherwise store decisions will keep accumulating in the sync doc.
- **F5 (medium):** The sync LLD leaves merge/upload edges open — what "merges them into the canonical store" means beyond conflict resolution, plus partial-upload failure, retry, and idempotency on reconnect — so two reasonable implementers could land in incompatible places · *LLDs close enough of the solution space* (specific enough to follow without guessing, loose enough not to rot). Worth closing before tests-first begins.
- **F6 (low):** HLD Goals double as success criteria without measurable form ("convergent state after reconnect" — within what bound?) · *HLD is architecture and rationale* (the HLD carries success metrics). Consider sharpening.

**What was audited**
- Read fully: CLAUDE.md, docs/high-level-design.md, docs/intent/sync/sync-design.md, docs/intent/sync/sync-specs.md — the entire working tree (4 files; no other files exist in the repo)
- Enumerated: 1 LLD, 1 spec file, 2 EARS specs (SYNC-001–002), 0 `@spec` annotations (no code or test files present), 0 arrow segments (no `docs/arrows/` overlay)
- Conventions cross-checked: linked-intent-dev's EARS syntax reference (status-marker semantics, ID format), LLD template reference (frontmatter, Decisions & Alternatives), capability-flags (no flagged configurations listed for my model configuration)

**Capability-flag note** — omitted: `capability-flags.md` lists no flagged configurations. **Out-of-scope note** — omitted: Full mode, whole repo in scope.

Want me to walk through the findings in detail, focus on a theme (the design seams F2–F5 work well as a set), or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID for this project — when to add the arrow-maintenance overlay, how a leaf promotes to a sub-HLD if sync grows internal depth, mode fit as the codebase grows — I can help with those too.

**Run notes (defaults taken, per non-interactive invocation):** Dispatch resolved to the fully-configured branch → full review (no dispatch default needed); no other decision points arose. Report rendered inline and **not** persisted to disk — the skill's advisory posture is load-bearing, so no file changes were made; apply findings via direct edits, `/update-lid` for configuration, or `/arrow-maintenance` for structural enumeration. Capability-flag and out-of-scope sections skipped per their stated defaults. The coach stops here rather than iterating; the two invitations above are the follow-up paths.