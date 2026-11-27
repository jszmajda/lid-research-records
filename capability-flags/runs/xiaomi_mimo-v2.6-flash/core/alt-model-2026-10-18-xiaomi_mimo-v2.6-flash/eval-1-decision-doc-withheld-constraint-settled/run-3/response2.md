Overkill — I'd record it as a row in the registry LLD's Decisions & Alternatives table, no decision doc. Reasons:

1. **Inherited constraint settles it.** The HLD's tenets ("lookup SHALL complete using files on the kiosk; no runtime network access," "kiosks have no network route") are gates the other two options fail outright. The decision-doc heuristic says not to offer a doc for a choice an inherited constraint settles.
2. **Landed reading is obvious.** A cold reader of the finished registry design sees offline kiosk + USB snapshots + local index and reaches "SQLite, of course" without re-litigating; the HLD line settles any doubt. The doc's test is the landed state, not how long we deliberated.
3. **The tradeoff memory still lands.** The row's Alternatives column keeps the three candidates and why the network options were trimmed — one line, which is what "why this?" needs here.

Where it *would* earn a doc: if the no-network tenet were itself up for revision (e.g., you later allow an on-site directory), the choice becomes genuinely live again — at that point write the doc.

Want me to proceed to Phase 2 (finish the registry LLD with the SQLite design, decision recorded as a row), or do you want the decision doc anyway?