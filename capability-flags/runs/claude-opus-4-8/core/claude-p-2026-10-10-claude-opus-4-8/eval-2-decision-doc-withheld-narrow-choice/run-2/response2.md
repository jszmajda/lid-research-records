Honest answer: I'd hold off, and I want to give you the real reasoning rather than just say yes.

The test for a decision doc isn't how hard the decision was to make — it's what a *cold reader of the result* needs. The skill is pointed about this: judge from the landed state, not the deliberation. "After all that arguing" is the deliberation; a doc that exists to memorialize how contested something *was* is exactly the residue the docs-carry-current-intent tenet strips. Three meetings and 180 messages tell us it was hard to settle — they don't tell us a future reader will re-litigate it.

Two things specifically point to a row over a doc here:

1. **It affects only its own node.** The HLD deliberately fixed the interface, the 4-job queue, and the 12 GiB budget so the eviction choice stays inside the previews worker. Nothing else gets sized around 2Q — no sibling node, no shared contract. That's the skill's bright line for *not* offering a doc, "however long the debate ran."
2. **The row already carries what a cold reader would re-litigate from.** The Decisions & Alternatives row names 2Q, names LRU and aged-frequency as the rejected options, and gives the criteria (scan resistance vs. bookkeeping cost vs. project-switch lag). A full doc re-litigates a choice when the options and criteria *aren't* written down. They are.

So the row isn't a lightweight consolation — it's the right weight. A full doc here would mostly be a monument to the argument, and a `decisions/` directory full of those is its own smell.

That said — it's your call, and a decision doc is cheap. If you still want one (say, so the thread's participants can see their case was heard and not reopen it), I'll write a proper one: context, the criteria, all three options with their consequences, and a fit verdict for 2Q, then link it from the Decisions row. Want me to, or shall we leave the row and move to the EARS cascade?