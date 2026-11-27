## LID Coach Review — Visit Planner

**Bootstrapping — the design layer is in place and reads cleanly, but the arrow stops at EARS and one tenet is silently overridden.**

**Scorecard**
- ✓ Mutation hygiene — docs carry current intent; no changelog or "was X, now Y" residue
- ✓ LLD granularity — two intent components, one LLD each, no overlap
- ✓ Tenet quality — four real tie-breakers, defensible opposites, not platitudes
- ⚠ Arrow completeness — stops at EARS; no tests, no code, yet specs are checked off as done
- ⚠ Tenet cascade — same-day open checkout undercuts *First asked, first served* with no recorded exception
- ⚠ Linkage — spec prefixes are inconsistent (INTAKE vs FILL) and no `prefix:` frontmatter anchors them
- ⚠ Configuration — `## LID` block is present, but the file never declares the LID directives

The HLD's Problem/Approach/Tenets are genuinely well-drawn and the two LLDs are disciplined for their size; the fastest wins are reconciling the instruction file, resolving the eligibility/tenet tension in Fulfillment, and declaring what the `[x]` markers actually assert.

### Findings (10 total · 3 high · 6 medium · 1 low)

- **F1 (high):** `CLAUDE.md` has an `## LID` block and Mode marker but no LID directives (`linked-intent-dev` / "Linked-Intent Development") · *modes are declared, not inferred* — the mode is declared, but a reader can't tell which methodology the block belongs to; run `/update-lid` to reconcile.
- **F2 (high):** Fulfillment's ≤36-hour path lets "any eligible signed-in account" claim a searchable opening (`fulfillment-design.md`, FILL-004), which defeats *First asked, first served* (the HLD tenet that an earlier request is never passed by a later one) whenever a faster latecomer arrives first; no Decisions row records the trade · *tenet cascade* and *decision capture* — the exception may well be correct, but a future session reading FILL-004 cold can't tell it was chosen against the tenet.
- **F3 (high):** Every spec is marked `[x]` (`intake-specs.md`, `fulfillment-specs.md`) while the repository contains no tests and no code · *intent leads; code is compiled output* and *canonical arrow shape* — a cold reader will read `[x]` as verified/implemented; either define the marker's meaning or leave it unchecked until Tests and Code exist.
- **F4 (medium):** "Compatible" is the core of the matcher but is never defined in `fulfillment-design.md` (service? site? time window? accessibility?) · *LLDs close enough of the solution space* — two agents could build different matchers and both feel compliant.
- **F5 (medium):** The 36-hour, 20-minute, and two-hour thresholds appear in Fulfillment's Design with no source or rationale, and no Decisions row covers them · *decision capture* — a cold reader will ask whether these are clinical, operational, or invented numbers, and can't reconstruct the cost accepted.
- **F6 (medium):** INTAKE-001 scopes creation to "an authenticated account," but the HLD says "staff may act for patients who call" · *scope disambiguation* — the staff-assisted path is either silently out of spec or needs its own triggered spec.
- **F7 (medium):** Spec prefixes are `INTAKE-` (full word) and `FILL-` (abbreviation) with no `prefix:` frontmatter in either device or spec file · *specs are grep-anchored linkage* — neither leaf path is machine-resolvable to its LLD; pick one convention and declare it.
- **F8 (medium):** The HLD has no Non-goals, no Success metrics, and no Key Design Decisions section · *HLD is architecture and rationale* — goals exist but nothing says what is out of scope or how success is judged, so adjacent choices have no anchor.
- **F9 (medium):** "Registry scan" is used as load-bearing vocabulary in `fulfillment-design.md` and FILL-003/FILL-005 but defined nowhere · *docs carry current intent, written to be read cold* — a fresh reader cannot tell what the scan is or where it lives.
- **F10 (low):** The four tenets are unordered though *First asked, first served* and *Clinical fit precedes utilization* can conflict on a borderline earlier request · *tenets capture forward-looking preference* — ordering resolves which wins when both apply.

### What was audited
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files (5 docs, 70 lines)
- Enumerated: 2 LLDs, 2 spec files, 15 EARS specs
- Sampled: no code or test files exist to sample (0 `@spec` annotations, 0 tests); git history is a single "fixture" commit
- Not read: `references/sampling.md` — sampling thresholds (>15 LLDs, >200 annotated files, or an arrow overlay) were not met; overlay is absent

### Offer to help
Want me to walk through any finding in detail, focus on a theme or priority, or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID for your project — where tests and code fit while the arrow is still bootstrapping, multi-component scope, or how to record a deliberate tenet exception — I can help with those too.

*Defaults taken (non-interactive run): proceeded with a full review under Full mode because the project is LID-shaped despite the missing directive block; skipped `references/sampling.md` because no sampling threshold applied; rendered the report inline and made no file changes, per the skill's advisory posture.*