## LID Coach — Shelfwise

**Posture:** Healthy design core; configuration gap and one tenet-level design conflict.

**Scorecard**
- ✓ Linkage & naming — clean namespaced IDs (`HOLDALLOC-*`, `PICKUP-*`); both leaf prefixes resolve to HLD components
- ✓ Mutation hygiene — present-tense docs, no changelog/`[obsolete]`/history residue
- ⚠ Tenet alignment — allocation leans against the HLD's sequencing tenet
- ⚠ Adjacent-level coherence — pickup expiry timing differs between the LLD and its specs
- ⚠ Arrow completeness — the arrow stops at EARS; no Tests or Code exist
- ⚠ Configuration — mode is declared but the methodology directive block is missing

The design core is clean and well-linked across two components; the fastest wins are reconciling the instruction file and resolving the allocation/sequencing tenet conflict.

**Findings (8 total · 3 high · 2 medium · 3 low)**
- **F1 (high):** Instruction file declares `- Mode: Full` but carries no `linked-intent-dev` directive block · *modes are declared, not inferred* — the methodology reference should be stated, not implied. Point at `/update-lid`.
- **F2 (high):** Allocation's scanning-branch-first rule contradicts the HLD tenet "Waiting is honored in sequence" · *tenets capture forward-looking preference* — HOLDALLOC-003/004 give a *later* local hold priority over an *older* county-wide hold, so the earlier patron's wait is lengthened by one who asked after.
- **F3 (high):** The arrow stops at EARS — no Tests or Code · *canonical arrow shape* (HLD → LLD → EARS → Tests → Code) — 13 behavioral specs have no tests citing them.
- **F4 (medium):** The scanning-branch-first choice has no row in Hold Allocation's Decisions & Alternatives · *docs carry current intent* (decision capture) — a cold reader holding the tenet would question it and cannot reconstruct what was weighed against the courier savings.
- **F5 (medium):** Pickup-notices LLD and its specs disagree on when a lapsed hold closes · *coherence is adjacency* — the LLD (line 11) closes the hold at lapse; PICKUP-004/005 close it only when staff scan the copy off the shelf.
- **F6 (low):** HLD has no non-goals or target-users section · *HLD is architecture and rationale* — bounding what is out of scope helps future decisions.
- **F7 (low):** Tenet phrasing — "Hold history is not kept" reads as a decision rather than a lean, and the four tenets are unordered · *tenets capture forward-looking preference*.
- **F8 (low):** Spec status markers `- [x]` are used with no legend · *docs carry current intent, written to be read cold*.

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `hold-allocation-design.md`, `hold-allocation-specs.md`, `pickup-notices-design.md`, `pickup-notices-specs.md`
- Enumerated: 2 leaf LLDs, 2 spec files, 13 specs (7 `HOLDALLOC`, 6 `PICKUP`)
- Linkage metric: 0 `@spec` references — no code or test files exist; no `docs/arrows/` overlay present
- Cold-read pass and Decisions-table sweep run against all five design/spec docs

**Worth a second look (capability note):** No `references/capability-flags.md` was found in the sibling skill, so no model-specific flags apply.

Non-interactive defaults taken: mode = Full (no `## LID Scope` declared, per dispatch default); proceeded with a full review anchored on the existing artifacts rather than refusing for the missing directive block; report rendered inline and not persisted to disk.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.