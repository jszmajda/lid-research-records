# LID Coach — Visit Planner

**Posture: Solid design, healthy docs — the implementation layer and one tenet-mechanism conflict need attention.**

**Scorecard**
- ✓ Arrow shape — one HLD → two leaf LLDs → EARS, correctly depth-2, no lumping or stray phases
- ✓ EARS & linkage — every spec names a trigger; IDs unique, zero-padded, grep-friendly
- ⚠ Cascade coherence — the ≤36-hour mechanism works against the "first asked, first served" tenet
- ⚠ Decision capture — the load-bearing thresholds live only in prose, with no row behind them
- ⚠ Configuration — mode is declared, but the instruction file has no directive block
- ✓ Doc hygiene — no change-narration, no obsolete markers, no conversational fossils; docs read cold

**Headline:** The intent layer is genuinely well-built — clean tree, disciplined EARS, zero residue — and the fastest wins are fixing the spec status markers against a repo that has no code yet, and resolving the one place a tenet and a mechanism disagree.

## Findings (10 total · 3 high · 4 medium · 3 low)

- **F1 (high):** `CLAUDE.md` carries a `## LID` block (Mode, Version) but no directive block naming the `linked-intent-dev` skill — a future session has no instruction to walk the arrow · *modes are declared, not inferred* — the declaration is what makes the mode visible; run `/update-lid` to reconcile
- **F2 (high):** all 15 specs are marked `[x]` (implemented), yet the repo contains zero code files, zero test files, and zero `@spec` annotations — the markers assert a phase that does not exist · *intent leads; code is compiled output* — the status markers are the link's most-read surface, and a wrong one sends agents looking for code that was never written
- **F3 (high):** the tenet "First asked, first served" is defeated under a described condition — FILL-004 lets any eligible signed-in account claim a ≤36-hour opening during the 20-minute searchable window, ahead of the least-`enteredAt` offer in FILL-005 — and no Decisions row names the tenet traded against · *tenets capture forward-looking preference* — a tenet a cold session can't see honored will be applied from intuition
- **F4 (medium):** the 36-hour threshold, the 20-minute scan delay, and the 2-hour offer window appear only in `fulfillment-design.md` prose; the 2-hour offer window additionally has no spec of its own (FILL-002 covers expiry but not the duration) · *docs carry current intent, written to be read cold* — a threshold with no captured reasoning is re-decided on the next implementation pass
- **F5 (medium):** "compatible entry" and "eligible account" are used throughout both LLDs and both spec files but never defined — service/site/time matching criteria and patient eligibility are left open · *LLDs close enough of the solution space* — the matching rules are exactly the edges an implementer will fill in from its own prior
- **F6 (medium):** "registry scan" (`fulfillment-design.md:9`, FILL-003, FILL-005) names a component that exists nowhere in the HLD, the component list, or any spec · *docs carry current intent* — an undefined referent is a conversation-only artifact on the page
- **F7 (medium):** the HLD omits Target Users, Non-Goals, System Design, Key Design Decisions, and Success Metrics — in Full mode those sections are expected to be filled · *HLD is architecture and rationale* — Non-Goals and Success Metrics are the two that stop a future session from drifting or from shipping the wrong win
- **F8 (medium):** neither LLD carries `parent:`/`prefix:` frontmatter, and the fulfillment leaf's namespace `FILL` does not match its node name `fulfillment` — `grep FULFILLMENT` returns nothing · *specs are grep-anchored linkage* — prefix frontmatter is the declared bridge from human name to namespace
- **F9 (low):** the four tenets are an unordered list even though at least two can compete (first-asked ordering vs. whoever completes checkout) · *tenets capture forward-looking preference* — ordering is what tells a session which one wins
- **F10 (low):** spec lines omit the colon after the ID (`**INTAKE-001** When …` rather than `**INTAKE-001**: When …`) · *specs are grep-anchored linkage* — cosmetic against a grep, but off-convention against the EARS format
- **F11 (low):** INTAKE-006's "create a newly timed entry" is ambiguous — it is unclear whether the new entry inherits the old window or takes a new one · *docs carry current intent* — a spec a cold reader has to guess at will be implemented two ways

## What was audited
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/intake/{intake-design,intake-specs}.md`, `docs/intent/fulfillment/{fulfillment-design,fulfillment-specs}.md`
- Consulted for convention baseline: the EARS syntax reference and the HLD/LLD templates from the `linked-intent-dev` skill
- Enumerated: the complete working tree — 6 tracked files, 1 commit; 2 LLDs, 2 spec files, 15 specs (7 `INTAKE-*`, 8 `FILL-*`), 0 code files, 0 test files, 0 `@spec` annotations
- Overlay: `docs/arrows/` is absent, so no arrow-path sampling was possible and structural findings are limited to what a full read of the design tree showed
- Not assessable from this repo: cascade health across code/test seams, entry-point `@spec` placement, and semantic legibility in code (no code exists yet)

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

*Defaults taken in this non-interactive run:* the coach's advisory posture held — no project files were edited and the report was rendered inline rather than persisted to disk (fixes belong to you, or to `/update-lid` for configuration and `/arrow-maintenance` for structural work); dispatch took the Full-mode review branch, since `## LID` declares `Mode: Full`; and F1/F8 are pointed at `/update-lid` and F2's absence-of-code framing at the arrow's implementation phase rather than at `/arrow-maintenance`, since no arrow overlay is installed.