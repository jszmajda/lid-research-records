**LID Coach review: Field Notes**

**Executive summary**

Posture: *Early and well-shaped. The arrow is in place, and the decisions need fuller capture.*

**Scorecard**
- ✓ HLD discipline: architecture and rationale only, with no schemas or signatures
- ✓ Linkage: the `SYNC` prefix resolves to the Sync LLD, and both specs trace to it
- ✓ Mode fit: Full suits a project at this stage of design
- ⚠ Decision capture: the conflict-resolution row gives no cost for its choice
- ⚠ LLD sufficiency: merge and tie-breaking edges are still open
- ⚠ Arrow completeness: the arrow stops at specs, with tests and code not yet started

**Headline:** The HLD is clean, the Sync leaf walks from HLD to specs, and the last-writer-wins choice honors the *boring over clever* tenet. The fastest next step is to write down what that conflict rule costs in its Decisions row and close the merge edges before code begins.

**Findings (9 total · 2 high · 4 medium · 3 low)**
- **F1 (high):** The conflict-resolution row's rationale is only "Simpler." The LLD's own Context says device clocks run minutes off, so a later real edit can be silently discarded. Consider naming the alternative and the accepted cost. · *docs carry current intent* (decision capture: a cold reader would question this row)
- **F2 (high):** Merge behavior is under-specified. "Pending edits" is undefined, equal timestamps have no tie-break, and non-conflicting merges are not described. · *LLDs close enough of the solution space*
- **F3 (medium):** The tenet list has one entry, and nothing in it speaks to the data-loss trade-off the conflict rule makes. A second tenet could pre-decide that trade-off. · *tenets capture forward-looking preference*
- **F4 (medium):** The HLD names a device-local store, but only a Sync LLD exists. The SQLite decision sits in the Sync LLD even though it governs the store. · *one LLD per intent component*; *intent attaches at the lowest node that dominates it*
- **F5 (medium):** The goal "No blocked capture in the field" has no LLD or spec to trace to. · *effective intent-tree alignment*
- **F6 (medium):** The merge step in Architecture has no spec. SYNC-001 and SYNC-002 cover upload and conflict only. · *LLD behaviors with no specs are unnamed intent*
- **F7 (low):** The `[x]` marker in the specs file has no legend, so a cold reader can't tell whether checked means implemented, verified, or agreed. · *docs written to be read cold*
- **F8 (low):** Tests and code phases have not started, and there are no `@spec` annotations yet. This is expected at this stage; when implementation begins, tests-first would keep the arrow walkable. · *canonical arrow shape*
- **F9 (low):** The HLD omits target users, key design decisions, and success metrics from the content the HLD is meant to carry. · *HLD is architecture and rationale*

**What was audited**
- Read fully: `CLAUDE.md` (LID directive and Full mode marker), `docs/high-level-design.md`, `docs/intent/sync/sync-design.md`, `docs/intent/sync/sync-specs.md`
- Enumerated: 1 HLD, 1 LLD, 1 spec file with 2 specs
- Arrow-path sampled: none. There is no arrow overlay, and the repo has no code or tests to walk to.
- Linkage metric: 0 `@spec` references
- Checked, no conflict found: the last-writer-wins rule against the tenet and goals. It converges deterministically, and its cost is accuracy under clock skew, which F1 covers.

If you have questions about the findings, I can walk through any of them in detail, or work through specific items together. I can also help with broader LID-usage questions, such as adopting it across multiple repos, where PRDs fit, or when a segment grows too large.