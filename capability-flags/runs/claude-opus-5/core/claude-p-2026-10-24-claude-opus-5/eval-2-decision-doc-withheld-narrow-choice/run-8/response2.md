My honest read: no, and the reason is specifically that the debate was long.

The test I'd apply is to the design as it landed, not to how hard it was to decide. A decision doc earns its place when a cold reader would re-litigate the choice without the competing options and criteria in front of them, *and* other design nodes are about to be sized around the result. The first half is satisfied here — three credible options, traded against bookkeeping cost, scan resistance, and adaptation speed. The second half isn't: your own HLD tenet keeps cache paths and replacement bookkeeping private to the preview worker, and the review API is specified not to consume eviction metadata. The whole decision is contained in one node. Nothing downstream is shaped by whether you picked 2Q or LRU, which is exactly what made it arguable for three meetings — there was no external constraint to settle it.

And the thing a doc would carry is already on the page. The Decisions row names both rejected options, the criterion each lost on, and the cost you accepted. A cold reader asking "why not LRU?" gets the answer in two sentences without opening another file.

The cost of the doc isn't the hour of writing — it's that you'd have two artifacts describing the same choice, and when the sizing gets retuned against pilot measurements, the LLD will move and the doc won't. Then a cold reader gets two answers about a decision that only ever had one home.

The pull you're feeling is real, though, and I don't think it's about 2Q. 180 messages of argument produced one genuinely live question, and it's the one I flagged: the A1in/Am split. That's the part a future reader *will* question, because it's a tunable with no principled value yet. If you want that debate memorialized, the place for it is a fuller Open Questions entry — what the split trades off, what measurement would settle it, what you'd expect to see in the pilot. That I'd write without hesitation.

Your call. If you want the decision doc anyway, say so and I'll write it properly — context, criteria, all three options, and the selection at enough resolution to re-run the judgment. I'd rather you have it and not need it than feel the argument vanished into a table row.

Either way I still need the sizing confirmation and your triage on the eight probe items before I go to Phase 3.