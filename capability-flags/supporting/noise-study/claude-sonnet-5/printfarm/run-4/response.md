## printfarm: LID coach report

**Posture:** Well-shaped design layer with one load-bearing decision that works against the project's own tenets. The code and test end of the arrow isn't visible yet.

**Scorecard**
- ✓ Configuration: directives, `Mode: Full`, and the standard `docs/` layout are all in place
- ✓ Design tree: the HLD names two nodes, and each has a matching LLD and spec file with a `prefix:` in its frontmatter
- ✓ Spec hygiene: EARS phrasing is clean, IDs are unique and grep-friendly, and there are no `[obsolete]` leftovers or changelog residue
- ⚠ Decision capture: the most consequential choice, an in-memory queue, is not in a Decisions table
- ⚠ Arrow below the specs: no tests or code with `@spec` annotations could be found from this directory
- ⚠ LLD-to-spec coverage: several LLD behaviors have no spec

**Headline:** The HLD is compact, and its tenets are real tie-breakers. The specs are tidy, and the Decisions rows I read (scheduling order, job IDs) name a rejected alternative and an accepted cost. The most valuable next step is to reconcile the in-memory queue with the "a submitted job is a promise" tenet, then record that choice properly.

**Findings (7 total · 2 high · 3 medium · 2 low)**
- **F1 (high):** The job-queue LLD keeps accepted jobs only in memory and drops undispatched jobs on restart, which contradicts the HLD tenet "a submitted job is a promise" and the overnight-print goal. The LLD's own context section names OS updates and power blips as expected events. · *intent leads; code is compiled output* (specs and LLDs should express what you want, not what is cheapest to build)
- **F2 (high):** That same choice is stated only in Architecture prose. No Decisions & Alternatives row names the rejected alternative (for example persisting the queue, as the registry already does with SQLite) or the accepted cost, and nothing tells a member what to expect after a restart. A cold reader would still be tempted to reverse it. · *docs carry current intent, written to be read cold* (decisions that stay live need their tradeoffs on the page)
- **F3 (medium):** The HLD tenets "a submitted job is a promise" and "the service stays small" pull in opposite directions on F1, and they are unordered. Listing them in priority order would settle the conflict for future sessions. · *tenets capture forward-looking preference* (tie-breakers should say which lean wins)
- **F4 (medium):** Every spec is marked `[x]`, but there are no tests or code in this directory carrying `@spec` annotations. The completion marks can't be checked against anything, and the arrow can't be walked past the specs. If the code lives elsewhere, consider noting where. · *tests carry `@spec` annotations* and *canonical arrow shape*. Run `/arrow-maintenance` once code exists to enumerate linkage precisely.
- **F5 (medium):** Some LLD behaviors have no spec:
  - accepting a job only when its class has a registered printer
  - the staff and member priority classes, with FIFO inside each
  - content-hash file storage
  - the 90-day slug recycling
  - the outcome for members when queued jobs are lost at restart

  Without specs there is nothing to test against, so these can drift silently. · *effective intent-tree alignment* (each LLD behavior should have a spec)
- **F6 (low):** The queue marks a printer "suspect" (QUEUE-003), but the registry LLD and specs define only unreachable, idle and busy states, and the registry owns printer state. Consider defining "suspect" in the registry node and having the queue cite it. · *coherence is adjacency* and *intent attaches at the lowest node that dominates it*
- **F7 (low):** Cold-read gaps: "printer class" is never defined in the HLD or the LLDs, though the whole queue is organized around it. "Head job" and "suspect" are also undefined, and the HLD has no success metrics. A sentence or two would help future sessions. · *docs carry current intent, written to be read cold*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs and both spec files under `docs/intent/`
- Enumerated: 2 LLDs, 2 spec files, 8 EARS specs (5 QUEUE, 3 REG)
- Arrow overlay: `docs/arrows/` not present, so segment-level sampling wasn't possible
- Code and tests: none found in the project directory, so no `@spec` sampling was done
- Decisions-table sweep: 5 rows reviewed. The queue's LLD has 3 and the registry's has 2. The one decision that fails the cold-reader test is the in-memory queue, which isn't in a table (F2).

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.