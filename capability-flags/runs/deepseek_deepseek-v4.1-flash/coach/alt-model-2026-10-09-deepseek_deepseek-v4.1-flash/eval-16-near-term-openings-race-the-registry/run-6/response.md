**LID Coach review — Visit Planner**

**Executive summary**

*Posture: Solid foundations, with a configuration gap and one live design/tenet tension to resolve.*

**Scorecard**
- ✓ **HLD discipline** — architecture-and-rationale throughout; no schemas, signatures, or pseudocode bleeding upstream
- ✓ **Tenet quality** — four real tie-breakers, each with a defensible opposite
- ✓ **Mutation hygiene** — no history residue; specs are all current, none obsolete-tagged
- ⚠ **Configuration** — the instruction file declares a mode but carries no LID directive block
- ⚠ **Tenet cascade** — the same-day checkout path works against the project's own "first asked, first served" tenet
- ⚠ **Decision capture** — the same-day claim policy and the 36h/20-min thresholds have no Decisions row

The HLD and both LLDs are cleanly architecture-level and the tenets are genuine tie-breakers — this is a real arrow, not boilerplate. The highest-value next steps are reconciling the instruction file and resolving the same-day checkout path against "first asked, first served."

**Findings (7 total · 3 high · 2 medium · 2 low)**
- **F1 (high):** `CLAUDE.md` has a `## LID` block with `- Mode: Full` but no LID directive content (no reference to the `linked-intent-dev` workflow) · *modes are declared, not inferred* (the declared foundation should be visible and complete) → run `/update-lid`
- **F2 (high):** Fulfillment's rule that "any eligible signed-in account may complete checkout while [a ≤36h opening] is searchable" lets a later-asking (or never-asking) account claim ahead of the earliest requester — directly against the HLD tenet *"First asked, first served… an earlier request is never passed by one made after it"* under the same-day-cancellation condition, with no exception recorded · *tenet cascade* (check mechanisms against your own tenets even when the words don't match)
- **F3 (high):** The same-day publish-and-claim policy, plus the 36-hour cutoff and 20-minute scan, are consequential choices not captured anywhere in a Decisions & Alternatives table · *docs carry current intent* / *decision capture* (a cold reader can't reconstruct what was traded for the first-asked guarantee)
- **F4 (medium):** The arrow currently stops at EARS — no Tests and no Code phase exists, so no `@spec` annotations anchor the specs to behavior · *canonical arrow shape* / *tests before code* (the use of the system never enters the context window before implementation)
- **F5 (medium):** The Fulfillment LLD owns two cancellation regimes (scheduled matching >36h vs. publish-and-scan ≤36h) that share the opening model but have separable behavior — a possible sub-HLD promotion candidate · *one LLD per intent component*
- **F6 (low):** Spec prefix `FILL` doesn't match its leaf node name `fulfillment` (and no `prefix:` frontmatter disambiguates) · *specs are grep-anchored linkage* (a grep for the design node won't cleanly land on its specs)
- **F7 (low):** The four tenets are listed unordered even though "First asked, first served" and "Clinical fit precedes utilization" can pull against each other · *tenets capture forward-looking preference* (ordering the ones that can conflict helps a cold reader)

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, and the design + spec files under `docs/intent/intake/` and `docs/intent/fulfillment/`
- Enumerated: 2 LLDs, 2 spec files, 15 specs (7 `INTAKE-*`, 8 `FILL-*`)
- Code/test sample: none exists — 0 files carry `@spec` annotations; the review is exhaustive by virtue of the project's size
- No arrow-maintenance overlay present; Full mode, so no scope exclusions

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — where tests-first fits when you're still docs-only, mode transitions, what to do when a segment grows too large, or where a decision like the 36-hour rule should be recorded — I can help with those too.

**Defaults taken (non-interactive run):** dispatched to a full review (LID-shaped project, default Full mode); treated the missing directive block as a configuration finding rather than refusing to coach; made no file changes (advisory posture — recommendations surfaced, not applied); produced the report inline and did not persist it to disk.