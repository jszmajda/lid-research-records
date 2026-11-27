Dispatch check complete. The project is LID-shaped (HLD + two leaf design/spec pairs) and declares `Mode: Full`, but `CLAUDE.md` carries no `linked-intent-dev` directive block — so I proceeded with a full review and surfaced the missing directive as a high-priority finding (dispatch table, row 2). No arrow overlay, no code, and no tests are present. Capability-flags file lists no flagged configurations, so that section is omitted. Here is the report.

---

# LID Coach — Shelfwise

## Executive summary

**Posture:** Solid design-stage arrow — clean docs and linkage; one real tenet tension and a configuration gap to tighten.

**Scorecard**
- ✓ **HLD discipline** — architecture and rationale only; no schemas or signatures bleeding upstream
- ✓ **Linkage** — IDs unique, zero-padded, grep-anchored; every spec traces to its leaf
- ✓ **Mutation hygiene** — docs read cold and clean; present-tense, no history residue or obsolete markers
- ⚠ **Tenet cascade** — branch-first allocation can lean against *"waiting is honored in sequence"*
- ⚠ **Configuration** — `## LID` block present, but the `linked-intent-dev` directive is missing
- ⚠ **Coherence** — all specs marked `[x]` done, yet no Tests or Code phase exists to check them against

**Headline:** The arrow is genuinely walkable for a two-component design — tight specs, faithful LLD→spec coherence, and Decisions tables that mostly carry their own weight (the pickup-window *Expiry handling* row is a model: it names the Goal 1 cost and why it's accepted). The highest-value move is recording the allocation sequence trade-off that's currently unspoken; the fastest is reconciling the instruction file via `/update-lid`.

## Findings (5 total · 2 high · 2 medium · 1 low)

- **F1 (high):** `CLAUDE.md` has the `## LID` block (Mode, Version) but no `linked-intent-dev` directive — run `/update-lid` to reconcile · *modes are declared, not inferred* — the foundation the rest of LID keys off should be explicit on the page, not implied by a bare mode bullet
- **F2 (high):** Branch-first allocation (HOLDALLOC-003/004) can seat a later patron ahead of an earlier one when the copy is scanned at the later patron's pickup branch — this leans against the tenet *"nobody's wait is lengthened by a patron who asked after them"*, and no Decisions row or note records the exception · *tenets capture forward-looking preference / keep the arrow coherent* — an unrecorded conflict with a stated tenet is exactly the drift a future session re-derives or contradicts
- **F3 (medium):** The branch-preference policy itself has no Decisions & Alternatives row in `hold-allocation-design.md` — only the inline aside *"keeps most copies off the courier van"* · *docs carry current intent (decision capture)* — a cold reader would still question choosing courier efficiency over strict sequence; capture the alternative weighed and the cost accepted
- **F4 (medium):** Every spec is marked `[x]` done, but the repo has no test or code phase to cross-check — the arrow stops at EARS · *coherence is adjacency / tests before code* — completion markers that outrun the arrow can't be verified, and if code lives elsewhere the arrow isn't walkable code-up
- **F5 (low):** Leaf design and spec files carry no `prefix:` frontmatter tying each leaf path to its spec namespace — resolution works by name today but isn't authoritative · *specs are grep-anchored linkage*

## What was audited
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both leaf design docs, both spec files
- Enumerated: 1 HLD, 2 leaf LLDs, 2 spec files, 13 specs (HOLDALLOC-001–007, PICKUP-001–006)
- Coherence: LLD→spec adjacency checked for both components (both consistent)
- Not present / not sampled: no `docs/arrows/` overlay, no tests, no code — the Tests and Code phases do not exist in this repo

---

Want me to walk through any of these in detail, focus on a theme or priority, or work a specific item together — F2 and F3 in particular are worth unpacking, since they're two angles on the same allocation choice? You can also pick a single finding to dig into.

If you have broader questions about using LID for Shelfwise — when to add the Tests/Code phases, how the arrow overlay would help once there's code, or mode fit as the project grows — I'm glad to help with those too.