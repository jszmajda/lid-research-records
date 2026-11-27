# LID Coach — Shelfwise

**Posture:** Solid, well-linked design with two coherence gaps — configuration and a tenet conflict. The design layer is clean and disciplined; the drift is in how one allocation rule sits against your own tenets, and in the instruction file's incomplete LID block.

**Scorecard**
- ✓ Arrow (design phases) — HLD → LLDs → EARS present and traceable; tests/code not yet started
- ✓ Mutation hygiene — no history residue, `[obsolete]` markers, or changelog text anywhere
- ✓ HLD discipline & EARS format — architecture-level HLD, clean EARS patterns (`When`/`If…then`/`While`)
- ⚠ Configuration — `## LID` block has a mode marker but no LID directive block
- ⚠ Tenet cascade — branch-local allocation works against "Waiting is honored in sequence"
- ⚠ Decision capture — the local-first rule has no Decisions & Alternatives row

**Findings (5 total · 2 high · 2 medium · 1 low)**
- **F1 (high):** `CLAUDE.md` declares `## LID` / `Mode: Full` but carries no LID directive block (`linked-intent-dev` absent) · *modes are declared, not inferred*
- **F2 (high):** branch-local allocation lets a later hold jump an older county-wide hold, contradicting the "Waiting is honored in sequence" tenet with no recorded exception · *tenet cascade*
- **F3 (medium):** the local-first allocation choice lives only in design prose, with no row in Hold Allocation's Decisions & Alternatives · *decision capture*
- **F4 (medium):** every spec is marked `[x]`, but no legend says what the marker means (active? approved? implemented?) and there is no code · *docs carry current intent*
- **F5 (low):** Tests and Code phases are entirely absent — expected for a design-stage project, but the arrow stops at EARS · *canonical arrow shape*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`hold-allocation-design.md`, `pickup-notices-design.md`) and both spec files
- Enumerated: 2 LLDs, 13 EARS specs (7 `HOLDALLOC-*`, 6 `PICKUP-*`), 2 HLD components
- No `docs/arrows/` overlay, no `@spec` annotations, no code or tests to sample; git history is a single `fixture` commit
- Cold-read pass run over every LID doc; no `[inferred]`, `obsolete`, `TODO`, or `FIXME` residue found

**Worth a second look:** models configured like me are known to miss designs that contradict the project's own tenets. Please check the leaf designs against your HLD tenets yourself — I've flagged one instance (F2), but confirm it independently.

**Offer to help**

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

*Run defaults taken (non-interactive): Full mode (as declared); proceeded with a full review per the LID-shaped-artifacts dispatch branch; no arrow overlay present; report rendered inline and not persisted to disk.*