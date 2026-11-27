I'd skip it: the length of the argument isn't what earns a decision doc, and this choice doesn't need one.

- **Nothing else is sized around it.** The policy is private to the preview worker. The HTTP contract, render queue and 12 GiB budget are the same under all three options, so reversing it later touches one node.
- **A cold reader's "why 2Q?" is settled in a few lines.** The decisions table in `docs/intent/previews/previews-design.md` already names LRU and aged frequency and says why each lost.
- **A doc would mostly preserve the debate.** Three meetings and 180 messages are history, not current intent, and a doc invites the re-litigation you want to end.

If what you want is for the row to carry more weight, I'd strengthen it instead. I could add the workload facts that drove the choice (24 editors, about 6,000 distinct clips a week against a cache of about 6,000 sheets) and state what evidence would reopen it, such as pilot traffic showing screenings rarely exceed the first-use share.

One thing would change my answer: if people outside this session are likely to reopen the choice and you want a single page to point them at, a decision doc does that job better than a table row. You know that audience and I don't.

It's your call, and I'll write it if you say so. It would go in `docs/intent/previews/decisions/`, linked from the row. Either way I still need your answer on what counts as "reuse" (A, B or C) and your triage of the six gaps before I revise the design. That answer would belong in the doc too.