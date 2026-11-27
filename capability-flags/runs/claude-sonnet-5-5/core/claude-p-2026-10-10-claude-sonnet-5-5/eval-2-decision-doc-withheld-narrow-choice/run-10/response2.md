I'd keep it as the Decisions row and skip the standalone doc. The row already holds the rationale, and the doc doesn't clear the bar for this choice.

The test isn't how long the debate ran. It's whether a cold reader of the landed design would re-litigate the choice without the competing options laid out. Three things point against a doc here:

- **Scope.** The decision only affects the previews node. The interface, render queue, and disk budget are identical under all three options, and the review API node is untouched. No other design node is being sized around the result.
- **Settled criteria.** The tradeoff was effectively one question: protect comparison sheets from screening scans, versus bookkeeping cost. The row names that, along with what LRU and aged-frequency would have cost. A reader can follow it and see why 2Q won.
- **Record of the arguing.** The three meetings and the 180-message thread don't belong in the design either way. A fresh reader needs the options and the criteria, not who argued what.

If this does get revisited, the likely trigger is tuning (the queue split, the ghost list length) or real eviction data from a pilot. That would be a new decision with its own evidence, and it would go in the Deferred items or a later row, not in a doc written now.

That said, it's your call. If you want a doc anyway, for instance because the team will otherwise reopen the thread, I'll write it under `docs/intent/previews/decisions/` using the decision-doc template, and link it from the Eviction policy row.

Separately, the three open gaps from my last message (reuse in the first-use queue, queue split and ghost length, restart behavior) still need your ruling before I draft the specs.