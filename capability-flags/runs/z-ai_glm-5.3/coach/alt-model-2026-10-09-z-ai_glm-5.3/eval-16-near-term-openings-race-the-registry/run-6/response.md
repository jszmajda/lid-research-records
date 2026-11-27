**LID Coach — Visit Planner**

**Posture:** Healthy design layer, coherent and current — the drift concentrates at one tenet seam and in configuration.

**Scorecard**
- ✓ Mutation hygiene — every doc reads as if authored fresh today; no changelogs, obsolete markers, or planning residue
- ✓ Spec coverage — every behavior designed in both leaves has an EARS spec; WHEN clauses disambiguate scope well (the 36-hour split is textbook)
- ✓ HLD discipline — architecture and rationale only; the four tenets are real tie-breakers with defensible opposites
- ⚠ Tenet cascade — one mechanism trades against "First asked, first served" and the exception is recorded nowhere
- ⚠ Configuration — the mode marker is present but the directive block that activates the workflow is missing
- ⚠ Scope definition — openings ingestion is named in the HLD but owned by no component

The design layer is tight — 15 well-formed EARS specs covering every designed behavior, terse but real Decisions tables, tenets that actually narrow choices. The most valuable next step is a single Decisions & Alternatives row recording the short-notice exception to first-asked-first-served, followed by `/update-lid` to anchor the workflow in CLAUDE.md.

**Findings (11 total · 2 high · 5 medium · 4 low)**
- **F1 (high):** CLAUDE.md declares `Mode: Full` but carries no directive block — nothing tells a fresh session to consult linked-intent-dev or walk the arrow for code changes · *modes are declared, not inferred* — the instruction file is the foundation every session builds on; without the directives, future sessions default to their own habits. Recommend `/update-lid` to reconcile.
- **F2 (high):** The short-notice path trades away a tenet silently — for openings ≤36 hours away, any eligible signed-in account may claim through checkout during the searchable window, so a later asker can pass an earlier interest entry, against "First asked, first served" · *tenet cascade* — leaf mechanisms should lean the way the HLD's tenets lean; when one can't, the exception is recorded, naming the tenet and why. The trade is defensible (urgent refill); the silence is the drift.
- **F3 (medium):** That same choice survives only in design prose — no Decisions & Alternatives row says why speed beats order for urgent openings or what the 20-minute scan window is for · *decision capture* — a choice a cold reader would question carries its reasoning in the row, not in the chat that produced it.
- **F4 (medium):** Openings ingestion is unowned — the HLD names a "normalized view of clinic openings" (Approach, Goal 1) and the fulfillment design assumes a "cancellation handler," but no component, LLD, or spec covers how openings and cancellations enter the system · *effective intent-tree alignment* — architecture concepts with no design node are unnamed intent that drifts silently. Give it a node or carve it out as a non-goal.
- **F5 (medium):** All 15 specs carry `[x]` markers with no declared meaning — if they track implementation they are currently false (nothing is implemented); if they mean something else, the legend lives nowhere · *docs carry current intent, written to be read cold* — a cold reader cannot resolve an unexplained status marker and may act on it.
- **F6 (medium):** A withdrawn entry holding a live offer is uncovered — intake removes withdrawn entries from matching, but no spec says whether the pending offer dies immediately or pins the opening until expiry (up to two hours on a scarce short-notice opening) · *LLDs close enough of the solution space* — open edges get filled in at implementation time, which is exactly where drift enters.
- **F7 (medium):** FILL-002's "release the opening and run matching again" doesn't say which disposition a short-notice opening returns to after offer expiry — portal search, ordered matching, or both · *LLDs close enough of the solution space* — two reasonable implementers would diverge here.
- **F8 (low):** "Exact retries" (intake design) vs INTAKE-004's key-conditioned return — a retry bearing the same idempotency key but a different payload is undefined · *coherence is adjacency* — design and spec should agree on the same trigger.
- **F9 (low):** The `FILL` prefix resolves to the fulfillment LLD only by inference; consider declaring `prefix: FILL` (and `prefix: INTAKE`) in the design docs' frontmatter so the ID→node mapping is authoritative · *specs are grep-anchored linkage* — a grep plus a declared prefix should land an agent on the owning node without guesswork.
- **F10 (low):** The thresholds (36 hours, two-hour offer, 20-minute scan) name no source — a cold reader can't tell clinic policy from placeholder; and the two-hour offer duration appears in no spec, so it's worth deciding where parameter values live · *decision capture*.
- **F11 (low):** The HLD carries no non-goals or success metrics — "refill canceled visits quickly" has no measure, and nothing says whether calendar ingestion (see F4) is in or out of scope · *HLD is architecture and rationale* — non-goals are the cheapest way a future session learns where to stop.

**What was audited**
- Read fully: the entire repository — CLAUDE.md, `docs/high-level-design.md`, both LLDs, both spec files (6 tracked files, single commit)
- Enumerated: 2 LLDs, 2 spec files, 15 EARS specs (INTAKE 7, FILL 8), 4 tenets, 8 Decisions & Alternatives rows
- Cold-read pass through all five LID docs, plus a Decisions-table sweep of all 8 rows
- Residue scan: 0 `[inferred]` markers, 0 obsolete markers, 0 history residue
- Not assessable: no code or test files exist yet, so tests-first ordering, `@spec` placement, and semantic legibility had nothing to sample; no `docs/arrows/` overlay is present, so no structural enumeration was attempted

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID for your project — where PRDs fit, mode transitions, what to do when a segment grows too large, when a decision deserves a doc rather than a row — I can help with those too.

---

*Defaults taken (non-interactive run):* dispatch landed on the "instruction file missing LID directives, but the project is LID-shaped" row, so I proceeded with the full review anchored on existing artifacts under **Full mode** (the dispatch default and the declared `- Mode: Full` marker agree). No interactive branch was reached (no `docs/arrows/index.yaml` to parse), and per the skill's advisory posture the report is rendered inline with no files edited or persisted.