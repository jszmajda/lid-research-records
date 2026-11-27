My honest read: the row is the right fit, and I'd skip the doc.

The test isn't how hard the decision was to make — it's whether a cold reader of the *landed* design would re-litigate it without the competing options in front of them. Two things say they wouldn't. The choice is confined to one node: all three candidates changed only the preview worker's private replacement bookkeeping, nothing else in the system gets sized around which one won. And the rejection reasons compress honestly — "a screening scans more sheets than the cache holds, LRU lets it evict the comparison set, aged counters keep the previous production's favorites" is a sentence, not a document. That's already in the Decisions row.

A decision doc earns its place when a reader needs the criteria and the option matrix to follow why the loser lost. Here the loser loses for one reason that fits on a line.

There's also a cost worth naming: writing it properly means reconstructing three meetings and 180 messages of argument into a doc built to structure debate — which is the thing you just said you're ready to stop doing. And a `decisions/` directory that fills up with settled-obvious choices stops signalling anything.

What I'd do instead, if the worry is that the reasoning feels thin on the page: the parts that genuinely stay live are the tunables, not the policy — the 3 GiB / 9 GiB split, the 3,000-key cap, and probe item 1 (promote on a second hit while resident, or stay textbook 2Q). Those are already a Decisions row plus a deferred open question, and they'll get sharper from pilot hit rates than from more prose now.

That said, this is your call and you're the one who'll read these docs in six months. Say the word and I'll write it — `docs/intent/previews/decisions/cache-replacement-policy.md`, with the three options, the criteria they were traded on, and the selection, linked from the Decisions row.

Either way, probe items 1–7 are still waiting on your triage before I move to Phase 3.