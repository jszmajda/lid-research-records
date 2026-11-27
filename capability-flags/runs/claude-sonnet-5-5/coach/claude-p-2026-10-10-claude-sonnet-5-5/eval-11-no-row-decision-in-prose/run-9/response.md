## printfarm — LID Coach review

### Executive summary

**Posture:** Solid foundations, with one design-versus-tenet tension worth resolving.

**Scorecard**
- ✓ Configuration: Full mode is declared and the `## LID` block is present. The HLD and the `docs/intent/` tree match the layout the mode expects.
- ✓ HLD discipline: the HLD is short, holds problem, approach and rationale, and has no implementation detail.
- ✓ Spec hygiene: EARS phrasing is consistent, IDs are unique and prefixed by node (`QUEUE-`, `REG-`), and the LLD `prefix:` frontmatter matches.
- ✓ Doc currency: no history residue or change-narration in any doc I read.
- ⚠ Tenet cascade: the job-queue's in-memory design works against the HLD's first tenet and its goal.
- ⚠ Arrow completeness: the specs are all marked `[x]`, but the repo has no tests or code to carry `@spec` linkage.

**Headline:** The design tree is small, readable and cleanly specified, with real tenets, rationale-bearing decision rows and tight EARS specs. The most valuable next step is to decide deliberately how the queue's restart behavior squares with "a submitted job is a promise".

### Findings (5 total · 1 high · 3 medium · 1 low)

- **F1 (high):** the in-memory queue drops accepted jobs on restart, which works against the tenet "A submitted job is a promise… upload and walk away" and the goal "overnight print… with no member present". The LLD's own Context names unattended OS updates and power blips. No Decisions row records the exception. · *tenet cascade: do the design nodes lean the way the HLD's tenets say to lean?*
- **F2 (medium):** the choice of an in-memory queue, with members resubmitting, lives only as architecture prose in `job-queue-design.md`. It has no row in Decisions & Alternatives naming the alternative (for example persisting the queue as the registry does) or the cost accepted. A cold reader would likely question it. · *docs carry current intent; decision capture*
- **F3 (medium):** specs are marked `[x]` but no tests or code exist in the repo, so the `@spec` arrow stops at EARS. Either the implementation lives elsewhere, or the markers claim more than the repo shows. · *canonical arrow shape; tests carry `@spec` annotations*
- **F4 (medium):** QUEUE-003 marks a printer "suspect", but the registry's design and REG specs define only unreachable, idle and busy. The state is undefined, and it is unclear who clears it or whether it blocks dispatch. This crosses a node boundary. · *coherence is adjacency; intent attaches at the lowest node that dominates it*
- **F5 (low):** a few stated behaviors have no spec: the "accepted only if the class has a registered printer" rule, the two-class FIFO prioritization, and the heartbeat interval. · *effective intent-tree alignment: LLD behaviors with no spec drift silently*

### What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files.
- Enumerated: 2 design nodes, 2 spec files, 8 EARS specs (5 `QUEUE`, 3 `REG`).
- Not present: `docs/arrows/` overlay, and any test or source files, so no `@spec` linkage was sampled.
- Cold-read pass and Decisions-table sweep: done across all docs.

### Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into. F1 and F2 are good ones to take together.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.