Overkill — and the reason is worth naming, because it isn't "the debate was short."

The test runs from the landed state, forward: would a cold reader of the finished registry design find the SQLite index non-obvious, question it, or be tempted to reverse it? They wouldn't. They'd read the HLD tenets — no runtime network access, no network route, signed USB as the only update channel — and find a kiosk-local index to be the only shape that fits. The structure documents itself.

That's what makes this a row rather than a doc, and the deliberation doesn't change it. A decision doc earns its place when a choice stays *live*: a reader would re-litigate it without the competing options and criteria laid out in front of them. Here the alternatives aren't live, they're eliminated — an inherited constraint took them off the table. A doc would spend a page reconstructing a comparison whose answer the HLD already gives on one line, and a `decisions/` directory full of that kind of entry is a smell.

The fact that you went back and forth is a symptom, not the test. What it points at isn't a missing doc — it's that my option sketch presented three things as comparable when one of them was the only candidate that passes a standing constraint. The fix for that is upstream of the recording question.

So the row stays as written. It carries the one line a cold reader needs:

> Both alternatives put a network call on the lookup path, which the kiosks have no route for and the design does not permit.

Two narrower things I'd rather have on the page than a doc about the backend:

- The **normalized-key** row already notes its real cost — the index is only valid under the normalization rules it was built with. That's the choice a cold reader is actually most likely to question, and it's the one whose reversal would hurt.
- If the HLD's network tenets ever loosen, the on-site directory becomes live for the first time, and *that's* when a doc would earn its place — at the tenet change in Phase 1, not here.

Still waiting on the probe triage from my last message: which of 5–7 to fold into the LLD now, and the direction on 1–3 (the result-type question that reaches into certificates).