# LID Coach — Visit Planner

**Posture:** Bootstrapping — design layers are solid and coherent; one real tenet tension needs resolving before implementation starts.

**Scorecard**
- ✓ Arrow shape — clean canonical HLD → LLD → EARS, no shortcuts or residue
- ✓ Linkage — IDs (`INTAKE-001…007`, `FILL-001…008`) are unique, grep-friendly, and trace to LLDs and HLD components
- ✓ HLD discipline — tenets are genuine tie-breakers with defensible opposites; no implementation detail upstream
- ⚠ Tenet cascade — the urgent-opening claim path runs against "First asked, first served"
- ⚠ LLD sufficiency — the compatibility/eligibility seam between Intake and Fulfillment is left open
- ⚠ Tests — the arrow currently ends at specs; no tests or code yet

**Headline:** This is a tight, well-linked two-component design with real tenets and almost no drift; the most valuable next step is recording the urgent-opening exception to your queue-fairness tenet — a Decisions row, five minutes, before any code exists to inherit the ambiguity.

**Findings (7 total · 2 high · 2 medium · 3 low)**
- **F1 (high):** The ≤36-hour urgent path works against a tenet — publishing the opening to portal search and letting any eligible signed-in account claim it through checkout (FILL-003/004) means a patient who asked later can win the opening ahead of an earlier interest entry, which "First asked, first served" says never happens; no row records the exception · *tenet cascade — mechanisms shouldn't quietly defeat a stated tenet under a described condition*
- **F2 (high):** The urgent-opening design choice has no decision record — the 20-minute open-claim window trading queue fairness for refill speed appears nowhere in Fulfillment's Decisions & Alternatives, so a cold reader can't reconstruct what was given up or why · *decision capture — live choices get a row, not just prose*
- **F3 (medium):** Every one of the 15 specs is marked `[x]`, but the repo contains no code or tests — if `[x]` means "specified/reviewed" rather than "implemented," nothing says so, and the markers currently claim a state that doesn't exist · *docs carry current intent — status a cold reader can't reconcile is residue*
- **F4 (medium):** "Compatible active entries" and "eligible" (FILL-001, FILL-005, FILL-006) are never defined against Intake's stored fields — service, allowed sites, time window, accessibility — so two agents implementing the matcher could land on different notions of clinical compatibility · *LLDs close enough of the solution space — open edges are where intent drift enters*
- **F5 (low):** The arrow ends at specs — no tests or code yet; when implementation starts, write tests first and cite spec IDs with `@spec` annotations so the arrow stays walkable · *tests before code*
- **F6 (low):** Fulfillment owns several separable concerns (matching/offers, urgent publish-and-claim, transactional claim + outbox, event log) around one shared opening state machine — fine at this size, but consider whether it becomes a sub-HLD as it grows · *one LLD per intent component — or split when it outgrows one node*
- **F7 (low):** INTAKE-006's "create a newly timed entry" asks the reader to guess that the replacement gets a fresh `enteredAt` — one clarifying phrase would pin it · *docs carry current intent, written to be read cold*

**What was audited**
- Read fully: every project file — `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files
- Enumerated: 2 LLDs, 15 specs (7 INTAKE, 8 FILL), 0 code/test files (none exist), 1 commit of history
- No `@spec` annotations to sample (no code); no `docs/arrows/` overlay, so no structural enumeration was attempted

**Defaults taken (non-interactive run):** Full mode was already declared, so the full review proceeded with no dispatch default needed; the report is rendered inline rather than persisted, and — per the skill's advisory posture — no files were changed, even though you offered; apply fixes directly or via `/update-lid` for configuration items. F1/F2's remedy is a fuller Decisions & Alternatives row (or a short decision doc if you want the trade-off on the record); F3's is either unchecking the boxes or stating what `[x]` means.

Want me to walk through any of these findings in detail, or draft the Decisions-row language for F1/F2? If you have broader questions about using LID here — where PRDs fit, mode transitions, or how to sequence tests-first when implementation begins — I can help with those too.