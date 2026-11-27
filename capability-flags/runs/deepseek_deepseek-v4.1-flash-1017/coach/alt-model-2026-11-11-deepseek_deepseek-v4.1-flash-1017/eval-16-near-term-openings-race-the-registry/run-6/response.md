## LID Coach — Visit Planner

**Posture:** Well-formed spec-first seed; the arrow stops at EARS and the configuration is bare. Healthy design instincts, with a tenet-level tension that should be decided on the record before code lands.

**Scorecard**
- ✓ HLD discipline — architecture and rationale, no implementation bleed
- ✓ LLD granularity — one clean leaf per component, no overlap
- ✓ Mutation hygiene — no change-narration, no obsolete residue
- ⚠ Configuration — bare `## LID` block; the LID directives are absent
- ⚠ Arrow completeness — Tests and Code phases have no artifact, yet specs read `[x]`
- ⚠ Tenet cascade — the same-day path can pass earlier requesters
- ⚠ Decision capture — the load-bearing thresholds and tier split have no row

**Headline:** The two-leaf design tree and its EARS set are coherent and cold-readable; the fastest wins are reconciling the instruction file with `/update-lid` and recording the same-day-vs-future design decision that currently lives only in prose.

### Findings (10 total · 3 high · 6 medium · 1 low)

- **F1 (high):** `CLAUDE.md` carries a `## LID` block but no linked-intent-dev directives — *modes are declared, not inferred* (the mode lives in the instruction file, and a bare block leaves the workflow conventions unstated). Recommend `/update-lid`.
- **F2 (high):** the ≤36-hour path lets *any* eligible signed-in account complete checkout while searchable, so a later (or absent) requester can take an opening ahead of an earlier one — under the described same-day condition this works against the **First asked, first served** tenet, and no Decisions row records the trade — *tenet cascade* (leaf mechanisms should lean the way the HLD's tenets say to lean).
- **F3 (high):** no tests or code exist, yet every spec is marked `[x]` complete — the arrow stops at EARS with nothing to verify it — *canonical arrow shape* / *tests before code* (tests preload the API's use before implementation exists).
- **F4 (medium):** the 36-hour split, two-hour offer window, and 20-minute scan delay are the core design but appear only in body prose with no Decisions-and-Alternatives row — a cold reader cannot reconstruct what was given up — *decision capture* (docs carry current intent with alternatives and accepted cost).
- **F5 (medium):** "registry scan" and "clinical compatibility" are used but defined nowhere; the matching eligibility rule stays open — *LLDs close enough of the solution space* (agents fill open edges with guesses).
- **F6 (medium):** the HLD's "staff may act for patients who call" has no corresponding spec or LLD behavior — *effective intent-tree alignment* (HLD intent with no EARS beneath it drifts silently).
- **F7 (medium):** spec prefixes use `INTAKE`/`FILL`, but nothing declares a `prefix:` frontmatter or maps `FILL` → Fulfillment — the leaf↔spec link needs inference — *specs are grep-anchored linkage*.
- **F8 (medium):** the HLD has no non-goals, target users, or success metrics — *HLD is architecture and rationale* (missing the sections that bound scope and measure outcome).
- **F9 (medium):** `FILL-003` bundles two obligations (publish to portal search *and* schedule a scan) in one spec — *specs are grep-anchored linkage* (a compound spec fails cleanly in two places at once).
- **F10 (low):** the tenets are unordered though **First asked, first served** and **Clinical fit precedes utilization** can conflict — *tenets capture forward-looking preference* (ordering resolves which wins).

### What was audited
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both `*-specs.md` files
- Enumerated: 2 LLDs, 2 spec files, 15 specs (7 `INTAKE`, 8 `FILL`)
- No arrow overlay (`docs/arrows/index.yaml` absent); no code or test files present to sample
- Linkage metric: 0 `@spec` references, 0 `prefix:` frontmatter declarations
- Cold-read pass over all five LID docs; Decisions-table sweep over both tables plus the threshold prose

*Defaults taken (non-interactive run): mode treated as Full from the `## LID` block; the missing-directives dispatch branch was taken, so a full review ran against the existing artifacts rather than refusing; advisory posture kept — no files edited.*

### Offer to help
Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.