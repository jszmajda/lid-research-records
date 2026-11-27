## LID Coach — Review of Shelfwise

**Posture:** Bootstrapping — the arrow's design layer is in place and coherent; downstream phases (tests, code) are not yet built, and a few seams need tightening before they are.

**Scorecard**
- ✓ Mutation hygiene — docs read clean and present-tense; no changelog residue or `[obsolete]` leftovers
- ✓ Decision capture — both LLDs' Decisions & Alternatives rows name options and accepted costs well
- ⚠ Configuration — `CLAUDE.md` has the `## LID` marker but no LID directives block
- ⚠ Arrow completeness — specs are marked implemented, but Tests and Code phases are empty
- ⚠ Tenet alignment — the allocation rule leans against the HLD's "waiting honored in sequence" tenet
- ⚠ Intent-tree alignment — LLDs carry no `parent:`/`prefix:` frontmatter to bridge spec prefix ↔ node

**Headline:** The design layer is small, readable, and well-reasoned; the highest-value next steps are reconciling the spec status markers with the absent code/tests and recording the one tenet the branch-local allocation rule trades against.

**Findings (8 total · 3 high · 3 medium · 2 low)**
- **F1 (high):** `CLAUDE.md` has only the `## LID` block — no LID directives body, navigation table, or annotation guidance (and no canonical `AGENTS.md` + `CLAUDE.md` alias) · *modes are declared, not inferred* / configuration
- **F2 (high):** all 13 specs are marked `[x]` (implemented) but the repo contains no code and no tests · *tests before code*, *coherence is adjacency*
- **F3 (high):** branch-local allocation (`HOLDALLOC-003`) lets a newer hold at the scanning branch beat an older county-wide hold, working against the HLD tenet "Waiting is honored in sequence," with no recorded exception · *tenet cascade*
- **F4 (medium):** leaf LLDs carry no `parent:`/`prefix:` frontmatter, and the `PICKUP` spec prefix diverges from the `pickup-notices` node name, leaving the leaf↔spec bridge ambiguous · *effective intent-tree alignment*
- **F5 (medium):** the HLD omits several Full-mode standard sections — Target Users, Non-Goals, System Design, Key Design Decisions, Success Metrics · *HLD is architecture and rationale* (coverage)
- **F6 (medium):** cancellation of an allocated copy that is already on a holds shelf (not in transit) is unspecified — only the in-transit case is covered (`HOLDALLOC-007`, `PICKUP-005`) · *LLDs close enough of the solution space*
- **F7 (low):** `PICKUP-005`/`HOLDALLOC-007` reference the other segment's allocation behavior with no inline context · *scope disambiguation*
- **F8 (low):** tenet "Hold history is not kept" reads as an already-made decision rather than a forward-looking tie-breaker · *tenets capture forward-looking preference*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both `-design.md` files, both `-specs.md` files (the entire repository)
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 13 EARS specs (7 `HOLDALLOC-*`, 6 `PICKUP-*`)
- Linkage metric: 0 `@spec` references, 0 test files, 0 code files
- Overlay: no `docs/arrows/` and no `docs/decisions/` present
- Sampling: exhaustive — project is below the sampling thresholds (<15 LLDs, no `index.yaml`)

**Offer to help**

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

---
*Non-interactive run — no questions were posed. Defaults taken: proceeded with a full review per the dispatch table (LID directives missing but LID-shaped artifacts present); treated absent flags as "no capability flag applies" (the flags file lists none); omitted the out-of-scope section (Full mode); and did not persist the report to disk or edit any files (advisory posture).*