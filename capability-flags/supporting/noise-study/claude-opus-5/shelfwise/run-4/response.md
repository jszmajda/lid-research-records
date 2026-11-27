**Shelfwise — LID Coach Report**

## Executive summary

**Posture: Bootstrapping — a clean, cold-readable design layer; the arrow stops at specs.**

**Scorecard**
- ✓ Design-layer shape — two leaves that match the HLD's two components exactly; no lumping, no fragmentation
- ✓ Mutation hygiene — no change-narration, no `[obsolete]` residue, no planning text; both designs read as current intent
- ✓ Decision capture (mostly) — six of seven Decisions rows name the rejected option *and* the accepted cost, which is better than most projects manage
- ✗ Arrow completeness — all 13 specs are marked `[x]` while no tests or code exist anywhere in the repo
- ⚠ Configuration — the `## LID` block declares `Mode: Full` but carries no LID directives at all
- ⚠ Tenet coherence — the branch-first allocation rule leans against Tenet 1; the tenets aren't ordered to break that tie
- ⚠ Goal traceability — neither goal has a design node that produces the number it is judged by

**Headline.** The design layer here is genuinely strong — tight scoping, well-formed EARS with real trigger clauses, and Decisions tables that a cold reader can actually reconstruct — so the highest-value next step is small: reconcile the instruction file with `/update-lid` and settle whether the checked-off specs mean "implemented elsewhere" or "designed, not yet built," because everything downstream of EARS currently reads as done when nothing is there.

## Findings (12 total · 3 high · 7 medium · 2 low)

- **F1 (high):** `CLAUDE.md`'s `## LID` block carries `Mode: Full` and `Version: 1.4.0` but no LID directives — nothing tells a fresh session to walk the arrow · *modes are declared, not inferred* — an unread mode is just a default, and here the workflow itself is unstated → `/update-lid`
- **F2 (high):** All 13 specs are marked `[x]` complete, yet the repo holds no tests, no code, and zero `@spec` annotations · *coherence is adjacency* — each arrow level should agree with its neighbor; today "done" has nothing behind it
- **F3 (high):** HOLDALLOC-003's branch-first rule hands a copy to a later local requester ahead of an earlier county-wide one, which is the thing Tenet 1 ("nobody's wait is lengthened by a patron who asked after them") forbids; the tenets are also unordered, so nothing breaks the tie between sequence and courier economy · *tenets capture forward-looking preference*
- **F4 (medium):** Goal 1 (median under 4 business hours from check-in to notification) sits against a design where transit copies wait for a van that runs once a day and the notice only fires on holds-shelf scan; neither doc reconciles the two · *coherence is adjacency*
- **F5 (medium):** Nothing in the arrow produces the numbers either goal is measured by, and closing a hold deletes its record (PICKUP-003, PICKUP-005, Tenet 4) — so the expiry rate the pickup-notices Decisions table says is "watched against Goal 2" has no source and no owning node · *effective intent-tree alignment*
- **F6 (medium):** Hold placement (HOLDALLOC-001) and the patron-facing limit message (HOLDALLOC-002) — plus hold cancellation, which both leaves reference — belong to no design node; the HLD's Approach starts at check-in · *effective intent-tree alignment*
- **F7 (medium):** The HLD has no Non-goals and no Key Design Decisions section, and never draws the line between Shelfwise and the circulation system, so "the system shall" is ambiguous in every spec — who owns the catalog, patron records, the request surface, the dialer? · *HLD is architecture and rationale*
- **F8 (medium):** The single most consequential choice in the project — branch-first over strict county-wide FIFO — has no Decisions row; it survives as one clause of body prose ("This keeps most copies off the courier van") · *docs carry current intent*, keep-side — a cold reader would still question this one
- **F9 (medium):** Tenet 4 ("Hold history is not kept") reads as a landed decision pinned by specs rather than a forward-looking lean · *tenets capture forward-looking preference* — a tenet's job is to break ties no spec covers
- **F10 (medium):** Two solution-space edges sit open between the leaves: a copy allocated at check-in but never scanned onto the shelf, and the transit-arrival scan implied between HOLDALLOC-004 and PICKUP-001 · *LLDs close enough of the solution space*
- **F11 (low):** Neither spec file carries `prefix:` frontmatter, and the prefixes (`HOLDALLOC`, `PICKUP`) don't mirror their leaf directory names · *specs are grep-anchored linkage*
- **F12 (low):** HOLDALLOC-002 uses the If/then unwanted-behavior form for what is really a state-driven limit ("While a patron has 15 open holds…") · EARS hygiene under *specs are grep-anchored linkage*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, and all four files under `docs/intent/` (two designs, two spec files) — the entire LID surface of this project, 6 files
- Enumerated: 2 leaf LLDs, 2 spec files, 13 EARS specs (7 `HOLDALLOC`, 6 `PICKUP`), 2 arrow segments, 4 HLD tenets, 2 goals, 7 Decisions & Alternatives rows
- Arrow-path sampled: both segments end-to-end as far as they go — HLD Components → leaf design → specs → **stop** (no tests, no code)
- Linkage metric: 0 `@spec` references repo-wide; repo-wide grep also found no occurrence of `linked-intent-dev` or `Linked-Intent Development`
- Cold-read pass: both designs and the HLD read as current intent with no history residue or in-conversation-only meaning — the ambiguities surfaced above (system boundary, who places holds, how goals are measured) are missing-content gaps, not accumulation
- Not present, and fine at this size: `docs/arrows/` (no arrow-maintenance overlay) and no git history, so tests-first evidence couldn't be checked from commits
- Defaults taken in this non-interactive run: reviewed at the declared `Mode: Full` with no scope restriction, and proceeded with a full review despite the absent directive block (F1) because the project is clearly LID-shaped

**Worth a second look:** I could not read the core skill's capability-flags reference in this session, so I'm treating its flags as applying to me. The one that bears on this review is designs that quietly contradict the project's own tenets — I flagged the allocation-vs-Tenet-1 tension in F3, but please read the two leaf designs against all four HLD tenets yourself, particularly Tenet 3 ("patrons hear once") against the exceptions-list path in PICKUP-006.

---

Want me to walk through the findings in detail, focus on a theme or priority band, or work through specific items together? You can also pick a single finding — F3 and F8 are the same decision seen from two sides and are probably the most productive pair to start with.

If you have broader questions about using LID on Shelfwise — when to add the arrow-maintenance overlay, where a PRD for the circulation-system integration would fit, whether the metrics concern in F5 wants its own cross-cutting node, or what to do as these two leaves grow — I'm happy to work through those too.