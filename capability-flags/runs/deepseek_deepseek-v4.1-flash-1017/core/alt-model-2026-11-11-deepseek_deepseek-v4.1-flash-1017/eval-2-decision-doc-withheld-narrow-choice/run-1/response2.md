I'd keep it as the Decisions & Alternatives rows rather than a full decision doc. The choice lives entirely inside the preview worker — no sibling node is sized around it — and the rationale is compact: 2Q protects the comparison set from screening scans at the cost of two queues and a split we tune. That settles a cold reader's "why this?" without re-running the argument.

That said, you're the one who has to live with the record. If you want the long-form version for the team anyway — the competing options, the criteria, and why 2Q won — say so and I'll write `docs/intent/previews/decisions/cache-replacement.md` and link it from the LLD. Otherwise I'll leave the rows as they are.

Either way, the LLD gap questions from my last message still need your calls before I draft the EARS specs.