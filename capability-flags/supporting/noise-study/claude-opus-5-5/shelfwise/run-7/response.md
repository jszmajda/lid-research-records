**LID Coach report: Shelfwise**

**Posture:** The docs are clean and well-written, but the arrow ends at the specs, and one design leans against its own tenet.

**Scorecard**
- ✓ Mutation hygiene: all five LID docs read cleanly on a cold read. There are no changelogs, no `[obsolete]` markers and no "as discussed" leftovers.
- ✓ Spec form: the EARS specs are well-formed, each ID is unique and easy to grep, and each component has its own ID prefix.
- ⚠ Tenet coherence: the hold-allocation design works against the first tenet, and pickup notices strain the third.
- ⚠ Decision capture: the most contested choice in the project has no Decisions & Alternatives row.
- ✗ Arrow completeness: all 13 specs are marked implemented, but the repo has no tests or code that cite them.
- ⚠ Configuration: `CLAUDE.md` has the Mode marker but not the LID directive block.
- ✓ Mode fit: Full mode suits a small project where both components are fully covered by the design docs.

The HLD, both component designs and their specs are consistent and easy to read cold. The most valuable next step is to settle whether "nearest branch first" or "oldest request first" wins in hold allocation, and write that answer into the tenets and the Decisions table.

**Findings (9 total · 4 high · 3 medium · 2 low)**
- **F1 (high):** Hold allocation serves the scanning branch first (`hold-allocation-design.md` Design ¶2, `HOLDALLOC-003`/`-004`). So a patron who asked later at the local branch gets the copy ahead of an older hold elsewhere in the county. That goes directly against the tenet "Waiting is honored in sequence… nobody's wait is lengthened by a patron who asked after them." Either change the design or reword the tenet. · *Tenets capture forward-looking preference* (a tenet is a tie-breaker the design is supposed to obey)
- **F2 (high):** The branch-first choice appears only as a sentence in the body ("keeps most copies off the courier van"). It has no Decisions & Alternatives row naming the rejected option (strict county-wide order) or the accepted cost (older holds at other branches wait longer, up to the daily courier cycle). A cold reader would question this choice, and F1 shows it is still an open decision. Consider a fuller table row. · *Docs carry current intent* (a live decision should be reconstructable from the page)
- **F3 (high):** All 13 specs carry `[x]`, but the project has no test or code files, so no `@spec` annotation exists to walk from any spec down to tests and code. If the implementation lives in another repo, say so in `CLAUDE.md`. If it doesn't exist yet, the `[x]` markers are claiming more than the project can show. · *Canonical arrow shape* (HLD → LLDs → EARS → Tests → Code) and *tests carry `@spec` annotations* (each test cites the spec it exercises)
- **F4 (high):** `CLAUDE.md` has a `## LID` block with `Mode: Full`, but not the linked-intent-dev directive block, so future sessions won't be told to follow the workflow. Run `/update-lid` to reconcile. · *Modes are declared, not inferred* (the configuration should be explicit, not assumed)
- **F5 (medium):** No spec covers a patron cancelling a hold. `HOLDALLOC-007` handles only the in-transit case. Nothing says the cancelled hold's record is deleted, which the "Hold history is not kept" tenet requires. Nothing says what happens to a copy that is already on the holds shelf, either, even though the hold-cap Decisions row assumes patrons can cancel. · *LLDs close enough of the solution space* (leave no edge for an agent to guess at)
- **F6 (medium):** An expired pickup window closes the hold without sending the patron anything (`PICKUP-004`/`-005`), but the tenet "Patrons hear once, clearly" says each event produces one message. Either spec an expiry notice or narrow the tenet to the events it's meant to cover. · *Coherence is adjacency* (each level agrees with the one above it)
- **F7 (medium):** The Failed delivery row sends failed notices to a staff phone call, justified by "Patrons chose their channel deliberately". But a staff call reaches the patron outside the channel they chose. A cold reader will stop at that contradiction. Consider saying why a human call is acceptable when an automated fallback is not. · *Docs carry current intent* (decision capture)
- **F8 (low):** The four tenets are unordered, and at least two pairs can conflict: waiting order vs. courier efficiency (F1), and the patron's chosen channel vs. staff calls (F7). Consider ranking them so the tie-breakers can break ties with each other. · *Tenets capture forward-looking preference*
- **F9 (low):** The component designs don't declare a `prefix:` frontmatter field. You can guess that `HOLDALLOC` maps to `hold-allocation/`, but it isn't stated. Consider adding `prefix:` so the leaf boundary is authoritative. · *Effective intent-tree alignment* (each spec prefix resolves to a named design node)

**What was audited**
- Read in full: `CLAUDE.md`, `docs/high-level-design.md`, both component designs, and both spec files.
- Counted: 1 HLD with 4 tenets and 2 goals, 2 component designs (LLDs), 2 spec files, 13 EARS specs, and 7 Decisions & Alternatives rows.
- Decisions & Alternatives sweep: all 7 rows checked. Five pass, one is questionable (F7), and one important decision has no row at all (F2).
- Tests and code: there were none to sample, so `@spec` placement and coverage couldn't be assessed.
- No `docs/arrows/` overlay was found, so there's no arrow index or drift fields.
- Configuration: the directive grep found no match; the Mode marker is present (Full).

**Worth a second look:** models in my class are known to miss designs that contradict the project's own tenets. Please check both component designs against your HLD tenets yourself. (I couldn't read the capability-flags reference in this run, so I'm assuming this flag applies.)

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project, I can help with those too. For example: multi-repo setups (relevant if the implementation behind F3 lives elsewhere), where PRDs fit, mode transitions, or what to do when a segment grows too large.