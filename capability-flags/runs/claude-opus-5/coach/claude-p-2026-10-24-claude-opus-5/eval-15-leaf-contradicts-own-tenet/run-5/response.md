**LID Coach — Shelfwise**

## Executive summary

**Posture:** Strong intent layer, arrow truncated below specs — and two tenets the design leans against.

**Scorecard**
- ✓ **Design-layer shape** — one HLD, two clean leaf components, no overlap, no bloat
- ✓ **Spec quality** — 13 well-formed EARS specs, stable prefixes, no obsolete residue
- ✗ **Arrow completeness** — the Tests and Code phases don't exist yet, but every spec is checked off
- ✗ **Tenet cascade** — the allocation rule and the record-deletion rule each work against a stated tenet or goal
- ⚠ **Decision capture** — the single most questionable choice in the system has no Decisions row
- ⚠ **Configuration** — the `## LID` block carries a mode and version but no LID directives

**Headline:** The intent layer here is genuinely good — the HLD stays architectural, the two LLDs split along a real seam, the specs are tight and traceable, and the Decisions tables already do the thing most projects skip (the *Expiry handling* row even names the Goal 1 cost it accepts). The highest-value next step is reconciling the tenets with what the design actually does: the branch-first allocation rule and the delete-on-close rule each cut against something the HLD commits to, and neither records the trade.

## Findings (11 total · 5 high · 4 medium · 2 low)

- **F1 (high):** `CLAUDE.md`'s `## LID` block declares mode and version but carries no LID directives — nothing tells a fresh session how to walk the arrow · *modes are declared, not inferred* (an unread mode is a default) → `/update-lid`
- **F2 (high):** The arrow runs HLD → LLD → EARS and stops; no tests, no code, no `@spec` annotations anywhere — yet all 13 specs are marked `[x]` · *coherence is adjacency* (each level should agree with its neighbor)
- **F3 (high):** Branch-first allocation (`HOLDALLOC-003`/`004`, design line 11) hands a returning copy to the oldest hold *naming the scanning branch*, so a later-asking patron at that branch can overtake an earlier county-wide hold — the tenet says "nobody's wait is lengthened by a patron who asked after them" · *tenet cascade* (leaf mechanisms should lean the way the tenets say)
- **F4 (high):** That same rule is captured only as a half-clause of prose ("keeps most copies off the courier van"); the Decisions table records granularity, trigger, and cap but not the one choice a cold reader would want to reverse · *decision capture*
- **F5 (high):** The tenet "hold history is not kept" plus `PICKUP-003`/`005` deleting the record at close removes the per-hold timing and outcome data Goals 1 and 2 are stated as measuring · *tenet cascade* (a mechanism that defeats a stated goal under a described condition)
- **F6 (medium):** Neither leaf design declares a `prefix:`, so `HOLDALLOC-` and `PICKUP-` resolve to their owning nodes only by eye · *specs are grep-anchored linkage* (the path/facet split should be authoritative, not inferred)
- **F7 (medium):** Cancellation is specified only for a copy in transit (`HOLDALLOC-007`); a hold cancelled while its copy sits on the holds shelf, or before allocation, is an open edge · *LLDs close enough of the solution space*
- **F8 (medium):** "Staff attention goes to exceptions" reads as a value rather than a tie-breaker — its opposite isn't a choice another library would make; and the four tenets are unordered although tenet 1 already collides with the efficiency lean behind F3 · *tenets capture forward-looking preference*
- **F9 (medium):** For a transit copy the patron learns nothing until the shelf scan, and the courier runs once a day — the design never says where Goal 1's four-hour clock starts or stops on that path · *LLDs close enough of the solution space*
- **F10 (low):** Body asides that restate their own Decisions rows — "No reminder follows", "does not trigger a fallback channel" — read as answers to questions once raised in conversation · *docs carry current intent, written to be read cold*
- **F11 (low):** Goal 1 is in business hours while windows and specs are in calendar days, with no stated relation between them · *semantic legibility as cheap linkage*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both leaf designs and both spec files under `docs/intent/` — 6 files, the entire tracked repo
- Enumerated: 1 HLD, 2 leaf LLDs, 2 spec files, 13 EARS specs, 4 tenets, 2 goals, 7 Decisions rows
- Arrow-path sampled: both segments walked HLD section → LLD → spec; the test and code legs do not exist to sample
- Linkage metric: 0 `@spec` annotations across 0 source or test files
- Overlay: `docs/arrows/` absent, so no `index.yaml` to guide sampling; structural findings here are patterns, not enumerations
- Dispatch note: `CLAUDE.md` has a `## LID` block but no LID directives, while the project is clearly LID-shaped — per the skill's default I ran a **full review** anchored on the existing artifacts and surfaced the directive gap as F1. Mode read as **Full** from the declared bullet; no scope section needed.

## Want to go further?

Want me to walk through these in detail, focus on one theme — the tenet conflicts in F3/F5 are the ones I'd start with — or work through specific findings together? Pick any finding and I'll dig in; I haven't changed any files, since applying is yours to decide.

If you have broader questions about using LID on Shelfwise — when to add the tests-and-code legs, whether these two components will want a sub-HLD as they grow, where a PRD would fit, or what to do about metrics that need data a tenet deletes — I can help with those too.