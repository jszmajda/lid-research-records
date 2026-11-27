**LID Coach review — Shelfwise**

**Executive summary**

*Posture: Healthy, design-complete — arrow stops at EARS, with a light configuration and coherence tidy-up.*

**Scorecard**
- ✓ HLD discipline — architecture-level *why* only; no schema or signature bleed
- ✓ LLD granularity — one clean leaf per intent component, no lumping or scatter
- ✓ Tenets — four real tie-breakers with defensible opposites; sequencing conflict already captured
- ✓ Mutation hygiene — all docs read as current intent; no history residue or obsolete markers
- ⚠ Linkage — spec IDs sound, but leaf prefixes are abbreviated and undeclared
- ⚠ Configuration — `## LID` marker present, but the instruction file carries no LID directive block

The design layer is genuinely well-built: two coherent intent components, 15 clean EARS specs, and a Decisions table that already names the tenet/goal it trades against. The fastest wins are reconciling the instruction file and tightening the pickup-notices sequencing ambiguity.

**Findings (5 total · 1 high · 3 medium · 1 low)**

- **F1 (high):** `CLAUDE.md` has the `## LID` mode marker but no LID directive block (nothing referencing the workflow) · *modes are declared, not inferred* — recommend `/update-lid` to reconcile.
- **F2 (medium):** the arrow stops at EARS — no tests, no code for either component · *canonical arrow shape* — expected at design stage, but when implementation starts, write tests before code so the API shape is fixed by consumers.
- **F3 (medium):** `pickup-notices-design.md:11` reads as if the hold closes and reallocates *at lapse*, while its own Decisions row and `PICKUP-004`/`PICKUP-005` put closure and reallocation at *staff-pull* time · *LLDs close enough of the solution space* + *coherence is adjacency*.
- **F4 (medium):** spec prefixes abbreviate rather than match leaf names (`HOLDALLOC` vs `hold-allocation`; `PICKUP` vs `pickup-notices`) and neither LLD declares a `prefix:` frontmatter · *specs are grep-anchored linkage* — declare the prefix so the path/facet split is unambiguous.
- **F5 (low):** instruction file is `CLAUDE.md`; if this project runs under opencode, `AGENTS.md` is the convention · *modes are declared, not inferred*.

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files
- Enumerated: 2 LLDs, 2 spec files, 15 EARS specs (8 hold-allocation, 7 pickup-notices)
- No code or test files exist in the repo; 0 `@spec` references; no `docs/arrows/` overlay
- Cold-read pass run over all five LID docs; one ambiguity surfaced (F3)

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

---

Defaults taken for this non-interactive run: proceeded with a **Full review** (project is LID-shaped, so coaching applies despite the missing directive block); **no fixes applied** (coach is advisory); **no report persisted to disk**; capability-flag section omitted because the flags table is empty.