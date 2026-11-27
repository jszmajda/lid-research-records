# Shelfwise — LID Coach Review

## 1. Executive summary

**Posture:** *Healthy design core; the arrow stops before code.*

**Scorecard**
- ✓ HLD discipline — architecture and rationale only, no schemas or signatures bleeding upstream
- ✓ Spec hygiene — all 13 specs are conditionally scoped, well-formed, no `[obsolete]`/`[inferred]` residue
- ✓ LLD granularity — one leaf per intent component, no lumping or fragmentation
- ✓ Decision capture (partial) — the pickup-notices table records accepted costs, including an explicit Goal 1 trade-off
- ⚠ Arrow completeness — no test or code phase exists; every spec is marked `[x]`
- ⚠ Tenets — four real tie-breakers, but unordered and one of them is really a decision
- ⚠ Decision capture — the branch-preference allocation rule is prose-only and in tension with a tenet
- ⚠ Configuration — the instruction file carries only `Mode`/`Version`, no LID directives

**Headline:** The design layer is unusually clean for its size — a tight HLD, two well-scoped LLDs, condition-scoped EARS, and a decisions table that records real costs — so the highest-value next steps are (a) reconcile the LLD↔EARS seam at expiry, and (b) bring the tests/code phase into existence, since `[x]` on every spec currently asserts an implementation that isn't there.

---

## 2. Findings inventory

**Findings (12 total · 4 high · 6 medium · 2 low)**

- **F1 (high):** `CLAUDE.md` declares `Mode: Full` and `Version` but contains no `linked-intent-dev` directives, so a fresh session has no workflow to follow · *modes are declared, not inferred* → run `/update-lid`
- **F2 (high):** the arrow ends at EARS — the repo contains no test and no code files, yet all 13 specs are marked `[x]` (complete) · *canonical arrow shape* + *intent leads; code is compiled output*
- **F3 (high):** branch-first allocation (scanning branch before county-wide oldest) exists only in prose, and it contradicts the tenet "Waiting is honored in sequence" · *decision capture* + *tenets capture forward-looking preference*
- **F4 (high):** LLD↔EARS disagree on when an expired hold closes: the design says at window lapse, PICKUP-004/005 say at staff scan-off · *coherence is adjacency*
- **F5 (medium):** patron channel selection ("at signup") and hold placement are referenced but have no owning LLD or spec; PICKUP-002 depends on "the patron's chosen channel" that nothing establishes · *effective intent-tree alignment*
- **F6 (medium):** the once-daily courier can push a transit copy a full day before pickup, against Goal 1's 4-hour notification target, with no recorded acknowledgement · *tenet cascade* + *decision capture*
- **F7 (medium):** four tenets in an unordered list, at least two of which can conflict (branch priority vs sequence; hear-once vs Goal 2) · *tenet quality*
- **F8 (medium):** "Hold history is not kept" reads as a pinned constraint rather than a forward-looking tie-breaker — its opposite (keep hold records) is a choice a future session could reasonably make · *tenet quality*
- **F9 (medium):** HLD has no Target users, Non-goals, Key design decisions, or Success metrics sections; nothing bounds scope · *HLD is architecture and rationale*
- **F10 (medium):** the copy lifecycle has no transit state in specs, and the arrival event exists only inside HOLDALLOC-007, leaving HOLDALLOC-006's guard ambiguous for a copy in transit · *LLDs close enough of the solution space*
- **F11 (low):** the `allocated` marker and the re-run-on-cancellation rule live in design prose with no Decisions row · *decision capture*
- **F12 (low):** spec ID prefixes are abbreviations (`HOLDALLOC`, `PICKUP`) rather than the design-tree path (`hold-allocation`, `pickup-notices`), with no project-root segment; unambiguous today, collision-prone at a third leaf · *specs are grep-anchored linkage*

---

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files (all 4 design docs, 13 specs)
- Enumerated: 2 intent components (leaf LLDs), 2 spec files, 4 HLD sections, 4 tenets, 7 Decisions rows
- Sampled: the whole repository — 6 tracked files, zero code, zero tests, no `docs/arrows/` overlay (`index.yaml` absent, so no arrow-path sampling was possible)
- Cold-read pass over all four docs, plus a Decisions-table sweep with the HLD and both LLDs in hand
- Grep screen for residue markers (`[inferred]`, `[obsolete]`, `TODO`, changelog/history sections, in-conversation phrases) — clean, no hits

---

## 4. Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

---

**Defaults taken (non-interactive run):** dispatch on the "LID-shaped artifacts present, instruction file missing directives" row — proceeded with a full review anchored on existing artifacts, defaulting to **Full** mode; treated the missing overlay (`docs/arrows/`) as absent rather than corruption; made no file changes, per the skill's advisory posture (findings are surfaced, you apply them — `/update-lid` for F1, `/arrow-maintenance` if you want structural enumeration of the spec↔LLD seams in F2/F4).