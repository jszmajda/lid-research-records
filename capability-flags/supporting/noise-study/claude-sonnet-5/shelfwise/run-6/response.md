## LID Coach report: Shelfwise

**Posture:** Bootstrapping. The design layer is unusually clean, but the arrow stops at the specs and the instruction file hasn't caught up.

**Scorecard**
- ✓ Design docs read cold: the HLD and both LLDs carry present-tense intent, with no changelog residue, `[obsolete]` specs or history narration
- ✓ Decisions & Alternatives: most rows name the rejected option and the accepted cost
- ✓ Spec hygiene: EARS phrasing, unique namespaced IDs and scoped WHEN clauses throughout
- ✓ Tenets: present, and mostly real tie-breakers
- ⚠ Arrow completeness: no tests or code are visible below the specs
- ⚠ Configuration: the instruction file has the mode marker but no LID directive block
- ⚠ Intent coherence: one allocation rule pulls against the first tenet

**Headline:** The design layer is compact and readable, with well-written specs and real tenets. The most valuable next step is to reconcile the local-branch-first allocation rule with the "waiting is honored in sequence" tenet, and to record that decision in the Decisions table. Configuration and the missing test/code layer come right after.

**Findings (7 total · 3 high · 2 medium · 2 low)**
- **F1 (high):** The instruction file has the `## LID` mode block but no `linked-intent-dev` / "Linked-Intent Development" directives. Consider `/update-lid`. · *modes are declared, not inferred* (the foundation should be explicit, not defaulted)
- **F2 (high):** Local-branch-first allocation (`HOLDALLOC-003`/`-004`, hold-allocation design §Design) lets a later requester at the scanning branch receive a copy ahead of an older hold elsewhere. That cuts against the tenet "nobody's wait is lengthened by a patron who asked after them". Either the tenet needs a stated exception or the rule needs a different shape. · *intent leads; code is compiled output* (a conflict at the intent level gets resolved arbitrarily downstream if it stays open)
- **F3 (high):** Every spec is marked `[x]`, but the repo shows no tests and no code, and there are no `@spec` annotations. The arrow can't be walked past EARS. If the implementation lives in another repo, say so in the instruction file. If it doesn't exist yet, consider `[ ]` markers and tests-first. · *canonical arrow shape*; *tests before code*; *tests carry `@spec` annotations*
- **F4 (medium):** The local-first choice appears only in prose (courier-van rationale) and not in the Decisions & Alternatives table. A cold reader would question it, and F2 shows why. Consider a fuller row naming the rejected alternative (strict county-wide FIFO), the accepted cost (a longer wait for some older holds) and the tenet exception. A row is enough; a decision doc is not warranted. · *docs carry current intent* (decision capture)
- **F5 (medium):** The hold-allocation LLD leaves some edges open. It doesn't say what happens when a hold is cancelled while its copy sits `allocated` on a holds shelf. It doesn't say when `allocated` is cleared, or what happens to the copy on arrival when the hold is still live but the shelf scan never occurs. `HOLDALLOC-007` covers only the in-transit case. · *LLDs close enough of the solution space*
- **F6 (low):** Tenet 4, "Hold history is not kept", reads as a settled data-handling decision rather than a lean, and `PICKUP-003` already fixes the behavior. Tenets 1 and 2 could also conflict, and the list is unordered. Consider moving tenet 4 to a key design decision, and ordering the tenets that can conflict. · *tenets capture forward-looking preference*
- **F7 (low):** `PICKUP-005` re-enters allocation on expiry, but the hold-allocation LLD names only check-in as a trigger, and neither LLD references the other. Consider a one-line cross-reference at that seam. Also consider a non-goals line in the HLD. · *coherence is adjacency*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (hold-allocation, pickup-notices) and both spec files (13 specs)
- Dispatch: LID-shaped (HLD, intent docs and `*-specs.md` present). Mode is Full (declared), and no `## LID Scope` is needed. There is no arrow overlay (`docs/arrows/` is absent), so no index or drift fields were read.
- Code and tests: none found to sample, so there is no `@spec` linkage metric
- Cold-read pass and Decisions-table sweep: done on all 7 table rows. Only the local-first choice failed the sweep, and it isn't in a table row at all (F4).

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.