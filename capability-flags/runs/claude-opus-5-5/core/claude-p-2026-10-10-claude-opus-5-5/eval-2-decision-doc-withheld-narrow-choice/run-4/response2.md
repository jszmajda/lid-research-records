I'd skip it. The length of the argument isn't what earns a decision doc; what matters is whether someone reading the finished design cold would reopen the question without the full tradeoffs in front of them. I don't think they would here:

- **The choice is contained.** It changes only the preview worker's private bookkeeping. The preview interface, render queue and 12 GiB budget are the same under all three policies, so nothing else is sized around it.
- **It is cheap to reverse.** Swapping to LRU or aged-frequency later touches one section of one doc and the code behind it.
- **The reasoning fits in a row.** The Decisions table already says why 2Q beat LRU (screenings evict the comparison set) and aged-frequency (stale favorites after a project switch, counter upkeep). That is the whole argument, and it's the first thing someone would find if they went looking to reopen it.

A decision doc would mostly restate that row at greater length, and the three meetings and the thread wouldn't go into it either way, since it records the tradeoffs, not the history.

The one thing I'd reconsider on: if the people who argued for LRU or aged-frequency are likely to raise it again and you want something more substantial to point them at, a doc with each option laid out at full strength does that better than a table row. That's a call about your team, not the design, so it's yours. Say the word and I'll write it at `docs/intent/previews/decisions/eviction-policy.md` and link it from the row.

Either way, the three choices and the gap list from my last message are still waiting on you before I draft the specs.