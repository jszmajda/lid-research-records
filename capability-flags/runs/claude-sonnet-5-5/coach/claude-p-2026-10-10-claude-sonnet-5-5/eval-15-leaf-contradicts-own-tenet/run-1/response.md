## Shelfwise: LID coach report

**Posture:** Well-shaped design tree, with one tenet–design conflict and an instruction file that needs reconciling.

**Scorecard**
- ✓ Arrow shape: HLD → 2 LLDs → EARS specs, with clean one-component-per-LLD granularity
- ✓ Mutation hygiene: no change-narration, `[obsolete]` markers, or history residue in any doc
- ✓ Decision capture in pickup-notices: each row names the rejected option and the accepted cost
- ✓ Spec hygiene: unique, grep-friendly IDs (`HOLDALLOC-001`…`007`, `PICKUP-001`…`006`) whose prefixes match their LLDs
- ⚠ Tenet cascade: the allocation rule works against the HLD's first tenet
- ⚠ Configuration: the instruction file has a `## LID` block but no LID directives
- ⚠ Lower arrow phases: no tests or code visible to check specs against

**Headline:** The design is cleanly layered, the specs are consistently EARS-shaped, and your pickup-notices Decisions table is exactly the kind of record a cold reader needs. The most valuable next step is to look at how hold allocation treats "oldest hold" against your *Waiting is honored in sequence* tenet.

**Findings (7 total · 2 high · 3 medium · 2 low)**
- **F1 (high):** Local-branch-first allocation (`HOLDALLOC-003`/`-004`) lets a newer hold at the scanning branch take a copy ahead of an older hold elsewhere, which cuts against the "waiting is honored in sequence" tenet and has no recorded exception · *tenets capture forward-looking preference* (the HLD's tie-breakers should be leaned on by every leaf design)
- **F2 (high):** `CLAUDE.md` carries the `## LID` mode block but none of the LID directives (no `linked-intent-dev` reference), so a fresh session won't be told how to work the arrow. Consider running `/update-lid` · *modes are declared, not inferred* (the instruction file is where the foundation is made visible)
- **F3 (medium):** The local-branch preference lives only in design prose ("keeps most copies off the courier van") with no Decisions & Alternatives row naming the rejected option (strict county-wide oldest) or the fairness cost · *docs carry current intent, written to be read cold* (the keep-side: live decisions need their reasoning on the page)
- **F4 (medium):** Hold cancellation has no spec of its own. `HOLDALLOC-007` and the design refer to cancelled holds, but nothing says when a cancelled hold's record is deleted, which matters for the "hold history is not kept" tenet · *effective intent-tree alignment* (LLD behaviors with no spec drift silently, with nothing to test against)
- **F5 (medium):** All 13 specs are marked `[x]`, but the repo has no tests, code, or `@spec` annotations to confirm it. If the implementation lives elsewhere, consider linking it; if not, the checkmarks claim more than the arrow can show · *tests before code* and *tests carry `@spec` annotations* (tests are how the arrow is walked from intent to behavior)
- **F6 (low):** Two tenets read as values or rules rather than tie-breakers: "Staff attention goes to exceptions" (its opposite isn't a real alternative) and "Hold history is not kept" (closer to a policy). The four tenets are also unordered, though 1 and 3 could pull against each other · *tenets capture forward-looking preference*
- **F7 (low):** Two small edges are left open: how ties on identical placement timestamps are broken in `HOLDALLOC-003`/`-004`, and what clears a copy's `allocated` state on pickup (no spec covers it) · *LLDs close enough of the solution space*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files (13 specs)
- No `docs/arrows/index.yaml` overlay present, so no structural or cascade-health enumeration was possible
- No code or test files found, so no `@spec` sampling was possible
- Cold-read pass done on every LID doc and the Decisions-table sweep done on all 7 rows. The expiry-handling row was already a well-captured acceptance of its Goal 1 cost, so it is not flagged.

**Want me to** walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project (multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large), I can help with those too.