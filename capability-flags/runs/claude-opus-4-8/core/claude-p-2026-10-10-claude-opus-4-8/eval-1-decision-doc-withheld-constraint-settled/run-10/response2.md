My recommendation: **overkill** — the Decisions row is the right home, for two reasons.

- **An inherited constraint does most of the work.** The no-runtime-network tenet eliminates both networked options for lookup outright. A full decision doc earns its place when the choice stays *live* — a cold reader would re-litigate it without the options and criteria laid out. Here a cold reader starting from the tenets would land on a local index on their own; SQLite as the embedded-index choice reads as native, not something they'd be tempted to reverse.
- **Nothing else gets sized around it.** The other half of the bar is "other design nodes about to be sized around the result." The certificate node is explicitly insulated (interface unchanged), and the only things the choice shapes — the import build/swap and the lookup path — live inside this same LLD. That's a within-node consequence, which the row already captures.

The fact that it felt close while you deliberated is the deliberation, not the landed result — and the skill's test is deliberately the landed result. A choice that was contested but reads as obvious once it lands is exactly the case the row covers without a doc.

Where I'd change my answer: if you expect the backend to stay genuinely contestable — e.g. you think a future reader might seriously reopen "why not a prebuilt index shipped in the snapshot, or a flat sorted file" — then a doc laying out the criteria (250 ms budget, per-kiosk rebuild cost, snapshot-format independence) would be worth it. If that's the risk you're feeling, I'll write it; otherwise the row stands.

Still need your call on the **normalized-key collision** (Open Question #1) before I move to the specs, plus whether to specify or defer #2 and #3.