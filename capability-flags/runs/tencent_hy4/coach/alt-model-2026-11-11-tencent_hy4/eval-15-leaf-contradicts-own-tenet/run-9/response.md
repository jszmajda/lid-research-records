# LID Coach — Shelfwise review

**Posture:** Solid, well-authored intent layer — bootstrapping implementation, with one load-bearing tenet conflict to tighten.

**Scorecard**
- ✓ Tenet quality & HLD discipline — four real tie-breakers, architecture-level rationale, no upstream implementation bleed
- ✓ Mutation hygiene & decision capture (pickup-notices) — tradeoffs recorded with costs, no history/obsolete/`[inferred]` residue
- ✓ EARS format & intent-tree coverage — clean WHEN/IF/SHALL specs, unique IDs, every LLD behavior has a spec
- ⚠ Configuration — `## LID` mode marker present, but the LID directive block is missing from `CLAUDE.md`
- ⚠ Tenet cascade / decision capture (hold-allocation) — branch-local priority leans against "waiting honored in sequence," unrecorded
- ✗ Arrow completeness — no tests or code exist; the arrow stops at EARS

The intent layer is genuinely well done — crisp tenets, clean EARS, and a `pickup-notices-design.md` Decisions table that captures tradeoffs and accepted costs properly. The single highest-value next step is to reconcile branch-local allocation against Tenet 1 and give that choice a Decisions row; `/update-lid` for the missing directives is the quick win alongside it.

**Findings (6 total · 3 high · 1 medium · 2 low)**
- **F1 (high):** `CLAUDE.md` carries the `## LID` mode marker but no LID directive block, though the project is clearly LID-shaped — consider `/update-lid` to reconcile · *modes are declared, not inferred* — configuration belongs explicitly in the instruction file, not inferred from stray artifacts.
- **F2 (high):** `hold-allocation-design.md:11` hands a copy to a later requester at the scanning branch ahead of an earlier requester elsewhere whenever both are waiting, working against Tenet 1 "waiting is honored in sequence," with no Decisions row recording the exception · *tenet cascade* — leaf mechanisms should lean the way the HLD's tenets say, or record why not.
- **F3 (high):** that same branch-local-vs-county-wide-FIFO choice is live and questionable but sits only in body prose; consider a Decisions & Alternatives row naming the rejected alternative and accepted cost (the pickup-notices table shows how well you already do this) · *docs carry current intent, written to be read cold* — a future session should reconstruct what was given up without the chat that produced it.
- **F4 (medium):** the arrow stops at EARS — no test or code files, 0 `@spec` annotations, yet all 13 specs are marked `[x]`; consider standing up Tests → Code (tests-first) when implementation begins · *canonical arrow shape* — HLD → LLDs → EARS → Tests → Code, where specs drive tests and code rather than standing alone.
- **F5 (low):** spec prefixes `HOLDALLOC`/`PICKUP` don't literally resolve to the `hold-allocation`/`pickup-notices` leaves, and the LLDs carry no `prefix:` frontmatter; consider adding it so one grep lands on the owning leaf · *specs are grep-anchored linkage* — IDs should resolve unambiguously to their design node.
- **F6 (low):** the four tenets are an unordered list while real cases (a failed-delivery staff call vs. "patrons hear once"; strict sequence vs. courier logistics) pull them against each other; consider ordering them or stating which wins · *tenets capture forward-looking preference* — a tie-breaker helps most when its precedence is clear.

**What was audited**
- Read fully (5 docs): `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/hold-allocation/{design,specs}.md`, `docs/intent/pickup-notices/{design,specs}.md`.
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 13 EARS specs (`HOLDALLOC-001`–`007`, `PICKUP-001`–`006`, all `[x]`, zero collisions), 4 tenets, 2 goals, 7 Decisions & Alternatives rows.
- Cold-read pass and Decisions-table sweep run across all docs; no `docs/arrows/index.yaml` (overlay absent), no `AGENTS.md`.
- No code or test files exist anywhere in the repo; git history is a single "fixture" commit, so tests-first / cascade-timing could not be read from history.
- Consulted the skill's four `references/` files; `sampling.md`'s large-project thresholds (≤15 LLDs, ≤200 annotated files, overlay present) are not met, so every doc was read in full. Linkage metric: 0 `@spec` references (no annotated files).

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

**Defaults taken (non-interactive):** Full mode as the review anchor (the skill's default when directives are missing but the project is LID-shaped) rather than refusing or pausing to ask; rendered inline with no file persisted and no files edited (the coach's advisory default); stopped after the report instead of taking up an offer-to-help path (the coach does not iterate).