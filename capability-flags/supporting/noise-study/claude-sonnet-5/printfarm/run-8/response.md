## printfarm: LID coach report

### Executive summary

**Posture:** Healthy, well-shaped arrow. The main opportunity is a design decision that cuts against one of your own tenets.

**Scorecard**
- ✓ Configuration: the `## LID` block declares Full mode and the standard `docs/` layout is in place.
- ✓ Linkage: two design nodes, each with a matching spec file. `QUEUE-` and `REG-` prefixes match each LLD's `prefix:` frontmatter, and IDs are unique and zero-padded.
- ✓ Mutation hygiene: no changelog residue, no `[obsolete]` specs, no history narration.
- ✓ HLD discipline: the HLD holds problem, approach, architecture, tenets, goals and non-goals, with no implementation detail.
- ⚠ Tenet coherence: the queue's durability choice conflicts with the top tenet, and the tenets are unordered.
- ⚠ Decision capture and LLD sufficiency: one load-bearing choice is not in a Decisions table, and one term is left undefined.

**Headline:** The arrow is clean and easy to walk. The specs are crisp EARS, and the Decisions tables already name rejected alternatives and accepted costs. The most valuable next step is to reconcile the in-memory queue with the "a submitted job is a promise" tenet, and record that decision properly.

### Findings (5 total · 2 high · 2 medium · 1 low)
- **F1 (high):** The job queue lives only in memory, so accepted jobs are lost on restart. This contradicts the tenet "a submitted job is a promise", and the mini-PC takes unattended overnight OS updates. · *tenets capture forward-looking preference* (a tenet is a tie-breaker that should narrow real choices), and *intent leads; code is compiled output* (design should serve declared intent)
- **F2 (high):** The in-memory-queue choice is only in `job-queue-design.md`'s Architecture prose ("members resubmit them"). It has no Decisions & Alternatives row, no rejected alternative such as a durable queue, and no accepted cost such as lost overnight jobs. The `QUEUE-004` spec describes only the rebuild from printers, not the loss. · *docs carry current intent, written to be read cold* (a fresh reader can't reconstruct what was given up). This is a separate finding from F1: the design concern and the capture gap are both real. A fuller table row is the smallest fix. A decision doc is only an option if you want the full option space on record.
- **F3 (medium):** The three tenets are unordered, and the first and third are in direct tension. "A submitted job is a promise" pulls toward a durable queue, while "the service stays small" pulls toward memory. Ordering them would have settled F1 for the next session. · *tenets capture forward-looking preference*
- **F4 (medium):** "Suspect" is undefined. `QUEUE-003` and the queue LLD mark a printer suspect on dispatch failure, but the registry LLD's state model (id, class, address, state) and `REG-001` to `REG-003` never define it. It's also unclear how it differs from unreachable, how it clears, and whether suspect printers still receive dispatches. The queue is setting state the registry owns. · *LLDs close enough of the solution space* (two agents could implement it differently), and *intent attaches at the lowest node that dominates it* (a state used by both nodes belongs where it dominates both)
- **F5 (low):** `QUEUE-005` (staff reorder is visibly recorded) has no matching behavior in the LLD. The LLD mentions only priority classes and FIFO, and the HLD tenet "no silent reordering" is the sole source. Consider a short reordering paragraph in the LLD, covering who may reorder, within or across classes, and what "visible" means. · *coherence is adjacency*

### What was audited
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, and both spec files (2 design nodes, 8 EARS specs).
- Not present: `docs/arrows/index.yaml` (no arrow overlay), and no source or test files. The specs are all marked `[x]` (implemented), but there are no `@spec` annotations, tests or code to sample. I could not verify the implemented status or tests-first evidence, and did not treat the absence as a finding. If code lives in another repo or path, point me at it.
- Cold-read pass and Decisions-table sweep done on all docs. All six Decisions rows read well cold. The only capture gap is the one in F2.
- Non-interactive run: no prompts were needed, and none were skipped.

### Offer to help
Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into. F1 to F3 fit together as one working session.

If you have broader questions about using LID for your project (multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large), I can help with those too.