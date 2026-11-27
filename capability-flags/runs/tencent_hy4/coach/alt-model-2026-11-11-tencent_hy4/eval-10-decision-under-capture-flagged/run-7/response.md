I have everything I need. Dispatch resolves to **fully configured** (directives in `CLAUDE.md`, explicit `Mode: Full`, standard `docs/` tree) → full review; small project (4 files, no overlay), so full read rather than `sampling.md` path-sampling.

---

# /lid-coach — LID principle review (2026-11-11)

**Posture:** Bootstrapping — the upper arrow is clean and well-linked; one load-bearing decision needs a capture pass.

**Scorecard**
- ✓ Configuration — `## LID` directives and the explicit `Mode: Full` marker are present and coherent
- ✓ Linkage — `SYNC-001`/`SYNC-002` are grep-friendly and EARS event-driven, with `parent:`/`prefix:` frontmatter and a spec→LLD pointer
- ✓ HLD discipline & Tenet quality — the HLD carries architecture and rationale only (SQLite detail sits correctly in the LLD), "Boring over clever" is a genuine tie-breaker, and the docs carry no history residue
- ⚠ Tenet cascade — wall-clock last-writer-wins works against the convergent-state goal under the clock-skew condition the LLD itself states
- ⚠ Decision capture — the "Simpler." row leaves the accepted tradeoff unrecoverable to a cold reader
- ⚠ Coherence / arrow completeness — `[x]` "Implemented" markers with no tests or code in the tree

**Headline:** The upper arrow is genuinely well-formed — a clean architecture-only HLD, one properly namespaced `SYNC` component, EARS specs that trace back to the LLD, and docs free of change-narration — so the fastest win is to capture the reasoning behind the wall-clock conflict-resolution decision, which the LLD's own clock-skew constraint makes hard to defend when read cold, and to reconcile the `[x]` markers with the still-unwritten Tests→Code phases.

**Findings (4 total · 2 high · 1 medium · 1 low)**
- **F1 (high):** `docs/intent/sync/sync-design.md` resolves conflicts by device wall-clock timestamp even though its own Context says those clocks are "frequently wrong by several minutes"; under that condition last-writer-wins picks an essentially arbitrary winner and discards a field edit, working against the HLD goal "Convergent state after reconnect," and no Decisions row records the exception naming the goal and why · *tenet cascade* (design nodes should lean the way the HLD's tenets and goals say, even under conditions the docs themselves describe)
- **F2 (high):** the "Conflict resolution / Last-writer-wins by device wall-clock / Simpler." Decisions row is the only record of a choice a cold reader would still question or reverse, yet it names neither the rejected clock-independent alternative nor the cost accepted under clock skew · *docs carry current intent, written to be read cold* (a doc must stand on its own without the conversation that produced it)
- **F3 (medium):** both specs in `sync-specs.md` are marked `[x]` ("Implemented: code and tests exist") while the tree contains no tests and no code, so the arrow currently stops at EARS and the status markers claim a completion the doc tree can't back · *coherence is adjacency* (each level of the arrow agrees with its neighbor) and *tests before code* (tests preload the use of the system before implementation exists)
- **F4 (low):** the HLD carries Goals, Non-Goals and a Tenet but no explicit success metrics or architecture-level key design decisions, so the long-lived *why* is thinner than this component's tricky tradeoff warrants · *HLD is architecture and rationale* (the HLD holds the durable why, not implementation detail)

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md` — all 4 files in the tree
- Enumerated: 1 HLD, 1 LLD, 1 spec file (2 EARS specs, both `[x]`), 1 arrow segment (`SYNC`), 2 Decisions-table rows
- No `docs/arrows/` overlay, so there was no `index.yaml` to consult; `/arrow-maintenance` was not in play. Single-commit history (2026-11-11) showed no stale-segment or `[inferred]` signals to triage
- Small project, far below `sampling.md`'s 15-LLD / 200-`@spec`-file thresholds → full read at judgment depth rather than arrow-path sampling; 0 code files, 0 test files, 0 `@spec` annotations exist to sample
- Passes: dimension-by-dimension review across all 19 dimensions, a cold-read pass through every LID doc, and a decisions-table sweep over both rows (row 2, "SQLite / Standard embedded store," reads as native once landed and passes)

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

---

**Non-interactive run — defaults taken**
- Dispatch resolved to *fully configured → full review*; because the `Mode: Full` marker is present, the skill's "default Full when the `## LID` block/marker is absent" fallback did **not** apply. Full mode is authoritative, so no scope was assumed and the out-of-scope section is omitted per the report spec.
- No `docs/arrows/index.yaml` exists, so the "proceed reduced / pause for repair" corruption branch and the overlay-guided sampling rules were not triggered; I took `sampling.md`'s small-project default — read every LID doc in full at judgment depth.
- Report delivery: rendered inline in one message and **not** persisted to disk (the "do not persist unless the user asks" default). **No files were created or edited**, per the coach's advisory posture ("this skill does not edit project files") — recommendations are surfaced only.
- I stopped after the report ("the coach does not iterate") rather than entering a follow-up turn; the offer-to-help is left open. Where the skill would otherwise wait for the user's direction, no follow-up default was exercised (had one been, `follow-up-turns.md`'s default is a priority-order walkthrough).