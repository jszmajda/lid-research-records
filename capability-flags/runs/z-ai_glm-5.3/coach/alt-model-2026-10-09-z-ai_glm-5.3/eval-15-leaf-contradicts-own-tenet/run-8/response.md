## LID Coach — Shelfwise

**Posture:** Design-stage and healthy — the drift is in status claims, configuration, and one unrecorded tenet trade, not in the design itself.

**Scorecard**
- ✓ Granularity — clean depth-2 tree: one lean HLD over two right-sized LLDs
- ✓ Spec hygiene — EARS-compliant, globally unique grep-friendly IDs; the check-in space is cleanly partitioned (HOLDALLOC-003/004/005)
- ✓ Mutation hygiene — every doc reads cold: no history residue, no obsolete markers, no meaning that needs the conversation that produced it
- ⚠ Tenet cascade — branch-first allocation works against Tenet 1, unrecorded
- ⚠ Implementation status — all 13 specs marked implemented; no code or tests exist
- ⚠ Configuration — `## LID` block present but LID directives absent; LLDs lack `parent:`/`prefix:` frontmatter

**Headline:** The design half of your arrow is real and unusually clean — two well-scoped LLDs, decision rows that do real work (the expiry row names the goal traded and why accepted) — and the fastest wins are recording the one tenet-scale trade hiding in the allocation design, syncing spec status markers to reality, and one `/update-lid` pass.

### Findings (8 total · 3 high · 4 medium · 1 low)

- **F1 (high):** Branch-first allocation contradicts Tenet 1 ("waiting is honored in sequence") · *tenets capture forward-looking preference* — tenets pre-narrow the choices no spec has reached yet. The design sends a checked-in copy to the oldest hold **at the scanning branch** (HOLDALLOC-003) before an older hold elsewhere ever sees it — 004 only fires when nobody local waits — so a patron who asked sooner has their wait lengthened by a patron who asked after them, exactly what the tenet forbids. Nothing records the exception, so every future session re-meets this tension cold. Either scope the tenet ("within a pickup branch…") or record the trade against it.
- **F2 (high):** All 13 specs marked `[x]` — "implemented: code and tests exist" — in a repo with no code or tests · *intent leads; code is compiled output* — status markers are the arrow's ground truth. An arrow-walker greping HOLDALLOC-003 will hunt for an implementation that isn't there. Consider flipping all to `[ ]` (active gap) until tests-first lands.
- **F3 (high):** Instruction file carries the `## LID` block (Mode: Full, Version: 1.4.0 — current) but no LID directives · *modes are declared, not inferred* — an unread configuration is just a default. Grep for `linked-intent-dev` in CLAUDE.md finds nothing, so future sessions get the mode but never the instruction to walk the arrow. `/update-lid`'s append-directives branch exists for exactly this state.
- **F4 (medium):** The allocation-order choice (branch-first vs strict county-wide FIFO) has no Decisions & Alternatives row · *docs carry current intent* — a live choice belongs where a cold reader looks first. The why (courier runs once a day) lives only in body prose; what was given up goes unstated. One fuller row (rejected: strict FIFO; accepted cost: sequence honored only locally) resolves this and F1 together.
- **F5 (medium):** Hold cancellation is presumed but never specified · *effective intent-tree alignment* — LLD behavior with no spec drifts silently because there's nothing to test against. HOLDALLOC-007 handles a cancelled-in-transit arrival, but no spec covers the cancellation act itself, or that the record is then deleted per Tenet 4 ("hold history is not kept"). Consider specs for the cancel path.
- **F6 (medium):** Neither LLD carries `parent:`/`prefix:` frontmatter · *specs are grep-anchored linkage* — `prefix:` is the authoritative bridge from ID (HOLDALLOC) to design doc (hold-allocation). Without it the tree isn't walkable upward and the bridge rests on guesswork. Mechanical fix; `/update-lid`'s reconcile pass can batch it.
- **F7 (medium):** Full-mode HLD skips standard sections — Target Users, Non-Goals, Key Design Decisions, Success Metrics (Goals 1–2 currently do double duty) · *HLD is architecture and rationale* — Full LID expects these filled, and a Non-Goals boundary ("not a second circulation system") would be load-bearing against surface growth. The branch-first allocation (F1) is arguably the first Key Design Decision.
- **F8 (low):** Pickup LLD prose compresses expiry sequencing · *coherence is adjacency* — "the hold closes, and the copy is re-run through allocation" reads as if both happen at lapse, while PICKUP-004/005 place close + delete + reallocate at the staff pull-scan. The specs disambiguate; one tightening sentence in the LLD keeps the seam clean.

### What was audited

- Read fully: CLAUDE.md, docs/high-level-design.md, both LLDs, both spec files — 100% of the repo's tracked files
- Enumerated: 1 HLD, 2 LLDs, 13 EARS specs (7 HOLDALLOC, 6 PICKUP), 7 Decisions & Alternatives rows
- No code or test files exist to sample; no arrow overlay (`docs/arrows/` absent), so no end-to-end segment walks — the review covers the HLD → LLD → EARS span in full
- Calibrated against the linked-intent-dev skill's EARS syntax, HLD template, and LLD template references

**Defaults taken in this run (non-interactive):** dispatched per the skill's table — the instruction file greps negative for LID directives, but LID-shaped artifacts exist, so a full review ran anchored on the artifacts with the missing directives surfaced as F3; mode treated as the declared Full. The sampling reference was not needed (below its thresholds: 2 LLDs, no `@spec` files, no overlay); the capability-flag note is omitted (capability-flags.md lists no flagged configurations) and the out-of-scope section is omitted (Full mode). No files were changed: /lid-coach is advisory by design — apply findings via `/update-lid` (F3, F6) or direct edits.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID for this project — how tests-first will work once code starts landing, mode transitions, where the arrow overlay fits, multi-repo setups — I can help with those too.