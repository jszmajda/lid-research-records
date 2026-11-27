# LID Coach — Shelfwise

**Posture:** Docs-first and coherent, but the arrow is truncated at EARS — the implementation half is missing.

**Scorecard**
- ✗ Arrow completeness — design and specs exist; no tests and no code in the repo
- ⚠ Configuration — `## LID` block present, but the instruction file carries no LID directives
- ⚠ Linkage — spec IDs are clean and unique, but no LLD declares `prefix:`/`parent:`
- ⚠ Coherence — expiry handling reads one way in the LLD and another way in the specs
- ⚠ Tenet fit — one tenet ("waiting is honored in sequence") is contradicted by the allocation rule
- ✓ Mutation hygiene — no changelog residue, no obsolete markers, no `[inferred]` debt

**Headline:** The design layer is tight, well-reasoned, and cheap to read — the fastest wins are adding the missing LID directives and reconciling the expiry path, since the specs currently claim behavior the code (and the LLD) does not yet agree on.

---

**Findings (12 total · 4 high · 5 medium · 3 low)**

- **F1 (high):** Every one of the 13 specs is marked `[x]` ("implemented"), yet the repo contains no tests and no code — the arrow stops at EARS · *tests before code* (tests are written first and prove the spec) and *canonical arrow shape* (HLD → LLD → EARS → Tests → Code)
- **F2 (high):** `CLAUDE.md:6-8` has the `## LID` block but no `linked-intent-dev` directive section and no navigation table; the project also has no `AGENTS.md` — run `/update-lid` to reconcile · *modes are declared, not inferred* and *minimum surface, maximum discipline* (custom conventions should ride on the standard arrow, not replace it)
- **F3 (high):** `docs/intent/pickup-notices/pickup-notices-design.md:11` closes the hold and re-runs allocation when the window lapses; `docs/intent/pickup-notices/pickup-notices-specs.md:6-7` (PICKUP-004/005) defer both until staff scan the copy off the shelf — one of the two is wrong and the two implement different patron-visible behavior · *coherence is adjacency* (each level agrees with the level next to it)
- **F4 (high):** `docs/intent/hold-allocation/hold-allocation-design.md:11` prefers holds at the scanning branch over older holds elsewhere, which lengthens an earlier patron's wait — directly against the tenet "Waiting is honored in sequence" (`docs/high-level-design.md:13`), and the branch-local rule has no Decisions row at all · *tenets capture forward-looking preference* (a tenet that the mechanism contradicts is not a tie-breaker) and *decision capture* (a cold reader cannot reconstruct what was given up)
- **F5 (medium):** Neither LLD carries `parent:`/`prefix:` frontmatter, so `HOLDALLOC-` and `PICKUP-` have no authoritative bridge to a leaf · *effective intent-tree alignment* (the leaf prefix names the node that owns the spec)
- **F6 (medium):** The HLD has no `## Target Users`, `## Non-Goals`, or `## Success Metrics` section, and uses `## Components` where the template expects `## System Design` — Full mode expects every section filled · *HLD is architecture and rationale* (who it serves and what it explicitly is not are architecture)
- **F7 (medium):** HOLDALLOC-007 depends on a patron cancelling a hold, but no spec covers cancellation, and the tenet "a closed hold's record is deleted" has spec support only for checkout (PICKUP-003) and lapse (PICKUP-005) · *effective intent-tree alignment* (LLD behaviors with no spec are unnamed intent that drifts silently)
- **F8 (medium):** The transit path is nowhere reconciled with Goal 1: a copy routed to another branch waits for a once-daily courier, and the 7-day window does not start until it reaches the holds shelf — contrast the expiry row (`pickup-notices-design.md:22`), which does name its Goal 1 cost · *tenet cascade* (name the goal the mechanism costs and the condition)
- **F9 (medium):** Specs cross-reference other components' concepts without disambiguating them — "run allocation" (PICKUP-005), "holds shelf" (PICKUP-001), "in-transit copy" (HOLDALLOC-007) · *scope disambiguation* (a spec found by grep must still be unambiguous)
- **F10 (low):** The four tenets are unordered, and "Hold history is not kept" reads as a settled constraint rather than a forward-looking lean — it also bounds "Staff attention goes to exceptions", since failed delivery hands work to staff · *tenets capture forward-looking preference* (order them so the higher one wins)
- **F11 (low):** The 15-hold cap records the rationale and the cost but not where 15 came from — a cold reader cannot reconstruct the number · *decision capture* (capture what was given up, not just that something was)
- **F12 (low):** `pickup-notices` bundles notice delivery with expiry and pull-list handling; they share hold-lifecycle state today but have separable behavior — worth splitting if either grows · *one LLD per intent component* (split only if it actually starts to strain)

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files; cold-read pass over all six docs
- Enumerated: 2 LLDs, 2 spec files, 13 specs, 13 unique IDs, all marked `[x]`, no collisions
- Code and tests: none present in the repository — 0 `@spec` references to audit
- `docs/arrows/` overlay: absent, so no overlay or index findings
- Git history: a single `fixture` commit, so no upstream-change cascade could be assessed from history

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

*Defaults taken (non-interactive):* review rendered inline rather than persisted to disk; the missing instruction-file directives are reported and routed to `/update-lid` rather than edited here, and the F3 expiry mismatch is reported without choosing which side is correct; no project files were changed, per the skill's advisory posture.