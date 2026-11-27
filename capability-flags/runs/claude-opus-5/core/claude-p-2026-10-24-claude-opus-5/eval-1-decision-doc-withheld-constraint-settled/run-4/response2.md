Overkill — I'd keep the Decisions row.

The test is applied to the design as it lands, not to how hard the deliberation was. A cold reader opens the HLD, sees "no runtime network access is permitted" and "cloud services during kiosk operation" as a non-goal, then opens the registry LLD and finds an on-disk embedded index. That reads as native, not as a choice to re-litigate. There's nothing for a decision doc to preserve, because the competing options don't survive contact with the HLD — a doc laying out HTTPS-directory and managed-search criteria would mostly be explaining why two non-starters were non-starters.

What the row still earns is the part that *is* live: SQLite over a per-query NDJSON scan or an in-memory map. That one a cold reader could reasonably question — "90,000 records, why not just load them?" — and one line about the 4 GB RAM budget and the 250 ms goal settles it. That's already in the table.

The thing that would change my answer: if the no-network tenet is softer than the HLD states — if the lab network is genuinely on the table and you were weighing it on its merits rather than against a constraint. Then the choice stays live for a future reader, it's an HLD-level decision rather than a registry one, and it'd want a doc in `docs/decisions/`. Your "they looked pretty close at first" is the only reason I'm raising it twice; if the tenet holds, ignore this.

Still waiting on the three from the last message — the alternatives question, group B (no-snapshot result type), and the group-D normalization fork — before I move to Phase 3.