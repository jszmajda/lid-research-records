**Visit Planner — LID Coach Report**

## 1. Executive summary

**Posture:** Healthy design intent, incomplete arrow — the specs are in good shape, but nothing has been built or tested yet.

**Scorecard**
- ✓ Design intent — HLD is architectural, tenets are real tie-breakers, LLDs stay at intent level
- ✗ Arrow completeness — EARS phase exists and is well-formed; Tests and Code phases are entirely absent
- ⚠ Linkage hygiene — spec IDs are clean and namespaced, but no `prefix:` frontmatter and no `@spec` annotations exist yet
- ⚠ Configuration — the instruction file declares Mode but carries no LID workflow directive
- ⚠ Decision capture — the load-bearing thresholds have no recorded trade-off
- ⚠ Tenet cascade — one near-term path contradicts a stated tenet with no recorded exception

**Headline:** The intent layer of this project is genuinely good — the HLD, tenets, and 15 specs read like a hand-off doc, not a diary. The most valuable next steps are to bring the missing test/code phases into existence and to reconcile the near-term claim path with the "first asked, first served" tenet, so the arrow becomes walkable before implementation starts shaping it.

## 2. Findings inventory

**Findings (11 total · 3 high · 5 medium · 3 low)**

- **F1 (high):** 15 specs are marked `[x]` but the repo has zero tests and zero code — the Tests and Code phases of the canonical arrow (`HLD → LLDs → EARS → Tests → Code`) are missing entirely · *canonical arrow shape — with a recursive design layer* + *intent leads; code is compiled output*
- **F2 (high):** `CLAUDE.md` declares `## LID` with a mode but contains no `linked-intent-dev` directive — nothing tells a future session the six-phase workflow exists · *modes are declared, not inferred* → run `/update-lid`
- **F3 (high):** `FILL-004` lets any eligible signed-in account claim a near-term opening by checkout, while the tenet "First asked, first served" orders by `enteredAt` — the near-term path contradicts a stated tenet, and no Decisions row records the exception · *tenet cascade*
- **F4 (medium):** The 36-hour threshold, the 2-hour offer, and the 20-minute scan are load-bearing constants with no Decisions row naming what was given up or why the numbers were chosen · *docs carry current intent, written to be read cold* (decision-capture side)
- **F5 (medium):** The word "compatible" is never defined — no rule states whether compatibility means service match, site containment, time-window containment, or all three, yet the whole matcher turns on it · *LLDs close enough of the solution space*
- **F6 (medium):** The HLD names two user paths (portal, and staff acting for patients who call) but only the authenticated-account path is specified — proxy/staff-assisted entry has no spec · *effective intent-tree alignment* + cold-read gap
- **F7 (medium):** The HLD has no Non-goals, no Target Users, no Key Design Decisions, and no Success Metrics sections — a cold reader can't tell what Visit Planner deliberately declines to do · *HLD is architecture and rationale*
- **F8 (medium):** Leaf LLDs carry no `prefix:` frontmatter, so `FILL`/`INTAKE` resolve only by filename convention, not authoritatively · *effective intent-tree alignment*
- **F9 (medium):** Every spec carries a completed status marker, which claims implementation that doesn't exist — a future reader can't distinguish live-unbuilt intent from shipped behavior · *delete obsolete specs* / *mutation, not accumulation*
- **F10 (low):** No `docs/arrows/index.yaml` overlay — reverse orphans and ID drift can't be enumerated structurally yet · *coherence is adjacency* → run `/arrow-maintenance` once code lands
- **F11 (low):** No index in `docs/intent/` — a reader landing in the directory has no map of which LLD owns which leaf prefix · *verticalize intent*
- **F12 (low):** The `## LID` block carries `Version: 1.4.0` but the block is otherwise minimal — with no directive, scope, or overlay status, a future session reads the version as configuration it cannot resolve · *modes are declared, not inferred*

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/intake/{intake-design,intake-specs}.md`, `docs/intent/fulfillment/{fulfillment-design,fulfillment-specs}.md`
- Enumerated: 2 LLDs, 2 spec files, 15 spec IDs (`INTAKE-001..007`, `FILL-001..008`), 0 code files, 0 test files, 0 `@spec` annotations (no code or tests exist to sample)
- Overlay: `docs/arrows/` not present — `index.yaml` absent, so no arrow-path sampling was possible
- History: single commit (`baedca2`), so no commit-order evidence of tests-before-code was available
- Depth: full cold-read pass over every LID doc, plus a Decisions-table sweep of all 8 rows against the HLD above them

## 4. Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

---

*Defaults taken (non-interactive run):* dispatched to a **full review** on the declared Full mode; produced the report **inline without persisting it to disk** (per the skill's report structure); read no `references/sampling.md` because the project is under 15 LLDs and has no arrow overlay; made **no file changes** — the skill's advisory posture is load-bearing, so F1–F12 are surfaced for you to apply, with F2 pointed at `/update-lid` and F10 at `/arrow-maintenance`.