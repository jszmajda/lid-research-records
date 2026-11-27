# LID Coach — Visit Planner

**Posture:** Solid intent foundation; the arrow ends at EARS, with configuration wiring and one unrecorded tenet trade to close.

**Scorecard**
- ⚠ Configuration — `## LID` declares Mode: Full but carries no `linked-intent-dev` directives
- ✗ Tenet cascade — same-day checkout runs against the FIFO tenet, with no exception recorded
- ⚠ Intent-tree alignment — several LLD behaviors have no spec to test against
- ⚠ Cold-read clarity — undefined terms and one retry-semantics mismatch
- ✓ Linkage — 15 unique, grep-anchored IDs, each tracing to a leaf LLD
- ✓ Tenets — four real tie-breakers with defensible opposites

**Headline:** The design tree is small, coherent, and unusually well-filled in — two leaf LLDs matching the HLD's components, every one carrying a Decisions table with accepted costs. The fastest wins are recording the same-day checkout trade and wiring LID's directives into `CLAUDE.md`.

**Findings (12 total · 4 high · 5 medium · 3 low)**
- **F1 (high):** `CLAUDE.md`'s `## LID` block declares Mode and version but no `linked-intent-dev` directive, so the workflow skill isn't wired into the project's instructions — run `/update-lid` to reconcile · *modes are declared, not inferred* — the instruction file is the one place LID setup should be declared
- **F2 (high):** for openings ≤36h out, the first checkout claimant wins while earlier interest-holders wait for the 20-minute scan — under that described condition a patient's earlier request *is* passed by a later one, against the "First asked, first served" tenet, with no recorded exception · *tenet cascade* — leaf mechanisms should lean the way the HLD's tenets and goals say to lean
- **F3 (high):** that publish-and-claim choice for same-day cancellations has no Decisions row at all — a cold reader would question it and can't reconstruct what was given up or what cost was accepted · *decision capture* — a live decision belongs in a full row, not only in design prose
- **F4 (high):** "compatible" and "patient eligibility" — the matcher's central predicate — are never defined in the HLD or either LLD, so two agents could land on different matching rules · *LLDs close enough of the solution space* — open edges are exactly where guessing and drift enter
- **F5 (medium):** the arrow currently stops at EARS — no tests or code exist yet; when implementation starts, writing tests first that cite the 15 IDs keeps the walk intact · *tests before code* and *canonical arrow shape* (HLD → LLD → EARS → Tests → Code)
- **F6 (medium):** LLD behaviors with no spec: the two-hour offer window, the row-lock/one-transaction claim, and the "typed fields" (no free-text) rule · *effective intent-tree alignment* — behavior with no spec is unnamed intent with nothing to test against
- **F7 (medium):** the 36-hour split, 20-minute scan delay, and 2-hour offer carry no recorded rationale · *decision capture* — a cold reader can't tell a deliberate threshold from a placeholder
- **F8 (medium):** the intake LLD says "exact retries" while INTAKE-004 and its Decisions row say "idempotency key"; the same-key-different-payload case is unresolved · *docs carry current intent* — written to be read cold
- **F9 (medium):** "registry", "checkout", and "portal search" appear without introduction anywhere in the doc tree · *docs carry current intent* — a fresh reader shouldn't need the conversation that produced the doc
- **F10 (low):** all 15 specs carry `- [x]` with no legend — "authored" vs "implemented" is unreadable, and there's no code yet · *docs carry current intent*
- **F11 (low):** leaf LLDs declare no `prefix:` frontmatter, and `FILL-` abbreviates `fulfillment` — declaring the mapping keeps ID→node resolution authoritative · *specs are grep-anchored linkage*
- **F12 (low):** the HLD has no Non-goals or Success metrics sections · *HLD is architecture and rationale*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files — the entire repo (6 tracked files, 70 doc lines)
- Enumerated: 2 LLDs, 2 spec files, 15 spec IDs (INTAKE-001…007, FILL-001…008), 0 ID collisions, 8 Decisions rows reviewed
- No `docs/arrows/` overlay present; no code or tests exist, so `@spec` annotation sampling had nothing to sample (0 annotations)
- Dispatch: instruction file missing LID directives but the project is LID-shaped → full review anchored on the existing artifacts, treating the declared Full mode as authoritative
- Non-interactive run — skill defaults taken: Full-mode review, report rendered inline (not persisted to disk), and no file edits made (advisory posture; `/update-lid` is the application path for F1)

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.