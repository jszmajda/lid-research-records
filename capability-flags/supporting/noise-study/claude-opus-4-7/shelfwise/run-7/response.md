**LID Coach — Review of Shelfwise**

*Non-interactive run defaults noted:* project state matches the dispatch table's "fully configured" row (LID directives in `CLAUDE.md`, `Mode: Full`, standard directories, no scope declaration required for Full mode), so I proceeded with a full review without prompting.

---

## Executive summary

**Posture:** *Bootstrapping — design layer well-formed, downstream phases not yet in place.*

**Scorecard**
- ✓ HLD shape — Problem, Approach, Tenets, Goals, Components all present; no implementation detail creeping upstream
- ✓ Tenets — four tenets, each with a genuinely defensible opposite (another library could plausibly keep hold history, or send reminders, etc.)
- ✓ Linkage foundation — spec IDs are grep-anchored, prefix per leaf LLD, zero-padded and sequential; no collisions
- ⚠ LLD sufficiency — hold cancellation and hold placement flows have open edges the specs don't close
- ⚠ Mutation hygiene — every spec carries an `[x]` status marker whose meaning is ambiguous given no code exists
- ⚠ Arrow completeness — tests and code phases are absent; whether this is intentional bootstrap or drift is unstated

**Headline:** The two-component design is real and clean — an HLD that stays at architecture, LLDs that carry both design and Decisions tables, and specs that trace cleanly back through their leaf prefixes. The fastest wins are (a) closing two open edges in `hold-allocation` (cancel and place-with-available-copy) and (b) resolving the `[x]` marker convention so the checkbox stops competing with "presence means current."

## Findings (6 total · 2 high · 3 medium · 1 low)

- **F1 (high):** Hold *cancellation* is invoked by `HOLDALLOC-007` and by the design prose, but no spec defines the cancel action itself · *LLDs close enough of the solution space*
- **F2 (high):** No spec or decision-row addresses hold placement when a copy for that title is already on-shelf — either an implicit decision or a real gap · *docs carry current intent* / *LLDs close enough of the solution space*
- **F3 (medium):** Every spec is marked `[x]`, though no code or tests exist to have implemented them · *mutation, not accumulation*
- **F4 (medium):** Arrow phases below EARS — tests and code — are absent, and no note in the HLD or LLDs explains whether this is a deliberate bootstrap pause · *canonical arrow shape*
- **F5 (medium):** Goal 2 (measuring expiry rate) and Tenet 4 ("Hold history is not kept") read as being in tension for a cold reader, with no reconciliation on the page · *docs carry current intent, written to be read cold*
- **F6 (low):** The HLD's Approach implicitly assumes the reader knows the actors (circulation staff, patrons, courier) but does not name target users or non-goals explicitly · *HLD is architecture and rationale*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLD design files (`hold-allocation-design.md`, `pickup-notices-design.md`), both spec files (`hold-allocation-specs.md`, `pickup-notices-specs.md`)
- Enumerated: 2 leaf LLDs, 2 spec files, 13 EARS specs total (7 HOLDALLOC + 6 PICKUP), 4 HLD tenets, 7 Decisions & Alternatives rows across the two LLDs
- Arrow-path sampling: not applicable — the project sits under the 15-LLD / 200-`@spec` threshold and has no code or test phase to sample against
- Overlay: no `docs/arrows/` directory — arrow-maintenance overlay is not installed (fine; it's opt-in)
- Cold-read pass: performed against every doc; F2, F5, and F6 came out of that pass
- Decisions-table sweep: performed against all 7 rows — each stands on its own for a cold reader (rejected alternative + accepted cost both present); no capture findings from the sweep itself. F2 is a *missing row*, which is a distinct thing.

## Worth a second look

I couldn't place myself against the core skill's `references/capability-flags.md` from this session (it's outside my accessible paths), so per the skill I'm treating flags as applying. In particular, models in my tier are known to miss designs that quietly contradict a project's own tenets — please sanity-check F5 (Goal 2 vs Tenet 4) yourself, and give the Decisions tables a second read for anything I may have accepted on tone.

## Want to go deeper?

Want me to walk through the findings in detail, focus on a theme or a specific priority (e.g., just the two high-priority ones), or work through a specific finding together? You can pick any one to dig into.

If you have broader questions about using LID for this project — where a PRD might sit upstream of this HLD, when to add tests/code phases and how to introduce `@spec` annotations as the first code lands, whether the two-component split will hold as you add features, or when the arrow-maintenance overlay starts paying for itself — I can help with those too.