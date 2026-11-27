# LID Coach Report: Shelfwise

**Posture:** The design layer is clean and compact, but one tenet conflicts with the allocation design, and the arrow stops at the specs.

**Scorecard**
- ✓ Mutation hygiene: docs read as current intent, with no changelog residue or obsolete markers
- ✓ Linkage IDs: spec IDs are unique, stable, and grep-friendly; prefixes match their design docs
- ⚠ Tenet coherence: the hold-allocation design goes against the first HLD tenet
- ⚠ LLD sufficiency: the hold lifecycle and cancellation are left open
- ✗ Arrow completeness: all specs are marked `[x]`, but the repo has no tests or code citing them
- ⚠ Configuration: `CLAUDE.md` has the `## LID` mode block but no LID directives

**Headline:** The HLD is short and focused on *why*. Its tenets are real tie-breakers, and most rows in the Decisions tables name the rejected option and the cost you accepted. The most useful next step is to settle whether "waiting is honored in sequence" or "keep copies off the courier van" wins in hold allocation, and write that answer down.

**Findings (8 total · 4 high · 3 medium · 1 low)**
- **F1 (high):** The allocation design gives a copy to a *newer* hold at the scanning branch ahead of an *older* hold at another branch (`hold-allocation-design.md` §Design; HOLDALLOC-003/004). The HLD tenet "nobody's wait is lengthened by a patron who asked after them" says the opposite. Consider either changing the tenet (for example, "in sequence, except a copy stays local when someone local is waiting") or changing the allocation rule. · *tenets capture forward-looking preference*: tenets exist so that choices a spec didn't anticipate lean the way you want, and this one leans against its own tenet.
- **F2 (high):** The branch-first allocation choice appears only as one line of body text ("keeps most copies off the courier van"). It has no Decisions & Alternatives row, so strict county-wide first-come-first-served is never named as the rejected option, and the cost (older holds elsewhere wait an extra courier cycle or more) is never stated. Try adding a fuller row. · *docs carry current intent*: a decision a cold reader would question needs its tradeoff on the page.
- **F3 (high):** Every HOLDALLOC and PICKUP spec is checked `[x]`, but the repo has no test or code files, and so no `@spec` citations. If the implementation lives in another repo, say so in `CLAUDE.md`. If it doesn't exist yet, the markers claim more than has been built. · *canonical arrow shape*: HLD → LLD → EARS → Tests → Code, with each phase present or its absence explained.
- **F4 (high):** `CLAUDE.md` has the `## LID` block with `Mode: Full`, but no linked-intent-dev directive block, so future sessions don't get told how to use the arrow. Run `/update-lid` to reconcile. · *modes are declared, not inferred*: the setup that sessions depend on should be written into the instruction file.
- **F5 (medium):** "Open hold" is never defined against the hold's later stages (allocated, in transit, on shelf). Nothing states that a hold which already has a copy allocated drops out of matching. Two agents could reasonably build versions where one hold receives two copies. · *LLDs close enough of the solution space*: two agents reading the doc should end up with compatible implementations.
- **F6 (medium):** Hold cancellation shows up in the LLD (the in-transit case) and in HOLDALLOC-007, but no spec covers the cancellation itself. In particular, no spec requires deleting a cancelled hold's record, which the tenet "Hold history is not kept" calls for. · *effective intent-tree alignment*: behavior the design describes should have a spec so it can be tested.
- **F7 (medium):** The four tenets aren't ordered, and F1 shows they can already pull against efficiency concerns. If the courier constraint is a real preference, consider stating it as a tenet and ranking it against sequence fairness. · *tenets capture forward-looking preference*: an ordered list says which tenet wins when two conflict.
- **F8 (low):** PICKUP-006's idea of "fails to deliver" is written with email and SMS in mind, and the pickup-notices design only gives email and SMS examples of a failure. The phone-dialer channel has no stated failure condition (no answer? voicemail?). Consider making the WHEN clause cover each channel. · *scope disambiguation*: a spec that sounds universal should stay unambiguous for every variant it covers.

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, and both design docs and both spec files under `docs/intent/`
- Enumerated: 2 LLDs, 2 spec files, 13 EARS specs, 7 Decisions-table rows (6 pass the cold-reader sweep; the missing branch-first row is F2)
- Code/tests: none found in the project tree, so there was nothing to sample and no `@spec` references
- Overlay: `docs/arrows/` isn't present
- Dispatch: `CLAUDE.md` has no directives, but the project has LID-shaped artifacts, so I ran a full review in the default Full mode
- Couldn't read: the capability-flags reference (`linked-intent-dev/references/capability-flags.md`) wasn't accessible in this run. Following the skill's default, I treated the flags as applying.

**Worth a second look:** models in my class are known to miss designs that contradict a project's own tenets. Please check both LLDs against your four HLD tenets yourself; F1 may not be the only one.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick one finding to dig into.

If you have broader questions about using LID on Shelfwise, such as multi-repo setups (for example, if the code lives elsewhere), where PRDs fit, switching modes, or what to do when a segment grows too large, I can help with those too.