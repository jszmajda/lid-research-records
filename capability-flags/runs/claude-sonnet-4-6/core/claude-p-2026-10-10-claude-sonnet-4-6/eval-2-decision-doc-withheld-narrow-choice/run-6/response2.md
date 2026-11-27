The skill has a specific test for this, and the debate length explicitly isn't part of it.

The test from the *landed* state: would a cold reader of the finished system re-litigate this choice without the full tradeoffs written out? Probably yes — LRU is simpler and a cold reader might reach for it. That clears the "genuinely live" bar.

But the skill adds a carve-out that overrides it: **don't offer a decision doc for a choice that affects only its own node, however long the debate ran.** The eviction policy is entirely private to the preview worker — the external interface, render queue, and disk budget are all unaffected, and no other node sizes itself around this choice. It fails that test, so the Decisions & Alternatives table row is the right call.

The row already captures everything a cold reader needs: what the three options were, why LRU loses to screening scans, why frequency-with-aging adds maintenance cost and lags project switches, and why 2Q's extra queue is the accepted tradeoff. A decision doc over that same content would be length without purpose.

So: no decision doc here — the row is sufficient. Want to move on to the edge-case probe triage so we can get to Phase 3?