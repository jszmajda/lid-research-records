# LID Coach — principle review (2026-11-11)

*Posture: Bootstrapping cleanly — strong doc layer; one load-bearing decision is both under-captured and working against a goal.*

**Scorecard**
- ✓ Configuration — explicit `## LID` block with `Mode: Full` + directives · *modes are declared, not inferred*
- ✓ Linkage & alignment — `SYNC` prefix traces to the LLD; EARS `When … SHALL` with status markers · *specs are grep-anchored linkage*
- ✓ Mutation hygiene — no history residue, no obsolete markers, clean cold-read docs · *mutation, not accumulation*
- ✓ HLD discipline — architecture-level HLD, one real tie-breaker tenet, no implementation detail · *HLD is architecture and rationale*
- ⚠ Decision capture — the wall-clock conflict-resolution choice is under-captured and works against a goal · *docs carry current intent*
- ⚠ Arrow completeness — the arrow currently ends at EARS (bootstrapping) · *canonical arrow shape*

The doc layer is genuinely well-formed: an explicit Full-mode config, a tenet and goals in the HLD, a properly-prefixed LLD, and EARS specs with status markers and a back-link. The single most valuable next step is to settle the `sync` conflict-resolution decision — and put its trade-off on the record — before it propagates into tests and code.

**Findings (3 total · 2 high · 0 medium · 1 low)**
- **F1 (high):** `docs/intent/sync/sync-design.md:17` resolves conflicts by device *wall-clock* timestamp while its own Context (`:9`) says clocks are "frequently wrong by several minutes" (NTP only on reconnect); under that described condition the genuinely-later edit can be discarded — working against the HLD goal "Convergent state after reconnect" (`docs/high-level-design.md:21`) — and `SYNC-002` (`sync-specs.md:6`) already encodes the rule, so no Decisions row records the exception · *tenets capture forward-looking preference* — the HLD's tenets/goals pre-narrow downstream designs, so when a mechanism works against one under a described condition, the exception belongs on the record.
- **F2 (high):** the row `Conflict resolution | Last-writer-wins … | Simpler.` (`sync-design.md:23`) leaves a choice a cold reader would still question or try to reverse (given the clock-skew context) with no rejected alternative and no named accepted cost; the `SQLite | Standard embedded store` row is the healthy contrast · *docs carry current intent, written to be read cold* — a future session gets only the page, so a live decision's reasoning has to sit on it, not in the chat that produced it.
- **F3 (low):** no Tests or Code phase exists for `SYNC` yet — no tests, no code, no `@spec` annotations for `SYNC-001`/`SYNC-002`; when you implement `sync`, that's where tests-first and entry-point annotations extend the arrow · *canonical arrow shape* — HLD → LLDs → EARS → Tests → Code, with each phase present for in-scope components.

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`, plus the skill's four `references/` files.
- Enumerated: 1 HLD, 1 LLD, 1 spec file (2 IDs: `SYNC-001`, `SYNC-002`, both resolving to prefix `SYNC`), 0 test files, 0 code files, 0 `@spec` annotations; git history is a single commit (`fixture`).
- Cold-read pass and Decisions-table sweep run across every LID doc; below the sampling thresholds and no `docs/arrows/index.yaml`, so inputs were read in full by judgment (no `/arrow-maintenance` enumeration needed).

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together — say, F1 on the wall-clock conflict-resolution choice? You can also pick any single finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

*Non-interactive run — defaults applied: rendered the report inline and did not persist it to disk (skill default: do not persist unless asked); made no file edits (the coach is advisory and does not iterate, and no "fix" was requested); took `Mode: Full` as declared rather than inferred (no Scoped scope review needed); read all inputs in full since the project is below the sampling thresholds; no arrow overlay, so the corrupt-index "reduced review vs. pause" choice never arose; and offered the two follow-up invitations without engaging them (no user direction, so the "walk findings in priority order" follow-up default was not triggered).*