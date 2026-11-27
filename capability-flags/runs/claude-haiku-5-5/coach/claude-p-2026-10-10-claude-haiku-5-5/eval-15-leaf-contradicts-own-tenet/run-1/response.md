**LID Coach report: Shelfwise**

**Posture:** Solid design layer, with two load-bearing contradictions to resolve.

**Scorecard**
- ✓ Granularity: one LLD per HLD component, and the two components are cleanly separated.
- ✓ HLD discipline: the HLD carries problem, approach, tenets, and goals, with no schemas or signatures.
- ✓ Spec form: all 13 specs are EARS-shaped with unique, grep-friendly IDs, and their scope sits in the WHEN clauses.
- ✓ Decision capture: most Decisions rows name the rejected alternative and the accepted cost, including the Goal 1 trade-off in pickup expiry.
- ⚠ Coherence: the pickup-notices LLD disagrees with its own Decisions row and with PICKUP-005 on when a lapsed copy is reallocated.
- ⚠ Tenet cascade: local-first allocation pulls against "waiting is honored in sequence," and that trade-off isn't recorded.
- ⚠ Configuration: `CLAUDE.md` has the `## LID` mode block but no LID directive.

**Headline:** The arrow is well-shaped at the design and spec levels, and most trade-offs are written down with their costs. The fastest wins are reconciling the expiry-timing contradiction and deciding how the local-first rule should interact with the waiting-in-sequence tenet.

**Findings (12 total · 4 high · 5 medium · 3 low)**

- **F1 (high):** `CLAUDE.md` has the mode block (`Mode: Full`, `Version: 1.4.0`) but no reference to linked-intent-dev, so agents aren't pointed at the methodology · *modes are declared, not inferred* (the instruction file is where LID's configuration lives)
- **F2 (high):** `pickup-notices-design.md` says a lapsed copy's hold closes and the copy is re-run through allocation at lapse, but the Expiry handling row and PICKUP-004/005 say reallocation waits until staff scan it off the shelf · *coherence is adjacency* (the doc and its spec should agree)
- **F3 (high):** Local-first allocation (HOLDALLOC-003/004, hold-allocation design) can give a copy to a newer hold at branch B ahead of an older hold at branch A, which lengthens the older patron's wait · *tenet cascade* (the mechanism works against the tenet "waiting is honored in sequence"; the design shows no recorded exception)
- **F4 (medium):** The local-first priority has no Decisions row. The courier-van rationale lives only in design prose, so a cold reader can't see what was given up · *decision capture* (a live choice should name its rejected alternative and cost)
- **F5 (medium):** The four HLD tenets are an unordered list, but the local-first case shows two of them can collide, and nothing says which wins · *tenets capture forward-looking preference* (ordering matters once tenets can conflict)
- **F6 (medium):** No tests or code exist in this repo, so the arrow stops at specs and no `@spec` annotations can exist yet. If code lives in another repository, this is a multi-repo setup; if it should live here, the tests and code phases are missing · *canonical arrow shape* (each phase should exist for components in scope)
- **F7 (medium):** All 13 specs are marked `[x]`, but nothing in the repo verifies them and no legend says what `[x]` means · *coherence is adjacency* (a done marker with no tests behind it reads as verified)
- **F8 (medium):** Some LLD behaviors have no spec: hold cancellation as an operation, the `allocated` marking, and the channel choice at signup · *effective intent-tree alignment* (behaviors without specs drift silently)
- **F9 (low):** "Hold history is not kept" and "Patrons hear once, clearly" read as spec-shaped rules rather than tie-breakers, and PICKUP-003/005 already cover the deletion · *tenets capture forward-looking preference* (a tenet should lean one way when two choices are defensible)
- **F10 (low):** The LLDs have no `prefix:` frontmatter, so `HOLDALLOC` and `PICKUP` resolve to their leaves by name only · *specs are grep-anchored linkage* (an explicit prefix makes the leaf boundary unambiguous)
- **F11 (low):** Pickup failure routes to a staff phone call through the exceptions list, which is a second contact the patron didn't pick. The Decisions row records this cost, so it's noted here, not flagged · *patrons hear once, clearly*

**What was audited**
- **Dispatch:** The instruction file has the mode block but no LID directive. With LID-shaped artifacts present, this is a full review, and F1 is the reconciliation finding.
- **Read fully:** `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`hold-allocation-design.md`, `pickup-notices-design.md`), and both spec files.
- **Enumerated:** 2 LLDs, 2 spec files, 13 specs (HOLDALLOC-001–007, PICKUP-001–006). Git history is one commit, so cascade timing can't be read from history.
- **Not present:** no code, no tests, no `@spec` annotations, no arrow overlay. Arrow-path sampling doesn't apply, and no structural audit is needed (`/arrow-maintenance` isn't installed).
- **Capability flags:** none are recorded in the core skill's `capability-flags.md`, so no flag note applies.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project (multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large), I can help with those too.