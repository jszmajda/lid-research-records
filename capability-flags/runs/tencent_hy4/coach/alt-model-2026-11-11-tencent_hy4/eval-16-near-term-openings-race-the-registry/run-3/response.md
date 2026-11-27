# LID Coach — Visit Planner

**Executive summary**

*Posture: solid design layer; the arrow stops at EARS and one tenet/mechanism conflict sits unrecorded.*

**Scorecard**
- ✓ Docs carry current intent — clean, cold-readable docs; no changelog, `[obsolete]`, or `[inferred]` residue
- ✓ LLD granularity & alignment — tidy two-component tree, one spec file per leaf, well-formed EARS with scoped WHEN clauses
- ✓ Mode fit — Full mode matches a repo made entirely of LID design docs
- ⚠ Configuration — `## LID` block present, but the `linked-intent-dev` directive block is missing
- ✗ Arrow completeness — no Tests or Code phases, yet all 15 specs carry `[x]` done-markers
- ✗ Tenet cascade — the short-notice checkout path works against "First asked, first served"

The HLD, both LLDs, and both spec files are clean, cold-readable, and well-scoped; the fastest wins are reconciling the instruction-file directives, settling how the arrow reaches Tests/Code (and what `[x]` means there), and recording the short-notice exception to "First asked, first served".

**Findings (6 total · 3 high · 2 medium · 1 low)**

- **F1 (high):** `CLAUDE.md` carries `## LID` with Mode/Version but no `linked-intent-dev` directive block, so code changes aren't routed through the workflow — consider `/update-lid` to reconcile · *modes are declared, not inferred* (the instruction-file `## LID` block is the declared foundation that cascade rigor and coach dispatch key off).
- **F2 (high):** the arrow stops at EARS — there are no test or code files in the repo, while all 15 specs carry `[x]` done-markers, so a cold reader can't tell whether Tests/Code were walked or are pending · *canonical arrow shape* (HLD → LLDs → EARS → Tests → Code; a missing phase makes the arrow unwalkable).
- **F3 (high):** the ≤36h path in `fulfillment-design.md §Design` ("any eligible signed-in account may complete checkout while it is searchable", echoed in `FILL-004`) lets a later requester claim during the 20-minute window ahead of earlier interest entries, working against the HLD tenet "First asked, first served" (`HLD §Tenets`); no Decisions row names the trade · *tenets capture forward-looking preference* (tenets are tie-breakers every downstream mechanism should lean with), with *coherence is adjacency* (HLD and LLD should agree at their seam).
- **F4 (medium):** the two-path fulfillment design (>36h matcher vs ≤36h portal search + 20-min scan, with the 36-hour/20-minute parameters) is a live choice a cold reader would question, yet it sits only in design prose with no Decisions & Alternatives row and no named source for those thresholds · *docs carry current intent, written to be read cold* (a landed decision a reader would still question belongs in a fuller row, not in the chat that produced it).
- **F5 (medium):** `HLD §Tenets` "First asked, first served" is elaborated as a triggered rule ("When openings are scarce, patients are served in the order they asked") and duplicates `FILL-001`/`FILL-005`; consider recasting it as a tie-breaker and ranking the four tenets, since FIFO and "Clinical fit precedes utilization" can point different ways · *tenets capture forward-looking preference* (a tenet leans between defensible options; a *when X, do Y* rule belongs in EARS).
- **F6 (low):** the `FILL-` prefix is an abbreviation that doesn't literally resolve to the `fulfillment` leaf the way `INTAKE-` resolves to `intake`, and no `prefix:` frontmatter settles it — consider `FULFILLMENT-` or adding `prefix:` so one grep lands on the owning node · *specs are grep-anchored linkage* (an ID's leaf prefix should name the design node that owns it).

**What was audited**
- Read fully (all 6 repo files): `CLAUDE.md`, `docs/high-level-design.md`, `intake-design.md`, `intake-specs.md`, `fulfillment-design.md`, `fulfillment-specs.md`; plus a cold-read pass and a Decisions-table sweep over the same set.
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 15 EARS specs (7 `INTAKE`, 8 `FILL`), 2 Decisions & Alternatives tables (4 rows each), 0 test files, 0 code files, 0 arrow segments (no `docs/arrows/` overlay).
- Sampling depth: below the 15-LLD / 200-`@spec` thresholds and with no overlay, so a full judgment read rather than arrow-path sampling; no code/test files exist, so `@spec` placement, tests-first evidence, and semantic legibility couldn't be assessed (folded into F2).
- Linkage metric: 15 `[x]` status markers; 15 unique, zero-padded IDs; 0 `@spec` references in code/tests (none exist).

**Offer to help**

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

*Non-interactive run — defaults taken: proceeded with a full review anchored on the existing artifacts in default Full mode (the dispatch's stated default when the directive block is missing); rendered the report inline and did not persist it to disk (the skill's default unless asked); stopped after a single pass because the coach does not iterate. No `docs/arrows/index.yaml` is present, so no parse-corruption reduced-review offer applied.*