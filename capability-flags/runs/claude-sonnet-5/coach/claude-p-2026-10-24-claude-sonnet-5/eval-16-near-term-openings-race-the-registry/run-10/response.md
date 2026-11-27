## LID Coach review — Visit Planner

**Posture:** Clean, well-linked design-stage arrow — with one tenet the fulfillment mechanism quietly works against.

**Scorecard**
- ✓ LLD granularity — Intake and Fulfillment each own exactly one LLD, matching the HLD's component list with no overlap
- ✓ Linkage hygiene — `INTAKE-NNN` / `FILL-NNN` IDs are zero-padded, grep-friendly, and collision-free
- ✓ Decision capture — both Decisions & Alternatives tables hold up under a cold read, except one gap (see F3)
- ⚠ Configuration — the `## LID` block declares Mode and Version but never states the LID directive itself
- ✗ Tenet cascade — the near-term cancellation path runs against the HLD's own "first asked, first served" tenet, with no record of the trade-off

**Headline:** The two-component split is tight and the specs trace cleanly to their LLDs and the HLD — that structure is exactly what later phases (tests, code) will hang off cleanly. The highest-value next step is reconciling `FILL-003`/`FILL-004` against the "first asked, first served" tenet before implementation locks the current behavior in.

**Findings (5 total · 3 high · 1 medium · 1 low)**
- **F1 (high):** `CLAUDE.md`'s `## LID` block has a Mode/Version marker but no directive language identifying the project as linked-intent-dev · *modes are declared, not inferred* — worth a pass through `/update-lid` to reconcile.
- **F2 (high):** For openings ≤36 hours out, `FILL-004` lets any eligible signed-in account claim through checkout as soon as it's published — not ordered by `enteredAt` — which runs against the HLD tenet "first asked, first served" (an earlier request can be passed by a later one, or by someone who never submitted an intake entry at all) · *tenet cascade* — the HLD and the Fulfillment design don't share wording, but the condition (a near-term cancellation with multiple waiting patients) is exactly where the tenet bites.
- **F3 (high, companion to F2):** That same trade-off — queue order traded for speed/availability — has no row in Fulfillment's Decisions & Alternatives table naming what was given up or why · *docs carry current intent* (decision-capture side) — a cold reader holding the HLD's tenets would still want to question this choice.
- **F4 (medium):** The HLD covers Problem, Approach, Tenets, Goals, and Components, but has no Non-Goals or Success Metrics section that might have pre-empted the F2/F3 ambiguity by stating how speed and ordering are meant to balance · *HLD is architecture and rationale*.
- **F5 (low):** "eligible signed-in account" in `FILL-004` isn't defined — unclear whether it requires an existing Intake entry or admits any signed-in patient · *LLDs close enough of the solution space*.

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`intake-design.md`, `fulfillment-design.md`), both spec files (`intake-specs.md`, `fulfillment-specs.md`)
- Enumerated: 2 LLDs, 2 spec files, 15 EARS specs (7 Intake, 8 Fulfillment)
- No `docs/arrows/` overlay, and no code or test files exist yet — this is a design-only arrow so far (HLD → LLDs → EARS), which is normal for a project that hasn't started implementation and wasn't flagged as a gap
- Non-interactive note: since this run can't ask follow-up questions live, the dispatch default (full review anchored on existing LID-shaped artifacts) and the "no code yet" state were both treated as expected bootstrapping rather than findings

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.