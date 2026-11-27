My recommendation is to keep the row in the Decisions & Alternatives table and skip the full decision doc.

The test is whether a cold reader of the landed design would question 2Q or be tempted to reverse it. How long we argued doesn't count.

- **The choice stays inside the previews node.** The HTTP contract, render queue, and disk budget are unchanged, and the Review API and the HLD only note that the policy is now 2Q. No sibling design node is being sized around the result, which is the usual reason to write a full doc.
- **The table row already carries the rationale.** It names the workload (long screenings alternating with repeated comparisons), the failure of LRU under scans, the staleness cost of aged frequency, and the price of 2Q. A cold reader can re-run the judgment from that.
- **The remaining uncertainty is tuning.** The size split and ghost-list length are parameters, not a live choice between policies. If real workloads show 2Q is wrong, replacing it is a contained change inside one worker, so it is easy to undo.
- **The 180-message thread is not a reason to write a doc.** Decision docs should be rare, and the skill specifically excludes choices that affect only their own node, however long the debate ran.

The case for a doc would be if you expect people outside this team to push for LRU or aged frequency later. A doc would also help if you want the measured workload numbers (6,000 clips a week, 2 MiB sheets) preserved with the criteria. I'd cover either of those by expanding the row, not by adding a doc.

It's your call, though. If you still want the doc, I'll write it at `docs/intent/previews/decisions/` with context, criteria (scan resistance, bookkeeping cost, adaptation speed, tuning burden), the three options, and the 2Q selection with a fit verdict. I'd link it from the Decisions row. The only cost is one more artifact to keep current.

I haven't changed any files in response to this. Say "write it" or "keep the row", and also send your answers to questions 1–4 from my last message so Phase 3 can start.