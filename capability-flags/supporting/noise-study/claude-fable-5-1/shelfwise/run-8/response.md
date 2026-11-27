**Shelfwise — LID Coach Report**

**Posture:** Bootstrapping — the design layer is clean and cold-readable; the arrow stops at specs.

**Scorecard**
- ✓ HLD discipline — lean, architecture-level, no implementation detail bleeding upstream
- ✓ Linkage & spec hygiene — unique, namespaced, grep-friendly IDs; every LLD claim has a matching EARS spec
- ⚠ Configuration — `## LID` block declares Full mode, but the instruction file carries no LID directives
- ⚠ LLD sufficiency — hold states, the event vocabulary, and cancellation are left for the implementer to guess
- ⚠ Tenet ↔ design coherence — branch-local-first routing quietly bends "Waiting is honored in sequence"
- ✗ Arrow completeness — no tests or code anywhere in the tree, while all 13 specs are marked `[x]`

**Headline:** The design layer is in good shape — a lean HLD with real tenets, two well-scoped LLDs whose Decisions tables mostly read cold, and 13 EARS specs that trace cleanly to them; the fastest wins are reconciling the instruction file with `/update-lid` and walking the first tests-first change so the done-markers mean something.

**Findings (12 total · 3 high · 5 medium · 4 low)**
- **F1 (high):** `CLAUDE.md` has the `## LID` mode block but no LID directives — run `/update-lid` to reconcile · *modes are declared, not inferred* (the instruction file is where LID learns how to behave; a bare mode marker with no directive block leaves every session guessing)
- **F2 (high):** All 13 specs are marked `[x]` but the project contains no tests and no code; the arrow ends at EARS · *coherence is adjacency* (each level agrees with its neighbor — a "done" spec with no test or code behind it is a seam with nothing on the other side) and *tests before code*
- **F3 (high):** Hold allocation routes copies to the oldest hold *at the scanning branch* before an older hold elsewhere, contradicting the HLD tenet "Waiting is honored in sequence … nobody's wait is lengthened by a patron who asked after them" — resolve at the HLD, by refining the tenet or changing the design · *intent attaches at the lowest node that dominates it* (a tenet is HLD-level; a leaf shouldn't silently reverse it)
- **F4 (medium):** The branch-local-first choice has no Decisions & Alternatives row — its rationale ("keeps most copies off the courier van") sits in body prose, and the rejected alternative (strict county-wide FIFO) and accepted cost (a patron elsewhere waits longer) are unrecorded · *decision capture* (a cold reader would pause at this choice and can't reconstruct it)
- **F5 (medium):** Hold lifecycle states are undefined — "open" is used in HOLDALLOC-002/003/004 without saying whether an already-`allocated` or on-shelf hold still counts as open, for the 15-hold cap or for a second check-in of the same title · *LLDs close enough of the solution space* (two agents reading this would build incompatible state models)
- **F6 (medium):** Only the check-in event is defined in Context, yet specs trigger on "arrives at a branch" (HOLDALLOC-007), "scanned onto a holds shelf" (PICKUP-001), and "scan a lapsed copy off" (PICKUP-005) — name the events Shelfwise receives and which scan is which · *LLDs close enough of the solution space*
- **F7 (medium):** Hold cancellation is referenced (HOLDALLOC-007) but never specified — no placement/cancel behavior, nothing for a cancel while the copy is on the shelf, and no deletion spec even though the "Hold history is not kept" tenet implies one · *effective intent-tree alignment* (LLD behavior with no spec is unnamed intent that drifts silently)
- **F8 (medium):** The HLD has no Non-goals and no Key Design Decisions; the event-driven-trigger choice, whose accepted cost ("Shelfwise must be up whenever desks are open") is system-wide, lives only in the hold-allocation leaf · *HLD is architecture and rationale* and *intent attaches at the lowest node that dominates it*
- **F9 (low):** Neither LLD declares a `prefix:` in frontmatter; the HOLDALLOC → hold-allocation and PICKUP → pickup-notices mapping is inferred from names rather than declared · *specs are grep-anchored linkage* (the leaf's declared prefix is what makes the arrow boundary machine-walkable)
- **F10 (low):** "Hold history is not kept" is phrased half as a lean, half as a triggered rule ("a closed hold's record is deleted" — already PICKUP-003/005), and the four tenets are unordered though the reminders decision shows they can pull against goals · *tenets capture forward-looking preference* (a tenet is a tie-breaker; triggered actions belong in EARS)
- **F11 (low):** Two defensive asides in the pickup-notices body prose ("No reminder follows"; "does not trigger a fallback channel") restate what the Decisions rows already capture — consider whether a fresh author would write them there · *docs carry current intent, written to be read cold* (the rejected alternative belongs in the Decisions table, not as an aside)
- **F12 (low):** Cold-read loose ends — "Patrons choose one contact channel at signup" (signup to what?); what "fails to deliver" means for the automated dialer; whether a 7-*calendar*-day window is intended when Goal 1 is stated in business hours · *docs carry current intent, written to be read cold*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`hold-allocation-design.md`, `pickup-notices-design.md`), both spec files.
- Enumerated: 2 LLDs, 2 spec files, 13 spec IDs (7 HOLDALLOC, 6 PICKUP), 0 `@spec` references, 0 code files, 0 test files.
- Not present: `docs/arrows/` overlay, `## LID Scope` (not needed in Full mode), any `[inferred]` markers, any change-narration residue.
- Not a git repository, so tests-before-code ordering could not be checked from history.
- Sampling: none required; the whole project was read, and every Decisions-table row (7) was swept.

**Worth a second look:** I could not read the capability-flags reference in this session, so I'm treating its flags as applying to me. Models in my class are known to miss designs that contradict the project's own tenets — F3 is one I did catch, but please check both leaf designs against all four HLD tenets yourself.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.