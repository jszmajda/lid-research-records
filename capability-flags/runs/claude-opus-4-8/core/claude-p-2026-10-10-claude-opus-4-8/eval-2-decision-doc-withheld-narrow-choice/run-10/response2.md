Honestly, my recommendation is no — keep it as the Decisions row.

I know that feels stingy after three meetings and 180 messages, but the amount of arguing isn't the test. The test is about the *landed* result: would a cold reader of the finished design re-litigate the choice *if the competing options and criteria weren't written down*? A decision doc earns its place only when a table row can't carry enough for them to reconstruct the judgment.

Two things point away from a doc here:

- **The row already carries the whole argument.** It names 2Q, names LRU and frequency-with-aging, and gives the criteria each was weighed on (scan resistance vs. bookkeeping vs. project-switch adaptation) and why 2Q won. A cold reader doesn't re-litigate from that — they see the reasoning and move on. A separate doc would mostly restate it.
- **The choice sizes only the previews node.** All three options were explicitly private to the preview worker — the interface, render queue, and disk budget don't move, and no sibling gets designed around the result. Decision docs are for choices that stay live *across* the system; this one doesn't leave its own node. That disqualifier holds however long the debate ran, which is exactly the case LID calls out, because a long argument makes a doc *feel* deserved regardless of whether the landed choice needs one.

Where a full doc genuinely would earn its place is if the recent-share and ghost-size *tuning* turns into its own ongoing debate with real downstream consequences — but that's not what you've decided yet, and we can spin one up then if it does.

That's my read. You own this call, though — if you still want the doc, say so and I'll write it under `docs/intent/previews/decisions/` and link it from the row. Either way, I still need your answers on the recent share, the ghost-queue size, the no-early-promotion behavior, and the stale HLD clause before I move to EARS.