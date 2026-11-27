## LID Coach — Visit Planner

### Executive summary

**Posture:** Strong intent layer; the arrow stops at specs, and the near-term fast path leans against a tenet.

**Scorecard**
- ✓ **Mutation hygiene** — both design docs and both spec files read as current intent; no changelogs, no `[obsolete]` residue, no planning text
- ✓ **Tenet quality** — four real tie-breakers with defensible opposites, not platitudes
- ⚠ **Configuration** — `## LID` block carries Mode and Version but no `linked-intent-dev` directive text
- ⚠ **Intent-tree alignment** — an HLD goal and two LLD behaviors have no node or spec that owns them
- ⚠ **Decision capture** — the fast-path policy and the `enteredAt`-preservation rules land with no Decisions row
- ✗ **Arrow completeness** — no tests and no code exist, yet every spec is marked `[x]`

**Headline:** The design layer here is genuinely good — the tenets are sharp enough to adjudicate real decisions, the specs are clean EARS with stable zero-padded IDs, and the docs read cold without any conversational residue. The fastest wins are reconciling the instruction file, deciding what `[x]` is meant to assert while the Tests and Code phases are still empty, and recording the near-term-cancellation policy as a decision, since it currently works against *first asked, first served* without saying so.

### Findings (14 total · 5 high · 7 medium · 2 low)

- **F1 (high):** `CLAUDE.md`'s `## LID` block declares Mode and Version but contains no LID directive text — nothing tells a fresh session to run the cascade · *modes are declared, not inferred* (an unread mode is just a default) → `/update-lid`
- **F2 (high):** The arrow runs `HLD → LLDs → EARS` and stops; no tests or code exist in the repo, yet all 15 specs carry `[x]` · *canonical arrow shape*, *coherence is adjacency* (each level should agree with its neighbor)
- **F3 (high):** `FILL-003`/`FILL-004` let any eligible signed-in account claim a ≤36-hour opening during the 20-minute window, which can pass over an earlier-asked entry — no Decisions row names the tenet traded against · *tenets capture forward-looking preference* (the HLD's "an earlier request is never passed by one made after it")
- **F4 (high):** The whole fast path — the 36-hour boundary, the 20-minute `notBefore`, the choice to open search at all — has no Decisions & Alternatives row in `fulfillment-design.md` · *docs carry current intent* (a cold reader would still question and want to reverse this)
- **F5 (high):** HLD Goals promise "one view of routine primary-care openings and ownership," but Components lists only Intake and Fulfillment; no design node owns opening ingestion or the normalized calendar view · *effective intent-tree alignment*
- **F6 (medium):** "Compatible active entries" is the matcher's central predicate and is never defined in either LLD or any spec — two agents would close that edge differently · *LLDs close enough of the solution space*
- **F7 (medium):** Offer lifecycle has open edges: the two-hour window lives only in `fulfillment-design.md:7` prose with no spec, there is no spec for a patient *accepting* an offer, and expiry behavior on the ≤36-hour path is unstated · *effective intent-tree alignment* (LLD behaviors with no spec)
- **F8 (medium):** Staff-assisted entry appears in the HLD Approach and `intake-design.md:4`, but `INTAKE-001` scopes creation to "an authenticated account submits" and no entry field records who acted · *scope disambiguation*, *effective intent-tree alignment*
- **F9 (medium):** Intake stores accessibility needs (`INTAKE-005` even protects them on change), but no fulfillment spec or design text matches on them · *coherence is adjacency*
- **F10 (medium):** "Registry scan" in `fulfillment-design.md:9` and `FILL-003` names a thing Intake never introduces — Intake calls them "interest entries" · *semantic legibility as cheap linkage*
- **F11 (medium):** `INTAKE-005`/`INTAKE-006` make site and accessibility changes keep queue position while a service change forfeits it — load-bearing for *first asked, first served*, with no Decisions row · *docs carry current intent*
- **F12 (medium):** Neither spec file carries `prefix:` frontmatter, and `FILL-*` doesn't match its `fulfillment/` leaf — prefix resolution is by inference · *specs are grep-anchored linkage*
- **F13 (low):** HLD has no Target users, Non-goals, or Success metrics; "refill canceled visits quickly" has no stated target · *HLD is architecture and rationale*
- **F14 (low):** The four tenets are an unordered list, though *first asked, first served* and *clinical fit precedes utilization* can pull against each other on a scarce opening · *tenets capture forward-looking preference*

### What was audited

- **Read fully:** `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/intake/intake-design.md`, `docs/intent/intake/intake-specs.md`, `docs/intent/fulfillment/fulfillment-design.md`, `docs/intent/fulfillment/fulfillment-specs.md` — the entire LID surface, plus a full file enumeration of the repo
- **Enumerated:** 2 LLDs, 2 spec files, 15 specs (7 `INTAKE-*`, 8 `FILL-*`), 2 Decisions & Alternatives tables (8 rows total), 0 sub-HLDs
- **Linkage metric:** 0 `@spec` annotations, 0 test files, 0 source files — the repo is docs-only at this commit
- **Arrow-path sampled:** both segments walked top-down (HLD section → LLD → spec); both terminate at the EARS phase
- **Not present:** `docs/arrows/` overlay (no structural audit available), `[inferred]` markers (no brownfield triage needed)
- **Cold-read pass:** completed across all four LID docs; no change-narration, in-conversation-only meaning, or conversational fossils found — F10 is the only unresolvable-vocabulary hit
- **Dispatch note:** `CLAUDE.md` lacks the LID directive text, but the project is clearly LID-shaped (populated HLD, two LLDs, two spec files), so this ran as a **full review** anchored on the artifacts, in **Full** mode as declared — the skill's stated default for that state. No prompts were needed; nothing was edited.

---

Want me to walk through the findings in detail, focus on a theme or priority band, or work through specific items together? F3 and F4 are the pair I'd start with — they're the same choice seen from two angles, and the fix for one makes the other easier.

If you have broader questions about using LID on this project — when the Tests and Code phases should start carrying `@spec` annotations, whether openings deserve their own design node or belong inside Fulfillment, or how status markers should behave before implementation exists — I can help with those too.