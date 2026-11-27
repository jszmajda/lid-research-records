# LID Coach — Field Notes

## 1. Executive summary

**Posture:** *Bootstrapping — arrow in place, content sparse.* The design core is clean and well-formed; the arrow stops at EARS and one key decision is under-explained.

**Scorecard**
- ✓ Linkage hygiene — `SYNC` prefix matches the LLD's `prefix:`, IDs unique, grep-friendly
- ✓ Mutation hygiene — no change-narration, no `[obsolete]` residue, no changelog fossils
- ✓ Mode & configuration — `CLAUDE.md` declares Full mode and consults the skill
- ✗ Arrow completeness — specs are marked complete but no test or code phase exists
- ⚠ Decision capture — the conflict-resolution choice is live and thinly justified
- ⚠ HLD discipline — architecture is present, rationale sections are missing

**Headline:** The intent tree is coherent and honestly written; the fastest wins are making the clock-skew decision defensible on the page, and giving the local note store its own design node.

## 2. Findings inventory

**Findings (8 total · 3 high · 3 medium · 2 low)**

- **F1 (high):** the sync LLD names the hazard — device clocks are "frequently wrong by several minutes" (`docs/intent/sync/sync-design.md:9`) — then resolves conflicts by wall-clock and discards the loser (`:17`, `:23`), with the rationale "Simpler." A cold reader cannot reconstruct what was given up, and the choice sits in tension with the HLD goal of convergent state after reconnect. Consider recording the trade-off and the tenet/goal it trades against · *decision capture — a live choice needs a row that says what was given up and at what cost*
- **F2 (high):** "Device-local store" is a first-class component in the HLD architecture (`docs/high-level-design.md:13`) but has no LLD, no specs, and no design of its own — an intent component with no node in the tree · *one LLD per intent component — each thing a user would describe as a thing gets its own design node*
- **F3 (high):** both specs carry a `[x]` complete marker (`docs/intent/sync/sync-specs.md:5-6`) while the repo has no tests and no code — the arrow stops at EARS, and the HLD goal "No blocked capture in the field" (`docs/high-level-design.md:21`) has no spec anywhere · *canonical arrow shape — HLD → LLDs → EARS → Tests → Code; a missing phase is a deviation*
- **F4 (medium):** the HLD has Problem, Approach, Architecture, Tenets, Goals, Non-Goals but no Target Users, Key Design Decisions, or Success Metrics — the goals are unmeasurable as written · *HLD is architecture and rationale — the HLD carries the why that outlives any implementation*
- **F5 (medium):** the sync LLD specifies SQLite-on-device storage and the service's merge into the canonical store (`docs/intent/sync/sync-design.md:13`, `:24`) but neither has a spec — LLD behaviors with no spec drift silently · *effective intent-tree alignment — behaviors with no spec are unnamed intent*
- **F6 (medium):** the HLD says "background sync to a central service on reconnect" (`docs/high-level-design.md:9`) while the LLD says sync happens on reconnect — a cold reader cannot tell whether sync also runs while already connected · *docs carry current intent, written to be read cold — the doc must stand without the conversation that produced it*
- **F7 (low):** one tenet ("Boring over clever") covers a narrow axis, and there is no tie-breaker for the project's biggest forward-looking question — what to do when capture would block on the network · *tenets capture forward-looking preference — a tenet pre-narrows the lean a future session has to make cold*
- **F8 (low):** the spec file links upward with an ad-hoc `**LLD**:` line while the LLD uses `parent:`/`prefix:` frontmatter — two linkage conventions in one tree · *minimum surface, maximum discipline — one convention, no parallel machinery*

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 HLD, 1 LLD, 1 spec file, 2 specs, 0 test files, 0 source files, 0 `@spec` annotations
- Overlay: no `docs/arrows/` present, so no arrow-segment sampling was applicable
- History: single commit (`0f38437`), so no long-lived `[inferred]` markers to triage

**Defaults taken** (non-interactive): proceeded without pausing for questions; treated the absent `docs/arrows/` overlay as "not installed" rather than corruption; rendered the report inline instead of persisting it, per the skill's advisory posture — no project files were modified. If you want the conflicts resolved and the local-store node drafted, say so and I'll apply those edits.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.