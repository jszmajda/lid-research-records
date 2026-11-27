# Shelfwise — LID Coach Review

**Posture: Clean design layer, arrow truncated above implementation.** The docs are unusually disciplined for a greenfield project — no residue, no obsolete markers, no drift-shaped detritus — but the arrow currently stops at EARS, and one live design conflict sits undocumented.

**Scorecard**
- ✓ Design layer — HLD + 2 LLDs + 2 spec files, clean node-as-folder layout, no accumulation
- ⚠ Arrow completeness — design and EARS only; no tests, no code in the repo
- ⚠ Linkage — spec IDs clean and globally unique; no `prefix:` frontmatter, no `@spec` annotations
- ⚠ Coherence — one LLD-prose vs. EARS mismatch on the expiry trigger; several LLD behaviors unspecced
- ⚠ Tenet cascade — branch-local allocation works against "waiting in sequence", unrecorded
- ✓ Mutation hygiene — every doc reads cold; all 7 Decisions rows are live, none are fossils

*The design layer is genuinely well-made — your tenet list and decision rows read like a project's own voice, not a template. The fastest wins are reconciling the instruction file, resolving one tenet conflict, and settling whether the implementation lives in this repo or another.*

**Findings (13 total · 3 high · 6 medium · 4 low)**

- **F1 (high):** the instruction file carries the `## LID` block (`- Mode: Full`, `- Version: 1.4.0` — current) but no LID directive section at all — nothing names `linked-intent-dev` or points a harness at the workflow · *modes are declared, not inferred* — the mode and version are visible, but the directive half of the configuration was never written → `/update-lid`
- **F2 (high):** all 13 specs are marked `[x]` (which the EARS convention defines as *code and tests exist*) while the repository contains zero source files and zero tests · *coherence is adjacency* — each level agrees with the one beside it; status markers are the implementation-status source of truth, so a wrong marker misleads every future session
- **F3 (high):** the canonical arrow `HLD → LLDs → EARS → Tests → Code` stops after EARS — there are no tests, no code, and therefore no `@spec` annotations anywhere · *canonical arrow shape* — a phase that hasn't started isn't drift, but a reader can't tell from the repo whether it's absent or lives elsewhere; name where the implementation sits
- **F4 (medium):** neither LLD carries the `parent:` / `prefix:` frontmatter that current LID conventions require, so `hold-allocation → HOLDALLOC` and `pickup-notices → PICKUP` aren't derivable from the ID · *effective intent-tree alignment* — the leaf's `prefix:` is the authoritative bridge from a namespace back to its design doc → `/update-lid`
- **F5 (medium):** same-branch-first allocation works against the tenet "Waiting is honored in sequence" — *nobody's wait is lengthened by a patron who asked after them* — and the trade-off is recorded nowhere · *tenet cascade* + *decision capture* — a cold reader will find it and have to guess which way it was meant to go → see below
- **F6 (medium):** `pickup-notices-design.md:11` says the copy is re-run through allocation **when the window lapses**, while `PICKUP-004` puts only the pull-list entry at lapse and `PICKUP-005` does the close/delete/reallocation **when staff scan the copy off the shelf** — two different triggers for one behavior · *coherence is adjacency* — the design's own decision row ("Morning pull list, then reallocate") supports the spec reading, so the §Design prose looks like the drifted text
- **F7 (medium):** LLD behaviors with no spec anywhere — the `allocated` copy state and its transition (`HOLDALLOC-006` references a state no spec establishes), hold cancellation (`HOLDALLOC-007` depends on a cancelled hold that nothing specifies), and channel selection at signup (`PICKUP-002` references "the patron's chosen channel" with no spec for how it's chosen or stored) · *effective intent-tree alignment* — unnamed intent drifts silently, because there's nothing to test against
- **F8 (medium):** the HLD omits several Full-mode sections — Target Users, Non-Goals, System Design (you have "Components"), Key Design Decisions, Success Metrics (you have "Goals") · *HLD is architecture and rationale* — in Full mode every section is filled, and Non-Goals is the one that earns its keep by making it easier to say "no" to surface growth
- **F9 (medium):** `PICKUP-005` says "run allocation for the copy as a check-in at that branch" with no pointer to `HOLDALLOC-003`/`004` — a grep-reader could reasonably implement it as "give it to the oldest hold county-wide" instead of the branch-preferred rule · *scope disambiguation* — a cross-file concept needs enough inline context to prevent a plausible-but-wrong implementation
- **F10 (low):** the tenet list is unordered, and there is now a live conflict candidate ("waiting in sequence" vs. branch-local preference; "patrons hear once" vs. expiry without reminders) · *tenets capture forward-looking preference* — order them so the higher one wins, so a future session resolves a collision by position rather than by guesswork
- **F11 (low):** a few cold-read gaps — which branch's holds shelf the patron scans at (the pickup branch? any branch?), what "morning pull list" means in time terms, and whether "county-wide" means exactly the six branches · *docs carry current intent* — future sessions read these cold, with none of today's context
- **F12 (low):** no arrow-maintenance overlay (`docs/arrows/`) is installed, so structural questions — orphans, reverse orphans, adjacent-level drift enumerated exhaustively — have no instrument · consider adding the plugin if you want those audits mechanical
- **F13 (low):** neither LLD carries an "Open Questions & Future Decisions" section, so deferred calls (exception-list staffing, courier scheduling, channel-selection storage) have no visible home · *minimum surface, maximum discipline* — the section is cheap and keeps deferred intent from surfacing as surprise later

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files (13 spec IDs, 7 Decisions rows)
- Repository scan: 6 tracked files across 1 commit; no source, test, build, or config files; 0 `@spec` annotations
- Compared against the installed LID conventions (LLD/HLD templates, EARS syntax reference, CHANGELOG): the project's `- Version: 1.4.0` matches the latest release — no version lag, and the node-as-folder layout is already at 1.2+ conventions
- Nothing to sample in code or tests — the bottom of the arrow does not exist yet; no overlay present to guide sampling

*Defaults taken (non-interactive run):* Full mode honored as declared; the missing-directive case was treated as "proceed with a full review" per the skill's dispatch table, with F1 surfaced as a `/update-lid` recommendation; structural findings were surfaced as patterns rather than enumerated (no `/arrow-maintenance` pass was run); **no files were changed** — the coach is advisory, and all remedies above are yours to apply.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.