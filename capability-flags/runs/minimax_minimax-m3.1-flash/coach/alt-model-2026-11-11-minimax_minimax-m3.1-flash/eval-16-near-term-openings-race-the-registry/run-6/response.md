# Visit Planner — LID Coaching Report

## 1. Executive summary

**Posture:** *Healthy design spine; the arrow stops at EARS and the configuration layer is thin.*

**Scorecard**
- ✓ Design spine — HLD, two leaf LLDs, and specs that line up cleanly with the HLD's two components
- ✗ Arrow completeness — the arrow terminates at EARS; no tests, no code, yet every spec is marked implemented
- ⚠ Cascade / tenet coherence — the HLD's most prominent tenet is contradicted by the near-term fulfillment path, with no exception recorded
- ⚠ Decision capture — the project's two most load-bearing thresholds are absent from every Decisions table and from the HLD
- ⚠ HLD discipline — Full-mode HLD is missing four standard sections, including Key Design Decisions
- ⚠ Configuration — the instruction file declares mode and version but carries no LID directives

**Headline:** The intent spine here is genuinely well-formed — a tight HLD with real tie-breaker tenets, two cleanly scoped LLDs, and 15 specs that trace to their design docs; the fastest wins are reconciling the spec status markers with the fact that no implementation exists, recording the 36-hour/20-minute decisions, and running `/update-lid` to restore the directive layer.

---

## 2. Findings inventory

**Findings (14 total · 4 high · 7 medium · 3 low)**

- **F1 (high):** instruction file declares `## LID` (Mode: Full, Version: 1.4.0) but carries no "Linked-Intent Development" directive block, navigation table, or terminology section · *modes are declared, not inferred* / *minimum surface, maximum discipline* → run `/update-lid`
- **F2 (high):** all 15 specs are marked `[x]` (implemented) while the repo contains zero code and zero test files · *canonical arrow shape* + *tests before code* — the arrow stops at EARS while the markers claim the phase after it
- **F3 (high):** HLD tenet "First asked, first served" is violated by the ≤36-hour publish-and-claim path (FILL-003/FILL-004), with no exception recorded anywhere · *tenet cascade*
- **F4 (high):** the 36-hour threshold and the 20-minute delayed scan — the most question-worthy choices in the system — appear only as prose in `fulfillment-design.md`, with no Decisions row and no HLD Key Design Decisions section · *decision capture*
- **F5 (medium):** neither LLD carries the `parent:` / `prefix:` frontmatter; `FILL-*` does not resolve to the `fulfillment/` leaf by name · *effective intent-tree alignment*
- **F6 (medium):** the two-hour offer window exists only in LLD prose; no EARS captures offer duration · *coherence is adjacency*
- **F7 (medium):** "eligible signed-in account" and "patient eligibility" are used in FILL-004/FILL-006 but defined nowhere; the staff-on-behalf-of-patient path named in the HLD has no spec · *semantic legibility* + *scope disambiguation*
- **F8 (medium):** the openings/schedule domain the HLD Approach names ("a normalized view of clinic openings") and that Fulfillment depends on has no owning intent component, LLD, or specs · *effective intent-tree alignment*
- **F9 (medium):** Full-mode HLD omits Target Users, Non-Goals, System Design, and Success Metrics · *HLD is architecture and rationale*
- **F10 (medium):** FILL-001 selects the "compatible **active** entry" while FILL-005 selects the "compatible entry" — an implementer reading FILL-005 alone could offer a withdrawn entry · *scope disambiguation*
- **F11 (medium):** the four HLD tenets are unranked, and "First asked, first served" versus "Clinical fit precedes utilization" has no stated precedence · *tenets capture forward-looking preference*
- **F12 (low):** INTAKE-002 uses the unwanted-behavior pattern without "then" · *EARS format*
- **F13 (low):** informal terms — "the matcher," "the registry scan," "the delayed scan," "the transaction" — are used without definition on first reference · *semantic legibility*
- **F14 (low):** LLDs lack `Open Questions & Future Decisions` and `References` sections; the HLD's `## Components` list is doing double duty as its System Design · *HLD discipline*

---

## 3. What was audited

- **Read fully:** `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/intake/intake-design.md`, `docs/intent/intake/intake-specs.md`, `docs/intent/fulfillment/fulfillment-design.md`, `docs/intent/fulfillment/fulfillment-specs.md`
- **Enumerated:** 2 leaf LLDs, 2 spec files, 15 EARS specs (7 `INTAKE-*`, 8 `FILL-*`), 6 tracked files total
- **Code/test sampling:** the repository has no source or test files — `git ls-files` returns the 6 documentation files only, and `grep` finds 0 `@spec` annotations anywhere
- **Overlay:** `docs/arrows/` and `docs/arrows/index.yaml` are absent, so no arrow-maintenance index was available; no structural enumeration was attempted
- **Sampling depth:** the project is below the threshold for `references/sampling.md` (2 LLDs, no overlay), so the review is exhaustive rather than sampled — every LID doc received a cold-read pass

---

## 4. Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

---

*Defaults taken for this run:* Full-mode review (declared in the instruction file), advisory posture — **no project files were created or modified**; the report is inline and unsaved, per the skill's advisory/no-edit stance. Structural candidates (F5, F8) are surfaced as patterns only, not enumerated; `/arrow-maintenance` would be the right instrument if you want them counted precisely.