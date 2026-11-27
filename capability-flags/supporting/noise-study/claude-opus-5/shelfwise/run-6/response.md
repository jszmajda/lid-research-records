**Shelfwise — LID Coach Review**

## Executive summary

**Posture:** Design layer is clean and coherent; the arrow stops at EARS, and a headline policy sits at odds with a tenet.

**Scorecard**
- ✓ Mutation hygiene — no changelogs, `[obsolete]` markers, or superseded docs anywhere; docs read as current intent
- ✓ LLD granularity & HLD discipline — two leaves matching the two HLD components; no schemas or signatures bleeding upstream
- ⚠ Decision capture — decision tables are well-formed, but the most consequential allocation choice isn't in one
- ⚠ Tenet coherence — the allocation rule and tenet 1 pull in opposite directions; one tenet is spec-shaped
- ✗ Arrow completeness — all 13 specs are marked done, with no tests or code in the repo
- ⚠ Configuration — the `## LID` block carries mode and version but no LID directives
- ✓ Mode fit — Full matches a project where everything present is in the arrow

**Headline:** The design layer here is unusually disciplined for its size — tight EARS specs in proper form, unique grep-anchored IDs, and Decisions tables that actually name the rejected option and the accepted cost, which is the part most projects skip. The fastest wins are reconciling the instruction file with `/update-lid`, and settling the branch-first allocation policy — capturing it in the Decisions table and resolving it against the "waiting is honored in sequence" tenet.

## Findings (14 total · 5 high · 6 medium · 3 low)

- **F1 (high):** `CLAUDE.md` has the `## LID` block (Mode: Full, Version 1.4.0) but no LID directives — nothing tells a fresh session to work the arrow · *modes are declared, not inferred*
- **F2 (high):** All 13 specs carry `[x]`, yet the repo holds no tests and no code — the arrow ends at EARS · *canonical arrow shape*; *tests before code*
- **F3 (high):** Branch-first allocation (the system's defining policy) lives only in body prose, not in hold-allocation's Decisions table · *decision capture*
- **F4 (high):** Branch-first allocation lets a later local hold precede an earlier county-wide one, which tenet 1 forbids · *tenets capture forward-looking preference*
- **F5 (high):** The `allocated` state has exits no spec names — cancellation while a copy is on the shelf, and clearing `allocated` when a hold closes · *LLDs close enough of the solution space*
- **F6 (medium):** PICKUP-005 re-enters allocation, but hold-allocation's Context lists only check-in and transit arrival as triggers · *cascade within a segment, pause across*
- **F7 (medium):** Goal 1's 4-business-hour notification clock and the once-a-day courier van are never reconciled for transit copies · *docs carry current intent, written to be read cold*
- **F8 (medium):** No design node owns measuring Goals 1 and 2, and "hold history is not kept" makes retention a live question · *effective intent-tree alignment*
- **F9 (medium):** Tenet 4's second sentence is a triggered rule already covered by PICKUP-003/005; the four tenets are unordered though they can conflict · *tenets capture forward-looking preference*
- **F10 (medium):** Neither spec file declares a `prefix:`, and `HOLDALLOC`/`PICKUP` don't echo their leaf directory names · *specs are grep-anchored linkage*
- **F11 (medium):** PICKUP-006's "fails to deliver" is undefined for the automated-dialer channel (bounce and undeliverable SMS are named; an unanswered call isn't) · *scope disambiguation*
- **F12 (low):** The HLD has no Non-goals and no target-users section, so the privacy stance and the six-branch boundary are inferred rather than stated · *HLD is architecture and rationale*
- **F13 (low):** Pickup notices bundles notice delivery and expiry/reallocation — one node today, but that's the natural split line if either grows · *one LLD per intent component — or split when it outgrows one node*
- **F14 (low):** No `docs/arrows/` overlay, so there's no deterministic structural audit available as the project grows · *coherence is adjacency*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/` — the entire LID surface (6 files, all of them)
- Enumerated: 2 leaf LLDs, 2 spec files, 13 EARS specs (7 `HOLDALLOC`, 6 `PICKUP`), 2 arrow segments, 3 + 4 Decisions & Alternatives rows
- Arrow-path sampling: attempted end-to-end on both segments; both terminate at EARS — greps for `@spec` across the repo returned 0 hits, and there are no source or test files
- Grepped: LID directive strings (0 hits), `@spec` (0), `[inferred]`/`[obsolete]`/`superseded`/`TODO` (0), status markers (13 × `[x]`, 0 open)
- Cold-read pass: one full pass through all four design/spec docs plus the HLD, reading with no project context
- Not a git repository, so tests-first evidence was assessed from file presence rather than commit order
- Mode: Full, as declared — reviewed project-wide, no scope exclusions

**Worth a second look:** I could not read the core skill's `references/capability-flags.md` from this session (outside the permitted directories), so I've treated the flags as applying. Models in my class are known to miss designs that contradict a project's own tenets and to under-report thin decision capture — F3, F4, and F9 are in exactly that area, so please check the two leaf designs against your four HLD tenets yourself; there may be more than the one I caught.

## Want to go further?

Want me to walk through these in detail, focus on a theme (the tenet/allocation tension, or the arrow's missing tests-and-code phases), or work through specific items together? Pick a finding and we can dig in — F3 and F4 are the pair I'd start with, since they're about the same decision from two directions.

If you have broader questions about using LID on Shelfwise — how to sequence the tests-and-code phases from a design layer that's already complete, where a PRD from the library board would sit, whether the arrow overlay is worth installing at this size — I'm glad to talk through those too.