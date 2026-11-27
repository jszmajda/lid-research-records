## LID Coach — Visit Planner

### Executive summary

**Posture:** Solid design-stage arrow; a tenet-cascade tension and a few uncaptured decisions to tighten.

**Scorecard**
- ✓ **Linkage** — spec IDs unique, zero-padded, grep-anchored; every spec's prefix resolves to its leaf LLD
- ✓ **Mutation hygiene** — docs carry current intent; no history residue, planning text, or obsolete markers
- ✓ **Scope disambiguation** — the two matching paths (>36h vs ≤36h) are cleanly separated by their `WHEN` clauses
- ⚠ **Tenet cascade** — the near-term checkout path can pass over an earlier requester
- ⚠ **Decision capture** — key design constants and the first-asked exception aren't recorded
- ⚠ **Configuration** — `CLAUDE.md` has the `## LID` mode block but no LID directive block

**Headline:** The arrow is real and coherent through the spec layer — two well-scoped components, tight LLDs that close the solution space without reproducing code, and genuinely good tenets. The single most valuable next step is reconciling the near-term fulfillment path with your *first asked, first served* tenet (and recording the result).

### Findings (7 total · 2 high · 3 medium · 2 low)

- **F1 (high):** `CLAUDE.md` carries the `## LID` mode/version block but no LID directive — an agent reading it isn't actually told to follow LID · *modes are declared, not inferred* (the config must state the methodology, not just a mode) → run `/update-lid`
- **F2 (high):** the ≤36h path (FILL-003/004) lets any signed-in account claim a searchable opening first-come-first-served during the 20-min window, which can pass over a patient who asked earlier — a tension with the tenet *First asked, first served* — and no Decisions row records the exception · *tenets capture forward-looking preference* (a leaf mechanism that works against a tenet under a described condition should name the trade on the record)
- **F3 (medium):** the design constants — the 36-hour split, the 20-minute `notBefore` scan delay, the 2-hour offer window — live only in prose; a cold reader would question each and can't reconstruct what was traded · *docs carry current intent* / decision capture (a still-live choice needs a Decisions row that carries its reasoning)
- **F4 (medium):** all 15 specs are marked `[x]` though no Tests or Code phase exists yet; the checkbox reads as "implemented" the arrow can't yet support · *coherence is adjacency* (status markers should mean one consistent thing across the arrow)
- **F5 (medium):** the HLD has Problem/Approach/Tenets/Goals/Components but no **Non-goals** or **Success metrics** — the boundaries and the bar that would let a cold reader tell in-scope from out · *HLD is architecture and rationale*
- **F6 (low):** tenets are an unordered list, yet *First asked, first served* and *Clinical fit precedes utilization* can collide; consider making precedence explicit · *tenets capture forward-looking preference* (order tenets that can conflict)
- **F7 (low):** no authoritative `prefix:` declaration for the leaf paths — `INTAKE`/`FILL` are inferable only from spec IDs, and `FILL` doesn't echo the `fulfillment/` directory name · *specs are grep-anchored linkage* / *semantic legibility* (an explicit prefix keeps the mapping unambiguous)

### What was audited
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`
- Enumerated: 1 HLD, 2 leaf LLDs, 2 spec files, 15 EARS specs (INTAKE-001–007, FILL-001–008)
- Arrow state: HLD → LLD → EARS present and linked; **no Tests or Code phase yet** (pre-implementation — treated as bootstrapping, not drift), so `@spec` coverage and tests-first evidence were not applicable
- No arrow overlay (`docs/arrows/`) present — structural enumeration not run

---

Want me to walk through any of these in detail, focus on a theme or priority, or work through specific items together? F2 and F3 are closely related and a good place to start.

If you have broader questions about using LID for this project — where a PRD would fit, when a component warrants splitting into a sub-HLD, how status markers should read before code exists, or mode choices as the project grows — I can help with those too.