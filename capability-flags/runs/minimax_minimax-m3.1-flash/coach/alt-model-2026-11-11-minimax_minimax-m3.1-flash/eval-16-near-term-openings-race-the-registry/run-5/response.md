# LID Coach — Visit Planner

## 1. Executive summary

**Posture:** Bootstrapping — a clean, well-shaped design layer with a missing bottom half.

**Scorecard**
- ✓ HLD discipline — problem, approach, tenets, goals, components; no implementation detail bleeding upstream
- ✓ Mutation hygiene — no changelog residue, no `[obsolete]` specs, no in-conversation asides; docs read as authored today
- ✓ Decision tables — every leaf carries a Decisions & Alternatives table with rejected alternative and accepted cost
- ⚠ Arrow completeness — the arrow currently stops at EARS; no tests and no code exist in the repository
- ⚠ Spec linkage — IDs are unique and stable, but leaf prefixes don't trace to the design nodes and no `@spec` annotations exist (nothing to trace yet)
- ⚠ Tenet cascade — the near-term cancellation path runs against *first asked, first served*, with no recorded exception
- ⚠ Configuration — `## LID` declares Mode and Version, but the instruction file never names the linked-intent-dev workflow

**Headline:** The design layer is genuinely good — the HLD is pure architecture, the tenets are real tie-breakers, and both leaves carry honest decision tables. The fastest wins are (1) wiring the instruction file so LID is actually invoked, and (2) deciding whether the near-term cancellation behavior should be reconciled with the "first asked, first served" tenet before any code is written to it.

---

## 2. Findings inventory

**Findings (13 total · 3 high · 7 medium · 3 low)**

- **F1 (high):** the instruction file declares `## LID` but contains no `linked-intent-dev` directive, so nothing invokes the workflow on a change · *modes are declared, not inferred* — the mode marker exists, but the directive block that routes work into LID does not
- **F2 (high):** the arrow stops at EARS — the repository contains no tests and no code, so `Tests → Code` phases are absent rather than collapsed · *canonical arrow shape* — every phase should exist for components in scope
- **F3 (high):** the ≤36-hour path lets any signed-in account claim a published opening while an earlier interest entry waits, which runs against the HLD tenet *first asked, first served*, and no Decisions row records the trade-off · *tenets capture forward-looking preference* / *decision capture*
- **F4 (medium):** `fulfillment-design.md` bundles scheduled-opening matching (FILL-001/002) with same-day cancellation publishing (FILL-003/004/005) — shared design, separable behavior, so it reads as a sub-HLD in disguise · *one LLD per intent component — or split into a sub-HLD when it outgrows one node*
- **F5 (medium):** the LLD guarantees the entry only for *exact* retries, while INTAKE-004 returns the original entry for *any* key retry — a same-key/different-payload retry is undefined and the two docs disagree · *coherence is adjacency*
- **F6 (medium):** the two-hour offer window is stated only in LLD prose with no spec covering it — unnamed intent with nothing to test against · *effective intent-tree alignment*
- **F7 (medium):** spec leaf prefixes `INTAKE` and `FILL` don't match the design nodes `intake` and `fulfillment`; `FILL` resolves to nothing, so grepping the node name misses the segment · *specs are grep-anchored linkage*
- **F8 (medium):** `registry scan` and `notBefore` are used without ever being defined — a cold reader can't tell what the registry is or what schedules the scan · *docs carry current intent, written to be read cold*
- **F9 (medium):** every spec carries `[x]`, asserting completion for behavior that has no implementation and no test · *coherence is adjacency*
- **F10 (medium):** neither LLD cites the spec IDs it owns, so LLD→EARS linkage is inferred from naming convention alone · *coherence is adjacency*
- **F11 (low):** the 36-hour threshold and the 20-minute delay have no stated source or rationale anywhere in the tree · *decision capture*
- **F12 (low):** FILL-004 covers a *signed-in account* claiming via checkout, but the HLD says staff may act for patients who call — the staff-assisted claim path for a published opening is unspecified · *scope disambiguation*
- **F13 (low):** `## LID Scope` is absent while the mode is `Full` — fine today, but if the implementation lives outside this repo, Scoped mode would match reality better · *mode fit*

---

## 3. What was audited

- **Read fully:** `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/intake/intake-design.md`, `docs/intent/intake/intake-specs.md`, `docs/intent/fulfillment/fulfillment-design.md`, `docs/intent/fulfillment/fulfillment-specs.md` — 6 of 6 files in the repository
- **Enumerated:** 2 leaf LLDs, 2 spec files, 15 specs (7 intake, 8 fulfillment), 4 HLD tenets, 3 HLD goals, 2 HLD components, 8 Decisions & Alternatives rows
- **Code/test sampling:** nothing to sample — the repository contains no source or test files; `@spec` reference count is 0 because no code exists
- **Overlay:** `docs/arrows/` is not installed, so no structural enumeration (orphans, reverse orphans, index drift) was attempted — those are `/arrow-maintenance`'s job
- **Cold-read pass:** performed on all six documents, not phrase-matched — F8 and F12 come from that pass
- **Decisions-table sweep:** all 8 rows re-read against the HLD above them; 7 pass on a cold read (each names a source or an evident cost), F3's absent row is the one that fails
- **History:** a single commit (`fixture`), so residue findings were assessed from doc content alone

---

## 4. Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

---

**Defaults I took (non-interactive run):** I applied the dispatch table's "instruction file missing LID directives but the project has LID-shaped artifacts" branch — proceeded with a **full review in Full mode** (the `- Mode: Full` marker was present and parseable), and raised the missing directive block as high-priority finding F1 pointing at `/update-lid`. No `docs/arrows/` overlay is installed, so I skipped structural enumeration and referenced `/arrow-maintenance` where a finding was structural. I followed the skill's advisory posture: **no project files were modified**, and the report is inline rather than persisted to disk.