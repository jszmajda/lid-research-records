# LID Coach Report: Shelfwise

**Posture:** The design layer is clean and small. One allocation rule contradicts its own tenet, and the arrow stops at specs.

**Scorecard**
- ✓ HLD discipline: problem, approach, tenets, goals and components, with no schemas or signatures leaking upstream
- ✓ Mutation hygiene: no change-narration, obsolete markers or conversational fossils in any doc
- ✗ Tenet alignment: hold allocation's local-branch-first rule works against "Waiting is honored in sequence"
- ⚠ Decision capture: most Decisions tables are exemplary, but the most consequential allocation choice isn't in one
- ⚠ LLD sufficiency: a couple of hold-allocation edges are still open for an agent to guess
- ✗ Arrow completeness: 13 specs are marked `[x]`, but there are no tests or code in the repo to back them

**Headline:** The HLD is sharp, the two LLDs match its components one-to-one, and the Decisions tables name what was rejected and what it costs. The most valuable next step is to settle how local-branch-first allocation fits with your first tenet, then record whichever way you decide.

**Findings (8 total · 5 high · 2 medium · 1 low)**
- **F1 (high):** Hold allocation serves the oldest hold *at the scanning branch* before older holds county-wide (`hold-allocation-design.md:11`, HOLDALLOC-003/004). That directly lengthens earlier patrons' waits, which the first tenet says should never happen. Either the tenet or the rule needs to give. · *tenets capture forward-looking preference*: tenets are tie-breakers, and designs should lean the way they point
- **F2 (high):** The local-first choice appears only as a line of body prose ("keeps most copies off the courier van"). It has no Decisions row naming the rejected option (strict county-wide order) or the cost accepted (earlier requesters at other branches wait longer). · *decision capture*: a live choice a cold reader would question needs its tradeoff on the page
- **F3 (high):** All 13 specs are marked `[x]` (implemented), but the project has no test or code files and no `@spec` annotations. Either the implementation lives elsewhere and isn't linked, or the status markers are ahead of reality. · *canonical arrow shape* (HLD → LLD → EARS → Tests → Code, each level present) and *tests carry `@spec` annotations*
- **F4 (high):** HOLDALLOC-003/004 allocate to "the oldest open hold", but nothing excludes a hold that already has a copy allocated or in transit. A second returned copy could go to the same patron. · *LLDs close enough of the solution space*: two agents reading it should build compatible behavior
- **F5 (high):** `CLAUDE.md` has the `## LID` mode block but no LID directive block. Future sessions get the mode but not the workflow instructions. Run `/update-lid` to reconcile. · *modes are declared, not inferred*: configuration should be explicit and complete
- **F6 (medium):** Hold cancellation is only covered for in-transit copies. There is no spec for cancelling a hold, deleting its record (which the "Hold history is not kept" tenet requires), releasing a copy already on the holds shelf, or saying when the `allocated` status clears. · *LLDs close enough of the solution space*
- **F7 (medium):** HOLDALLOC-004's trigger ("no open hold for its title names the scanning branch") also matches when there are no holds at all, which is the case HOLDALLOC-005 covers. Consider adding "open holds exist for its title, but none…". · *scope disambiguation*: a spec's WHEN clause should match only the cases it means
- **F8 (low):** The four tenets aren't ranked, yet they visibly compete: sequence vs. courier efficiency (see F1), and staff-handles-exceptions vs. patrons-hear-once on failed delivery. · *tenets capture forward-looking preference*: an order tells a future session which one wins

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`hold-allocation-design.md`, `pickup-notices-design.md`) and both spec files
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 13 EARS specs (HOLDALLOC-001–007, PICKUP-001–006)
- Code and tests: none present, so there was nothing to sample; 0 `@spec` references
- Arrow-maintenance overlay: not installed (no `docs/arrows/`)
- Decisions-table sweep: 7 rows checked. All pass the cold-reader test; the gap is the missing row flagged in F2.
- Dispatch: the mode marker is present (Full) but the directive block is absent, and the LID artifacts are in place, so this is a full review with the gap raised as F5

**Worth a second look:** I couldn't open the capability-flags reference, so I'm assuming the known limits apply to me. Models in my class are known to miss designs that contradict the project's own tenets. Please check both leaf designs against your HLD tenets yourself; F1 is one case, and there may be others.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick one finding to dig into.

If you have broader questions about using LID for your project, such as multi-repo setups, where PRDs fit, mode transitions, or what to do when a segment grows too large, I can help with those too.