**Shelfwise: LID coach report**

**Posture:** A clean, small design layer, but one allocation rule contradicts a tenet, and the tests and code aren't in this repo.

**Scorecard**
- ✓ Mutation hygiene: every doc reads as current intent, with no history, obsolete markers or planning notes.
- ✓ Spec linkage: IDs are unique, grep-friendly and grouped by component (`HOLDALLOC-*`, `PICKUP-*`), and every spec traces to its LLD and to an HLD component.
- ⚠ Tenet alignment: the hold-allocation design breaks the first tenet it claims to honor.
- ⚠ Decision capture: the decision table is strong except for the one choice a reader would question most.
- ✗ Arrow completeness: all 13 specs are marked done (`[x]`), but no tests or code exist here.
- ⚠ Configuration: `CLAUDE.md` declares the mode but has no LID directive block.

**Headline:** The HLD, both LLDs and both spec files are tidy and easy to read cold, and most decision-table rows name what was given up and what it costs. The most valuable next step is to settle how the "local branch first" allocation rule fits with *Waiting is honored in sequence*, then record that decision.

**Findings (7 total · 4 high · 2 medium · 1 low)**
- **F1 (high):** Local-first allocation (`hold-allocation-design.md:11`, `HOLDALLOC-003/004`) gives a copy to a newer hold at the scanning branch ahead of an older hold elsewhere. That directly contradicts the first HLD tenet: "nobody's wait is lengthened by a patron who asked after them." Either reword or demote the tenet in the HLD, or change the allocation rule. Because the conflict is between the HLD and a leaf design, the fix belongs at the HLD level. · *tenets capture forward-looking preference*: tenets are the tie-breakers future sessions lean on, so a design that quietly overrides one teaches agents to ignore both.
- **F2 (high):** The local-first choice exists only as one sentence in the body ("keeps most copies off the courier van"). It has no Decisions & Alternatives row naming the rejected option (strict county-wide order) or the accepted cost (some patrons wait longer, against tenet 1). This is a separate problem from F1: whichever way F1 is settled, the decision needs a fuller row. · *decision capture*: a choice a cold reader would try to reverse needs its trade-off written down.
- **F3 (high):** All 13 specs are checked as implemented, but the repo has no tests, no code and no `@spec` annotations. If the code lives in another repo or inside the circulation system, say so in `CLAUDE.md`. Otherwise the checkmarks claim more than the repo shows. · *canonical arrow shape*: the chain HLD → LLDs → specs → tests → code only catches drift when every stage can be walked.
- **F4 (high):** `CLAUDE.md` has the `## LID` block (`Mode: Full`, `Version: 1.4.0`) but none of the directives that name linked-intent-dev. Future sessions see the mode but not the workflow it implies. Run `/update-lid` to reconcile. · *modes are declared, not inferred*: the instruction file is the foundation every session reads first.
- **F5 (medium):** Hold cancellation is only mentioned indirectly (`HOLDALLOC-007`, the in-transit case). Several cases have no spec:
  - the patron-facing cancel action itself
  - deleting the record on cancel (the fourth tenet, *Hold history is not kept*, is only covered on the pickup and expiry paths)
  - cancelling while the copy is already on the holds shelf
  - how a copy leaves the `allocated` state after pickup
  
  · *LLDs close enough of the solution space*: open edges get filled in by whichever agent reaches them first.
- **F6 (medium):** "Failed delivery" gives examples for email and SMS only (`pickup-notices-design.md:13`, `PICKUP-006`). What counts as a failure for the automated phone dialer (no answer, voicemail, busy) is undefined. · *LLDs close enough of the solution space*
- **F7 (low):** The four tenets are an unordered list, but they can conflict. F1 is exactly the kind of clash where an order would tell a future session which tenet wins. · *tenets capture forward-looking preference*: ordered tie-breakers resolve collisions without a new conversation.

**What was audited**
- Read in full: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`hold-allocation-design.md`, `pickup-notices-design.md`) and both spec files.
- Counted: 2 LLDs, 2 spec files, 13 EARS specs (the structured requirement statements), 7 decision-table rows (all swept for decision capture) and 4 tenets.
- Code and tests: none in the repo, so there was nothing to sample for `@spec` placement. No arrow-maintenance overlay (`docs/arrows/`) is installed.
- Cold-read pass: done on all five docs. The cancellation and dialer-failure gaps came from that pass.

**Worth a second look:** I couldn't open the capability-flags reference, so I treated its flags as applying to me, which is the skill's default. Models in my class are known to miss designs that contradict the project's own tenets. I found one (F1), but please check both leaf designs against your four HLD tenets yourself.

Want me to go through the findings in detail, focus on a theme or priority, or work through specific items with you? You can also pick one finding to dig into.

If you have broader questions about using LID on Shelfwise, such as where the circulation-system integration code should live, where PRDs fit, or when a component should be split, I can help with those too.