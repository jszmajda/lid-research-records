# LID Coach — Shelfwise

**Posture:** Clean, disciplined intent layer; the arrow currently stops at the spec level, and one tenet is out of step with the allocation design.

**Scorecard**
- ✓ Mutation hygiene — every doc reads as current intent; no changelogs, "was X now Y" narration, `[obsolete]` specs, or stale `[inferred]` markers anywhere
- ✓ HLD discipline — architecture and rationale only; no schemas, signatures, or pseudocode bleeding upstream
- ✓ Intent-tree alignment — two HLD components → two leaf designs → two spec files; both spec prefixes resolve cleanly, no orphans
- ⚠ Tenet quality — these are real tenets, not platitudes, but they're unordered and one is contradicted by the design downstream
- ⚠ Decision capture — the Decisions tables that exist are genuinely good; the single most consequential decision isn't in one
- ✗ Arrow completeness — no tests or code phase exists yet, while all 13 specs are marked complete

**Headline:** For a project this young, the intent layer is in unusually good shape — tight EARS specs in proper form, a rationale-only HLD, and Decisions & Alternatives tables that actually name the rejected option and the accepted cost (the pickup-window and reminders rows are model examples). The highest-value next move is small: settle the branch-local allocation preference against the "waiting is honored in sequence" tenet and record that decision where it belongs, before code starts assuming one answer.

**Findings (14 total · 5 high · 7 medium · 2 low)**
- **F1 (high):** `CLAUDE.md`'s `## LID` block carries mode and version but no LID directive block — nothing names the methodology · *modes are declared, not inferred* — the foundation should be visible on the page, not assumed · run `/update-lid`
- **F2 (high):** Allocation prefers holds at the scanning branch over older county-wide holds (`hold-allocation-design.md:11`, HOLDALLOC-003/004, again via PICKUP-005), which lengthens an earlier patron's wait — the opposite of the tenet "Waiting is honored in sequence" · *coherence is adjacency* — each level agrees with its neighbor
- **F3 (high):** That branch-preference rule — the system's most consequential choice, governing both components — appears only as prose with no Decisions & Alternatives row, and sits inside one leaf though it dominates both · *decision capture* + *intent attaches at the lowest node that dominates it*
- **F4 (high):** All 13 specs are marked `[x]` while the repo contains no tests and no code — the arrow stops at EARS · *tests before code*; *canonical arrow shape*
- **F5 (high):** Closing a hold deletes its record (PICKUP-003/005, tenet "Hold history is not kept"), yet both HLD goals are statistical (median notification time; expiry rate under 10%) and no spec produces those numbers · *effective intent-tree alignment* — goals with no downstream intent drift silently
- **F6 (medium):** Hold lifecycle vocabulary is never enumerated — "open", `allocated`, in-transit, on-shelf, "closed" appear across docs with no state model; "15 open holds" (HOLDALLOC-002) doesn't say whether an allocated or shelf-ready hold still counts; equal placement timestamps have no tie-break · *LLDs close enough of the solution space*
- **F7 (medium):** The transit seam is unowned — HOLDALLOC-004 ends at the printed slip, PICKUP-001 begins at the holds-shelf scan, and nothing specs the arrival scan in between; conversely PICKUP-005 re-enters allocation but hold-allocation's specs name only the cancelled-in-transit path (HOLDALLOC-007) · *coherence is adjacency*
- **F8 (medium):** Cancellation is only partly specified — HOLDALLOC-007 covers cancelling while a copy is in transit; a plain open hold, or one whose copy is already on the shelf, has no spec · *LLDs close enough of the solution space*
- **F9 (medium):** "the patron's chosen channel" (PICKUP-002, `pickup-notices-design.md:5`) is load-bearing but never defined — no spec stores it, changes it, or handles its absence · *docs carry current intent, written to be read cold*
- **F10 (medium):** The HLD has no non-goals or target users, so the boundary is implicit — notably the title-level decision pushes edition modeling ("large print, audiobook must be separate title IDs") onto a catalog Shelfwise doesn't own · *HLD is architecture and rationale*
- **F11 (medium):** Four tenets, unordered, at least two pairs of which can collide — "Patrons hear once, clearly" against Goal 2's expiry target (the reminders row trades exactly this), and sequence-honoring against keeping copies off the once-daily courier van · *tenets capture forward-looking preference*
- **F12 (medium):** Time is mixed and under-specified — a 7-*calendar*-day window against a *business*-hours goal, a "last pickup date" that may land on a day the branch is closed, and "next morning's pull list" / "that day's exceptions list" with no spec saying when either is generated · *scope disambiguation*
- **F13 (low):** Spec-ID-to-leaf resolution isn't mechanical — spec files carry no `prefix:` frontmatter and no link back to their design doc, and `HOLDALLOC` / `PICKUP` don't quite echo `hold-allocation` / `pickup-notices` · *specs are grep-anchored linkage*
- **F14 (low):** "Hold history is not kept" reads as a fixed rule already fixed by PICKUP-003/005 rather than a lean for undecided cases; consider whether the tenet is the privacy *preference* behind it · *tenets capture forward-looking preference* (lean-not-trigger)

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, and all four files under `docs/intent/` — the entire repository is 6 files
- Enumerated: 2 leaf designs, 2 spec files, 13 EARS specs (7 `HOLDALLOC`, 6 `PICKUP`), 4 tenets, 2 goals, 7 Decisions & Alternatives rows
- Linkage metric: 0 `@spec` annotations — no code or test files exist anywhere in the tree, so no arrow path could be sampled past EARS
- Not present: `docs/arrows/` overlay (reasonable at two segments; `/arrow-maintenance` isn't available here, which is why F7 surfaces the seam as a pattern rather than an enumeration)
- Cold-read pass run over all five LID docs; mechanical screen for change-narration, `[obsolete]`, and `[inferred]` residue came back empty
- Notes on this run: non-interactive, so no clarifying questions were asked; declared mode (Full) was used as-is, and the capability-flags reference was outside the readable paths, so its flags are treated as applying

**Worth a second look:** models in my class are known to miss designs that contradict the project's own tenets. F2 is one such contradiction, but please check both leaf designs against all four HLD tenets yourself — particularly "Staff attention goes to exceptions" against the pull list and exceptions list, which add two daily staff routines.

Want me to walk through the findings in detail, focus on a theme or priority band, or work through specific items together? You can also pick a single finding — F2 and F3 are the pair I'd start with, since they're one conversation and everything downstream inherits the answer.

If you have broader questions about using LID for Shelfwise — when to start the tests phase, whether the notification-metrics concern in F5 wants its own node, where a PRD from the library board would fit, or what to do as these two components grow — I'm happy to work through those too.