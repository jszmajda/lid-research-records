**LID Coach — Visit Planner**

**Posture:** Solid design skeleton; spec status markers and configuration need attention.

**Scorecard**
- ✓ LLD granularity — two clean leaves (`intake`, `fulfillment`), no lumping or overlap
- ✓ HLD rationale — architecture-level *why* with four real tenets, no schemas leaking upstream
- ⚠ Configuration — the instruction file carries a `## LID` block but no LID directive block
- ✗ Spec status — every spec is marked `[x]` (implemented) though no code or tests exist
- ⚠ Tenet alignment — the ≤36h searchable-checkout path leans against "First asked, first served"
- ⚠ Decision capture — the 36h/20min/2h thresholds and the search-window choice have no row

The design layer is real and well-linked across both components; the fastest wins are correcting the spec status markers and reconciling the instruction file so the arrow can be walked cold.

**Findings (8 total · 3 high · 4 medium · 1 low)**
- **F1 (high):** `CLAUDE.md` has a `## LID` block but no `linked-intent-dev` directive block · *modes are declared, not inferred*
- **F2 (high):** all 15 specs marked `[x]` though the repo contains no code or tests · *coherence is adjacency* / *tests before code*
- **F3 (high):** fulfillment's ≤36h public-search / any-eligible-account checkout window defeats the tenet "First asked, first served" with no recorded exception · *tenet cascade*
- **F4 (medium):** no Decisions row captures the search-window-vs-order choice or the 36h / 20min / 2h thresholds · *decision capture*
- **F5 (medium):** both LLDs lack `parent:`/`prefix:` frontmatter · *effective intent-tree alignment*
- **F6 (medium):** HLD omits Full-mode sections — Target Users, Non-Goals, System Design, Key Design Decisions, Success Metrics · *HLD is architecture and rationale*
- **F7 (medium):** cold-read gaps — "registry scan", "the matcher", "checkout", and "system of record" are used without definition · *docs carry current intent, written to be read cold*
- **F8 (low):** the `FILL` prefix does not echo its leaf name `fulfillment` · *semantic legibility as cheap linkage*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`intake-design.md`, `fulfillment-design.md`), both spec files
- Enumerated: 2 LLDs, 2 spec files, 15 specs (7 intake + 8 fulfillment)
- No code, tests, or `@spec` annotations exist in the repo (6 tracked files total), so Tests/Code phases could not be sampled
- No `docs/arrows/` overlay; linkage metric: 15 spec IDs, 0 `@spec` references, 0 `prefix:`/`parent:` frontmatter declarations

**Defaults taken (non-interactive run):** treated the project as Full mode (mode marker present; directive block missing → Full per dispatch); surfaced the missing directives as a high-priority finding. No capability flags are configured, so the capability-flag note was omitted. Report rendered inline only; no files were edited, per the coach's advisory posture.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.