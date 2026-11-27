I'd skip it: the row already in the previews design is the right-sized record, and the length of the argument isn't what a decision doc is for.

The test is whether someone reading the finished design cold would re-litigate the choice without the full tradeoffs laid out. Here I don't think they would:

- **It affects only the preview worker.** The interface, render queue and 12 GiB budget are identical under all three policies, and the HLD keeps replacement bookkeeping private. Nothing else is sized around 2Q, so reversing it later is a contained change.
- **One sentence settles the "why".** Editors mix long screenings with repeated comparisons, LRU loses the comparison sheets to scans, and aged frequency clings to a finished project's favorites. The row says this and names both rejected options.
- **A doc would mostly preserve the debate.** The three meetings and the thread are history, and the design docs are meant to carry current intent only.

One thing would change my answer. If the people who argued for LRU or aged frequency are likely to reopen this when the pilot numbers come in, a doc that states the criteria and what evidence would flip the choice could save you a fourth meeting. That's a call about your team that only you can make.

If you want it, say so and I'll write `docs/intent/previews/decisions/eviction-policy.md` and link it from the row. Either way, I still need your ruling on the two choices and the eight gaps from my last message before I move on to the specs.